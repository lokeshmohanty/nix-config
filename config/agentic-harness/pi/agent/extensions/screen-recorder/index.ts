/**
 * screen-recorder — /record, a natural-language front door to screen recording.
 *
 *   /record record my screen for 10 seconds and turn it into a gif at 800px
 *   /record start recording the left half of the screen
 *   /record stop and convert the last recording to a 12fps gif
 *   /record                     (no args: print the current state)
 *
 * Deliberately registers NO tools. Tool schemas are charged to every session's
 * system prompt whether or not recording ever comes up; a command costs nothing
 * until it is typed. The work is done by a fleet subagent (`pi-agent`) driving
 * the `screen-rec` CLI, which is the single source of truth for how this machine
 * records and converts video — see agents/docs/harnesses.md.
 *
 * API surface follows harness-ops/index.ts (verified against pi 0.82.0).
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile, execFileSync } from "node:child_process";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const HARNESS_BIN = join(homedir(), ".nix", "config", "agentic-harness", "bin");

/** Seconds a worker gets. Recording tasks wait on real time (a 30s capture is
 *  30s of nothing) on top of a model that needs minutes per step. */
const WORKER_TIMEOUT_S = 1800;

/** Resolve a harness script: PATH first, then the nix-repo copy. */
function resolve(name: string): string {
	const fallback = join(HARNESS_BIN, name);
	return existsSync(fallback) ? fallback : name;
}

/** The worker's brief. Points at the CLI rather than restating its flags, so
 *  this never drifts from `screen-rec --help`. */
function taskFor(request: string): string {
	return [
		`The user asked, verbatim: "${request}"`,
		"",
		"Do it with the `screen-rec` CLI (on PATH, also at " + join(HARNESS_BIN, "screen-rec") + ").",
		"Do not hand-write gpu-screen-recorder or ffmpeg invocations — screen-rec already encodes the",
		"working flags for this machine.",
		"",
		"Run `screen-rec` with no arguments first: it prints whether something is already recording,",
		"the recent recordings, and the available commands. `screen-rec <command> --help` gives a",
		"command's flags and examples.",
		"",
		"Things worth knowing:",
		"- `screen-rec start` … `screen-rec stop` is the record cycle. The recording is detached and",
		"  survives your session, so never leave one running unless the user asked you to.",
		"- For a fixed duration: start, sleep that many seconds, then stop.",
		"- `screen-rec convert <file> --format gif --width 800 --fps 15` produces a shareable gif;",
		"  with no <file> it converts the most recent recording.",
		"- Anything that needs the user to point at part of the screen (`--region` with no geometry)",
		"  opens an interactive selector — only use it if the request implies the user is at the screen.",
		"",
		"You capture whatever is already on the screen. You cannot play the user's games, drive their",
		"apps, or put anything on screen yourself. If the request needs particular content shown — a game",
		"being played, a feature demoed — do NOT record an idle desktop and do NOT keep trying: stop",
		"immediately and report that the user has to perform it, with the exact commands they should run",
		"(`screen-rec start --region`, do the thing, `screen-rec stop`, then `screen-rec convert …`).",
		"Recording per artifact: N separate gifs need N separate start/stop cycles, not one recording.",
		"",
		"Report the absolute path of every file you produced, with its size and duration.",
	].join("\n");
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("record", {
		description: "Screen recording in plain language — dispatched to a subagent (e.g. /record 10s of my screen as a gif)",
		getArgumentCompletions: (prefix: string) =>
			[
				{ value: "record my screen and make a gif", label: "record, then convert to a gif" },
				{ value: "start recording the screen", label: "start — leave it running" },
				{ value: "stop recording", label: "stop — finish and save" },
				{ value: "convert the last recording to a gif at 800px", label: "convert the last recording" },
			].filter((i) => i.value.startsWith(prefix) || prefix === "") as any,

		handler: async (args: string, ctx: any) => {
			const request = (args ?? "").trim();

			// No request: just show the live state, cheaply and synchronously.
			if (!request) {
				let state = "";
				try {
					state = execFileSync(resolve("screen-rec"), [], { encoding: "utf-8", timeout: 10_000 }).trim();
				} catch (err: any) {
					state = `screen-rec is unavailable: ${err?.message ?? String(err)}`;
				}
				pi.sendMessage(
					{
						customType: "screen-recorder",
						content: `${state}\n\nAsk for what you want in plain language, e.g.\n`
							+ `  /record record 10 seconds of my screen and make it a gif at 800px\n`
							+ `  /record start recording with desktop audio\n`
							+ `  /record stop and convert it to a 12fps gif`,
						display: true,
					},
					{ triggerTurn: false },
				);
				return;
			}

			ctx?.ui?.notify?.("record: dispatching to a subagent…", "info");

			// Detached from this handler: a recording task can run for minutes and
			// blocking the handler would freeze the TUI. The report is pushed into
			// the conversation when the worker finishes.
			// pi-agent runs its own `timeout $PI_AGENT_TIMEOUT`. Keep ours strictly
			// longer, so its expiry wins and its "worker timed out" message survives;
			// two equal timeouts race and node's SIGTERM kills the messenger.
			execFile(
				resolve("pi-agent"),
				["implementer", taskFor(request)],
				{
					timeout: (WORKER_TIMEOUT_S + 60) * 1000,
					maxBuffer: 8 * 1024 * 1024,
					env: {
						...process.env,
						PI_AGENT_THINKING: "low",
						PI_AGENT_TIMEOUT: String(WORKER_TIMEOUT_S),
					},
				},
				(err: any, stdout, stderr) => {
					const report = (stdout || "").trim();
					// err.message would echo the entire task prompt back — report the
					// exit condition and the tail of pi-agent's diagnostics instead.
					let failure = "";
					if (err) {
						// err.killed means *we* timed it out; a bare signal came from elsewhere.
						const why = err.killed
							? `hit the ${Math.round(WORKER_TIMEOUT_S / 60)}min timeout and was killed`
							: err.signal
								? `was killed (${err.signal})`
								: `exited ${err.code ?? "abnormally"}`;
						const detail = (stderr || "").trim().split("\n").slice(-3).join("\n");
						// A killed worker never gets to run its own cleanup, so a recording
						// it started is still running. Say so rather than leaving it to rot.
						let dangling = "";
						try {
							const state = execFileSync(resolve("screen-rec"), ["status"], {
								encoding: "utf-8",
								timeout: 10_000,
							}).trim();
							if (!/^recording: idle/.test(state)) {
								dangling = `\n\nA recording is STILL RUNNING — stop it with \`screen-rec stop\`:\n${state}`;
							}
						} catch {
							/* status is best-effort */
						}
						failure = `\n\n(worker ${why}${detail ? `:\n${detail}` : ""})${dangling}`;
					}
					pi.sendMessage(
						{
							customType: "screen-recorder",
							content: `/record ${request}\n\n${report || "(the worker produced no output)"}${failure}`,
							display: true,
							details: { request },
						},
						{ triggerTurn: false },
					);
				},
			);
		},
	});
}
