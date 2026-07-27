/**
 * lazy-tools — defer heavy pi packages until a task actually needs them.
 *
 * The packages stay installed and registered (so their tools remain callable),
 * but they are removed from the ACTIVE set at session start, which keeps their
 * schemas out of the system prompt. A single `load_tools` loader re-activates a
 * group on demand; pi applies the additive change before the next model request
 * (docs: extensions.md "Dynamic Tool Loading").
 *
 * API surface follows pi-harness-delegate/index.ts (verified against pi 0.82.0).
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

/** group -> { match: substring of tool sourceInfo.path, blurb: shown to the model } */
const GROUPS: Record<string, { match: string; blurb: string }> = {
	subagents: {
		match: "@tintinweb/pi-subagents",
		blurb: "delegate to explorer/implementer/reviewer/orchestrator subagents",
	},
	browser: {
		match: "pi-agent-browser-native",
		blurb: "drive a real browser: navigate, click, type, screenshot",
	},
	wiki: {
		match: "@zosmaai/pi-llm-wiki",
		blurb: "LLM wiki: search/ingest/capture durable notes and insights",
	},
	web: {
		match: "pi-web-access",
		blurb: "web search and fetching page content from URLs",
	},
	goal: {
		match: "pi-codex-goal",
		blurb: "read/create/update the persistent session goal",
	},
	memory: {
		match: "pi-observational-memory",
		blurb: "recall observations from earlier sessions",
	},
};

const GROUP_NAMES = Object.keys(GROUPS);

export default function (pi: ExtensionAPI) {
	/** Tool names belonging to a lazy group, resolved live from the registry. */
	const namesFor = (groups: string[]): string[] => {
		const matches = groups.map((g) => GROUPS[g]?.match).filter(Boolean) as string[];
		return pi
			.getAllTools()
			.filter((t: any) => matches.some((m) => (t.sourceInfo?.path ?? "").includes(m)))
			.map((t: any) => t.name);
	};

	// Park every lazy group once the session (and all packages) have loaded.
	pi.on("session_start", () => {
		const deferred = new Set(namesFor(GROUP_NAMES));
		if (deferred.size === 0) return;
		pi.setActiveTools(pi.getActiveTools().filter((n) => !deferred.has(n)));
	});

	const menu = GROUP_NAMES.map((g) => `${g} (${GROUPS[g].blurb})`).join("; ");

	pi.registerTool({
		name: "load_tools",
		label: "Load Tools",
		description:
			"Activate a group of tools that are installed but not loaded, then use them on the "
			+ `next step. Groups: ${menu}. `
			+ "Call this the moment a task needs one of these capabilities — without it those "
			+ "tools do not exist. Loading is additive and lasts for the rest of the session.",
		promptSnippet:
			`Heavy tools are deferred. Call load_tools(groups) to activate: ${GROUP_NAMES.join(", ")}.`,
		parameters: Type.Object({
			groups: Type.Array(Type.String({ enum: GROUP_NAMES }), {
				description: "Which tool groups to activate.",
				minItems: 1,
			}),
		}),
		async execute(_toolCallId: string, params: { groups: string[] }) {
			const requested = (params.groups ?? []).filter((g) => g in GROUPS);
			const unknown = (params.groups ?? []).filter((g) => !(g in GROUPS));
			if (requested.length === 0) {
				return {
					content: [
						{
							type: "text",
							text: `No known group requested. Available: ${GROUP_NAMES.join(", ")}.`,
						},
					],
					details: { unknown },
				};
			}
			const active = pi.getActiveTools();
			const added = namesFor(requested).filter((n) => !active.includes(n));
			// Must be purely additive — pi uses that as the deferred-load signal.
			pi.setActiveTools([...new Set([...active, ...added])]);
			const note = unknown.length ? ` (ignored unknown: ${unknown.join(", ")})` : "";
			return {
				content: [
					{
						type: "text",
						text: added.length
							? `Loaded ${requested.join(", ")} — now available: ${added.join(", ")}.${note}`
							: `${requested.join(", ")} already loaded.${note}`,
					},
				],
				details: { groups: requested, added },
			};
		},
	});

	// Manual escape hatch: /load-tools browser wiki   (no args = show status)
	// Output goes through ctx.ui.notify — pi does not render a handler's return value.
	pi.registerCommand("load-tools", {
		description: "Activate deferred tool groups: " + GROUP_NAMES.join(", "),
		getArgumentCompletions: (prefix: string) =>
			GROUP_NAMES.filter((g) => g.startsWith(prefix)).map((g) => ({
				value: g,
				label: `${g} — ${GROUPS[g].blurb}`,
			})) as any,
		handler: async (args: string, ctx: any) => {
			const active = pi.getActiveTools();
			const requested = (args ?? "").split(/[\s,]+/).filter((g) => g in GROUPS);
			if (requested.length === 0) {
				const status = GROUP_NAMES.map((g) => {
					const names = namesFor([g]);
					const on = names.length > 0 && names.every((n) => active.includes(n));
					return `  ${on ? "on " : "off"} ${g} — ${GROUPS[g].blurb}`;
				}).join("\n");
				ctx?.ui?.notify?.(
					`Deferred tool groups:\n${status}\n\nUsage: /load-tools <group...>`,
					"info",
				);
				return;
			}
			const added = namesFor(requested).filter((n) => !active.includes(n));
			pi.setActiveTools([...new Set([...active, ...added])]);
			ctx?.ui?.notify?.(
				added.length
					? `Loaded ${requested.join(", ")}: ${added.join(", ")}`
					: `${requested.join(", ")} already loaded.`,
				"info",
			);
		},
	});
}
