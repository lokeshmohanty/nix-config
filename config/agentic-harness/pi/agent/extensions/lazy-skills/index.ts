/**
 * lazy-skills — keep a pinned core of skills in the system prompt, park the rest.
 *
 * Skills are already progressive-disclosure (only name + description are in the
 * prompt, the body is read on demand), but the descriptions alone are expensive:
 * measured 2026-07-28, 14 global skills = 5.7 KB of a 12.4 KB system prompt (46%).
 *
 * Parking a skill only removes its <skill> entry from the <available_skills>
 * block. Nothing is unregistered: `/skill:<name>` still works for a parked skill,
 * and so does reading its SKILL.md directly. Parked names stay listed (without
 * descriptions) in a compact <parked_skills> element so the model can still tell
 * they exist and call `load_skills` to see what they do.
 *
 * IMPORTANT: never mutate `systemPromptOptions.skills`. Verified against pi
 * 0.82.0 — splicing that live array hangs pi (the process has to be killed).
 * Read it, then rewrite the prompt STRING via the before_agent_start return.
 *
 * Toggles are per-session by design: nothing is persisted, so a new session
 * always starts from PINNED.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getSettingsListTheme } from "@earendil-works/pi-coding-agent";
import { Container, type SettingItem, SettingsList, Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

/** Always in the prompt. Edit this list to change what a fresh session starts with. */
const PINNED = ["harness-ops", "no-mistakes", "verification-before-completion"];

const BLOCK = /<available_skills>[\s\S]*?<\/available_skills>/;
const ENTRY = /<skill>[\s\S]*?<\/skill>/g;
const NAME = /<name>([^<]*)<\/name>/;

interface SkillInfo {
	name: string;
	description?: string;
	filePath?: string;
}

export default function (pi: ExtensionAPI) {
	/** Names the user/model has turned on this session. Reset on every session_start. */
	let active = new Set(PINNED);

	/**
	 * Cache of the loaded skills. Needed because `getSystemPromptOptions()` only
	 * exists on the *command* context — a tool's execute ctx does not have it, so
	 * `load_skills` has nothing else to read. Refreshed every before_agent_start,
	 * which always runs before any tool call.
	 */
	let known: SkillInfo[] = [];

	/** Copy out of pi's live array — never hand the original around, never mutate it. */
	const allSkills = (source: any): SkillInfo[] => {
		const skills = source?.skills;
		return Array.isArray(skills) ? skills.map((s: any) => ({ ...s })) : [];
	};

	/** Freshest list available in this context, falling back to the cache. */
	const skillsFrom = (source: any): SkillInfo[] => {
		const fresh = allSkills(source);
		if (fresh.length > 0) known = fresh;
		return known;
	};

	/**
	 * Rewrite <available_skills> down to the active set and append a name-only
	 * index of what was parked. Returns undefined when there is nothing to change.
	 */
	const rewrite = (prompt: string): string | undefined => {
		const block = prompt.match(BLOCK)?.[0];
		if (!block) return undefined;

		const entries = block.match(ENTRY) ?? [];
		if (entries.length === 0) return undefined;

		const kept: string[] = [];
		const parked: string[] = [];
		for (const entry of entries) {
			const name = entry.match(NAME)?.[1]?.trim();
			if (!name) continue;
			if (active.has(name)) kept.push(entry);
			else parked.push(name);
		}
		if (parked.length === 0) return undefined;

		const indent = (s: string) => s.replace(/^/gm, "  ").trimStart();
		const keptBlock = kept.length
			? `<available_skills>\n  ${kept.map(indent).join("\n  ")}\n</available_skills>`
			: "<available_skills>\n</available_skills>";

		const parkedBlock =
			`<parked_skills names="${parked.join(", ")}">\n`
			+ "  These skills are installed but their descriptions are withheld to save context.\n"
			+ "  Call load_skills([\"<name>\", ...]) to see what one does before using it.\n"
			+ "  /skill:<name> also works directly on a parked skill.\n"
			+ "</parked_skills>";

		// Function replacement: a skill description containing `$&` or `$'` would
		// otherwise be expanded as a replacement pattern and corrupt the prompt.
		return prompt.replace(BLOCK, () => `${keptBlock}\n\n${parkedBlock}`);
	};

	// Reset to the pinned core on every new session — toggles never persist.
	pi.on("session_start", () => {
		active = new Set(PINNED);
	});

	// The only place the prompt is actually trimmed. Runs per user turn, and is
	// idempotent: event.systemPrompt is the base prompt each time.
	pi.on("before_agent_start", (event: any) => {
		skillsFrom(event.systemPromptOptions);
		const systemPrompt = rewrite(event.systemPrompt ?? "");
		return systemPrompt ? { systemPrompt } : undefined;
	});

	pi.registerTool({
		name: "load_skills",
		label: "Load Skills",
		description:
			"Reveal the description of one or more parked skills (listed in <parked_skills>) "
			+ "and keep them in the prompt for the rest of the session. Call this when a parked "
			+ "skill's name suggests it covers the task — the result tells you what it does and "
			+ "where its SKILL.md is, so you can read it in the same step.",
		promptSnippet:
			"Most skills are parked by name only. Call load_skills(names) to see what one does.",
		parameters: Type.Object({
			names: Type.Array(Type.String(), {
				description: "Skill names, exactly as listed in <parked_skills>.",
				minItems: 1,
			}),
		}),
		async execute(_toolCallId: string, params: { names: string[] }) {
			const skills = known;
			const byName = new Map(skills.map((s) => [s.name, s]));
			const found = (params.names ?? []).filter((n) => byName.has(n));
			const unknown = (params.names ?? []).filter((n) => !byName.has(n));

			for (const name of found) active.add(name);

			const detail = found
				.map((n) => {
					const s = byName.get(n)!;
					return `<skill>\n  <name>${n}</name>\n  <description>${s.description ?? ""}</description>\n  <location>${s.filePath ?? ""}</location>\n</skill>`;
				})
				.join("\n");
			const note = unknown.length
				? `\n\nNot found: ${unknown.join(", ")}. Available: ${skills.map((s) => s.name).join(", ")}.`
				: "";

			return {
				content: [
					{
						type: "text",
						text: found.length
							? `Loaded ${found.join(", ")}. Read the SKILL.md at <location> to use one.\n\n${detail}${note}`
							: `No matching skill.${note}`,
					},
				],
				details: { loaded: found, unknown },
			};
		},
	});

	/** Interactive on/off list over every loaded skill. Applies immediately. */
	const openToggleUI = async (ctx: any, skills: SkillInfo[]) => {
		await ctx.ui.custom((tui: any, theme: any, _kb: any, done: (v?: unknown) => void) => {
			const items: SettingItem[] = skills.map((s) => ({
				id: s.name,
				label: PINNED.includes(s.name) ? `${s.name} (pinned)` : s.name,
				currentValue: active.has(s.name) ? "on" : "off",
				values: ["on", "off"],
			}));

			const container = new Container();
			container.addChild(new Text(theme.fg("accent", theme.bold("Skills in Prompt")), 1, 1));

			const list = new SettingsList(
				items,
				Math.min(items.length + 2, 15),
				getSettingsListTheme(),
				(id: string, value: string) => {
					if (value === "on") active.add(id);
					else active.delete(id);
				},
				() => done(undefined),
				{ enableSearch: true },
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

		const on = skills.filter((s) => active.has(s.name)).length;
		ctx?.ui?.notify?.(`${on}/${skills.length} skills in prompt (applies from your next message).`, "info");
	};

	// /skills            -> toggle list (TUI) or status text
	// /skills a b        -> load those skills
	pi.registerCommand("skills", {
		description: "Toggle which skills are described in the system prompt",
		getArgumentCompletions: (prefix: string) =>
			known
				.map((s) => s.name)
				.filter((n) => n.startsWith(prefix))
				.map((n) => ({ value: n, label: active.has(n) ? `${n} — on` : `${n} — parked` })) as any,
		handler: async (args: string, ctx: any) => {
			const skills = skillsFrom(ctx.getSystemPromptOptions?.());
			if (skills.length === 0) {
				ctx?.ui?.notify?.("No skills loaded.", "warning");
				return;
			}

			const known = new Set(skills.map((s) => s.name));
			const requested = (args ?? "").split(/[\s,]+/).filter((n) => known.has(n));

			if (requested.length === 0) {
				if (ctx.mode === "tui") {
					await openToggleUI(ctx, skills);
					return;
				}
				const status = skills
					.map((s) => `  ${active.has(s.name) ? "on " : "off"} ${s.name}`)
					.join("\n");
				ctx?.ui?.notify?.(`Skills in prompt:\n${status}\n\nUsage: /skills <name...>`, "info");
				return;
			}

			for (const n of requested) active.add(n);
			ctx?.ui?.notify?.(`Loaded ${requested.join(", ")}.`, "info");
		},
	});
}
