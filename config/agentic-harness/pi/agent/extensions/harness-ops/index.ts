/**
 * harness-ops — run the project-harness audit/migration from inside pi.
 *
 *   /harness-ops                 usage + audit of the current repo
 *   /harness-ops audit [dir|all]  read-only drift report
 *   /harness-ops migrate [dir|all] apply the mechanical fixes
 *
 * Thin wrapper over `harness-init --audit/--migrate` so the logic has a single
 * source of truth (same reason pi-harness-delegate wraps harness-skill-pick).
 *
 * The report goes through pi.sendMessage({display:true}) rather than ui.notify:
 * it is multi-line, and --migrate deliberately refuses to rewrite mandating prose
 * it cannot fix safely, printing those lines instead. Putting the report in LLM
 * context is the point — the model can then make those edits by hand.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFileSync } from "node:child_process";
import { existsSync, readdirSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

/** Resolve harness-init: PATH first, then the nix-repo copy. */
function resolveInit(): string {
	const fallback = join(homedir(), ".nix", "config", "agentic-harness", "bin", "harness-init");
	return existsSync(fallback) ? fallback : "harness-init";
}

/** Roots swept by the `all` target: harnessed repos live at depth 1-2 under these. */
const ROOTS = ["Projects", "Documents/Research"];

function isRepo(p: string): boolean {
	return existsSync(join(p, "AGENTS.md")) || existsSync(join(p, "CLAUDE.md"));
}

function findRepos(): string[] {
	const found: string[] = [];
	const nix = join(homedir(), ".nix");
	if (isRepo(nix)) found.push(nix);
	for (const root of ROOTS) {
		const base = join(homedir(), root);
		if (!existsSync(base)) continue;
		for (const a of readdirSync(base)) {
			const pa = join(base, a);
			try {
				if (!statSync(pa).isDirectory()) continue;
			} catch {
				continue;
			}
			if (isRepo(pa)) found.push(pa);
			for (const b of readdirSync(pa)) {
				const pb = join(pa, b);
				try {
					if (!statSync(pb).isDirectory()) continue;
				} catch {
					continue;
				}
				if (isRepo(pb)) found.push(pb);
			}
		}
	}
	return found;
}

function run(flag: "--audit" | "--migrate", dir: string): string {
	try {
		return execFileSync(resolveInit(), [flag, dir], {
			encoding: "utf-8",
			timeout: 15000,
			maxBuffer: 1024 * 1024,
			stdio: ["ignore", "pipe", "pipe"],
		}).trim();
	} catch (err: any) {
		// harness-init prints prose it refuses to rewrite on stderr; surface both.
		const out = [err?.stdout, err?.stderr].filter(Boolean).join("\n").trim();
		return out || `harness-init ${flag} ${dir} failed: ${err?.message ?? String(err)}`;
	}
}

const USAGE = [
	"/harness-ops — project-harness contract (~/.agents/docs/project-template.md)",
	"",
	"  /harness-ops audit [dir|all]     read-only drift report",
	"  /harness-ops migrate [dir|all]   apply mechanical fixes only",
	"",
	"Checks: AGENTS.md mandating a STATUS.md read every session; a stray TODO.md;",
	"a missing '# TODO(user added)' inbox; an oversized STATUS.md.",
	"migrate merges TODO.md verbatim and relaxes the exact template sentence; any",
	"other mandating prose is printed for you to edit by hand, never regexed.",
].join("\n");

export default function (pi: ExtensionAPI) {
	pi.registerCommand("harness-ops", {
		description: "Audit or migrate project harness layout (audit|migrate [dir|all])",
		getArgumentCompletions: (prefix: string) =>
			[
				{ value: "audit", label: "audit — read-only drift report" },
				{ value: "migrate", label: "migrate — apply mechanical fixes" },
				{ value: "audit all", label: "audit all — sweep every harnessed repo" },
				{ value: "migrate all", label: "migrate all — fix every harnessed repo" },
			].filter((i) => i.value.startsWith(prefix)) as any,
		handler: async (args: string, ctx: any) => {
			const parts = (args ?? "").trim().split(/\s+/).filter(Boolean);
			const verb = parts[0] ?? "audit";
			const target = parts[1] ?? ".";

			if (verb !== "audit" && verb !== "migrate") {
				pi.sendMessage({ customType: "harness-ops", content: USAGE, display: true },
					{ triggerTurn: false });
				return;
			}

			const flag = verb === "audit" ? "--audit" : "--migrate";
			const dirs = target === "all" ? findRepos() : [target];

			if (dirs.length === 0) {
				pi.sendMessage(
					{ customType: "harness-ops", content: "harness-ops: no harnessed repos found.", display: true },
					{ triggerTurn: false },
				);
				return;
			}

			ctx?.ui?.notify?.(`harness-ops ${verb}: ${dirs.length} repo(s)…`, "info");
			const report = dirs.map((d) => run(flag, d)).join("\n");
			const header =
				verb === "migrate"
					? "harness-ops migrate — mechanical fixes applied. Any lines listed below as needing a hand edit are yours to fix now."
					: "harness-ops audit (read-only).";

			pi.sendMessage(
				{
					customType: "harness-ops",
					content: `${header}\n\n${report}`,
					display: true,
					details: { verb, dirs },
				},
				{ triggerTurn: false },
			);
		},
	});
}
