/**
 * lazy-tools — defer heavy pi packages until a task actually needs them.
 *
 * The packages stay installed and registered (so their tools remain callable),
 * but they are removed from the ACTIVE set at session start, which keeps their
 * schemas out of the system prompt. A single `load_tools` loader re-activates a
 * group on demand; pi applies the additive change before the next model request
 * (docs: extensions.md "Dynamic Tool Loading").
 *
 * `/load-tools` with no arguments opens a SettingsList toggle in the TUI, which
 * can also turn groups back OFF. Removal is only forbidden inside a loader tool's
 * execution (that is what pi uses as the deferred-load signal) — from a command
 * handler an arbitrary active set is fine, same as the session_start park below.
 *
 * Toggles are per-session by design: session_start always re-parks every group,
 * so a new session is guaranteed to start lean.
 *
 * API surface follows pi-harness-delegate/index.ts (verified against pi 0.82.0).
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getSettingsListTheme } from "@earendil-works/pi-coding-agent";
import { Container, type SettingItem, SettingsList, Text } from "@earendil-works/pi-tui";
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

	/** A group is on when it owns at least one tool and all of them are active. */
	const isOn = (group: string, active: string[]): boolean => {
		const names = namesFor([group]);
		return names.length > 0 && names.every((n) => active.includes(n));
	};

	/**
	 * Set the active set so exactly `on` is loaded. Non-lazy tools are untouched.
	 * Only safe outside loader-tool execution — see the header note.
	 */
	const applyGroups = (on: Iterable<string>) => {
		const lazy = new Set(namesFor(GROUP_NAMES));
		const wanted = new Set(namesFor([...on]));
		const base = pi.getActiveTools().filter((n) => !lazy.has(n));
		pi.setActiveTools([...new Set([...base, ...wanted])]);
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

	/** Interactive on/off list over the groups. Applies each change immediately. */
	const openToggleUI = async (ctx: any) => {
		const on = new Set(GROUP_NAMES.filter((g) => isOn(g, pi.getActiveTools())));

		await ctx.ui.custom((tui: any, theme: any, _kb: any, done: (v?: unknown) => void) => {
			const items: SettingItem[] = GROUP_NAMES.map((g) => ({
				id: g,
				label: `${g} — ${GROUPS[g].blurb}`,
				currentValue: on.has(g) ? "on" : "off",
				values: ["on", "off"],
			}));

			const container = new Container();
			container.addChild(new Text(theme.fg("accent", theme.bold("Deferred Tool Groups")), 1, 1));

			const list = new SettingsList(
				items,
				Math.min(items.length + 2, 15),
				getSettingsListTheme(),
				(id: string, value: string) => {
					if (value === "on") on.add(id);
					else on.delete(id);
					applyGroups(on);
				},
				() => done(undefined),
			);
			container.addChild(list);

			return {
				render: (width: number) => container.render(width),
				invalidate: () => container.invalidate(),
				handleInput: (data: string) => {
					list.handleInput?.(data);
					tui.requestRender();
				},
			};
		});

		const loaded = GROUP_NAMES.filter((g) => on.has(g));
		ctx?.ui?.notify?.(
			loaded.length ? `Loaded groups: ${loaded.join(", ")}` : "All tool groups parked.",
			"info",
		);
	};

	// Manual escape hatch: /load-tools browser wiki
	// No args: toggle list in the TUI, plain status text everywhere else.
	// Output goes through ctx.ui.notify — pi does not render a handler's return value.
	pi.registerCommand("load-tools", {
		description: "Toggle deferred tool groups: " + GROUP_NAMES.join(", "),
		getArgumentCompletions: (prefix: string) =>
			GROUP_NAMES.filter((g) => g.startsWith(prefix)).map((g) => ({
				value: g,
				label: `${g} — ${GROUPS[g].blurb}`,
			})) as any,
		handler: async (args: string, ctx: any) => {
			const requested = (args ?? "").split(/[\s,]+/).filter((g) => g in GROUPS);

			if (requested.length === 0) {
				if (ctx.mode === "tui") {
					await openToggleUI(ctx);
					return;
				}
				const active = pi.getActiveTools();
				const status = GROUP_NAMES.map(
					(g) => `  ${isOn(g, active) ? "on " : "off"} ${g} — ${GROUPS[g].blurb}`,
				).join("\n");
				ctx?.ui?.notify?.(
					`Deferred tool groups:\n${status}\n\nUsage: /load-tools <group...>`,
					"info",
				);
				return;
			}

			const active = pi.getActiveTools();
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
