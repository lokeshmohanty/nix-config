/**
 * pi-harness-delegate — delegation-support extension for pi.
 *
 * Registers a `pick_skills` tool that, given a task description, returns the
 * harness skills whose purpose best matches it plus each skill's memory/ files —
 * so a subagent (spawned via @tintinweb/pi-subagents) can auto-load the right
 * knowledge before acting. It is a thin wrapper over the shared `harness-skill-pick`
 * CLI so skill-selection logic has a single source of truth across Claude & pi.
 *
 * API surface copied from the installed pi-web-access extension (verified working
 * against this pi version): `export default (pi: ExtensionAPI) => pi.registerTool({...})`.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { execFileSync } from "node:child_process";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

/** Resolve the harness-skill-pick executable: PATH first, then the nix-repo copy. */
function resolvePicker(): string {
	const fallback = join(homedir(), ".nix", "config", "agentic-harness", "bin", "harness-skill-pick");
	return existsSync(fallback) ? fallback : "harness-skill-pick";
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "pick_skills",
		label: "Pick Skills",
		description:
			"Given a task description, list the harness skills whose purpose best matches it, "
			+ "each with its memory/ files. Call this BEFORE starting a non-trivial task (or "
			+ "when spawning a subagent) to discover which SKILL.md files and memories to load, "
			+ "instead of guessing. Reads global (~/.agents/skills) and project (.agents/skills) skills.",
		promptSnippet:
			"Use pick_skills(task) to find which skills/memories apply before acting or delegating.",
		parameters: Type.Object({
			task: Type.String({
				description: "A short description or keywords of the task you are about to do.",
			}),
			all: Type.Optional(
				Type.Boolean({ description: "Show the full skill menu regardless of match score." }),
			),
		}),
		async execute(_toolCallId: string, params: { task: string; all?: boolean }) {
			try {
				const args = params.all ? ["-a", params.task ?? ""] : [params.task ?? ""];
				const out = execFileSync(resolvePicker(), args, {
					encoding: "utf-8",
					timeout: 5000,
					maxBuffer: 1024 * 1024,
				});
				const text = out.trim() || "(no matching skills found)";
				return { content: [{ type: "text", text }], details: { task: params.task } };
			} catch (err) {
				const msg = err instanceof Error ? err.message : String(err);
				return {
					content: [{ type: "text", text: `pick_skills failed: ${msg}` }],
					details: { error: msg },
				};
			}
		},
	});
}
