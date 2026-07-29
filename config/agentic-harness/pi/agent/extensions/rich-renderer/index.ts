// Fork of pi-rich-renderer 0.1.0 (https://github.com/dbydd/pi-rich-renderer, MIT).
//
// Vendored 2026-07-28 because upstream has two defects, both reproduced against
// pi 0.82.0 + ghostty 1.3.1:
//
//   FIX 1 (geometry): upstream passed maxWidthCells AND maxHeightCells to pi-tui's
//   Image, so calculateImageCellSize() picked scale = min(widthScale, heightScale)
//   and then rounded rows UP via ceil(). For wide, short formula images that ceil
//   adds up to a whole extra cell, and because a kitty escape carrying both c= and
//   r= is scaled to FILL that box without preserving aspect, every inline formula
//   came out vertically stretched — a 995x41px formula landed in c=40,r=1 and
//   rendered as an illegible hairline. We now derive rows FIRST from the natural
//   height, then compute columns from the true aspect, so the c x r box matches the
//   image's own proportions.
//
//   FIX 2 (matcher): upstream's `\$[^\n$]+\$` and `\$\$[\s\S]*?\$\$` matched things
//   that are not math. A nix interpolation in a config file
//   ("${config.home.homeDirectory}/.gemini/...") was rendered as a LaTeX formula,
//   and an unbalanced `$$` swallowed whole paragraphs of prose into a single
//   "formula" — deleting the text from the transcript. Math candidates now have to
//   pass looksLikeMath(), inline code spans are protected, and `${` never opens
//   inline math. The guard only ever REJECTS, so the worst case is that a genuine
//   formula stays as plain LaTeX source.
//
//   FIX 5 (placement, 2026-07-29): a formula sharing a line with prose was still
//   emitted as a raw escape wrapped in bare newlines. pi-tui's Markdown treats a
//   single newline as a soft break, so the escape and the rest of the sentence came
//   back as ONE line (verified against pi-tui 0.82.1) — the terminal drew the image
//   at the cursor, which encodeKitty() deliberately does not advance, and then
//   printed the sentence on top of it. Block escapes are now separated by blank
//   lines, and "block" means the formula owns its whole line; everything else flows
//   as Unicode placeholders, which occupy real cells and cannot be overprinted.
//
//   FIX 6 (row reservation, 2026-07-29): the blank lines that reserve an image's
//   height do not survive markdown, which collapses consecutive blanks — so a tall
//   block was drawn over by the next paragraph. Harmless while imageScale defaulted
//   to 0.5 and blocks were two rows; obvious at 1.0. reserveRows() emits lines that
//   are non-empty (so markdown keeps them) but zero-width (so pi-tui counts them).
//
//   FIX 7 (image ids, 2026-07-29): placeholder ids counted from 1 in every process,
//   so a second pi session in the same window overwrote the first session's images
//   — a table cell was seen changing into a formula from the next run. Seeded
//   randomly instead.
//
//   FIX 9 (inline size, 2026-07-29): inline math is placed on ONE cell row, so the
//   image's own pixel height alone decides how big the glyphs come out — a tight
//   crop of `x` (13px tall) was blown up 2x, while a bracketed fraction or an
//   integral with limits (55-87px) was shrunk to a third of the text size and
//   became unreadable. Two changes: inline formulas render in TEXT style behind a
//   `\strut`, which pins every image to the same ~1-baselineskip reference (so they
//   all come out at roughly terminal-text size, and \int/\sum/\frac stop growing
//   full-height bars and stacked limits); and anything still too tall for one row —
//   matrices, cases — gets its own line instead of being squeezed.
//
// Everything else is upstream's design and is deliberately unchanged: rendering
// shells out to latex + dvipng, PNGs are cached under ~/.pi/cache/rich-renderer,
// and the `context` hook restores the original markdown so the model never sees
// the rendered form.

import { execFile } from "node:child_process";
import { createHash } from "node:crypto";
import { existsSync } from "node:fs";
import { mkdir, mkdtemp, readdir, readFile, rm, stat, writeFile } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";
// `import type` (not `import { type ... }`) so every transpiler erases the whole
// statement: @earendil-works/pi-coding-agent is not installed in pi/agent/npm.
import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import {
	allocateImageId,
	encodeKitty,
	getCapabilities,
	getCellDimensions,
	getImageDimensions,
	Image,
	setCapabilities,
	Text,
	type Component,
} from "@earendil-works/pi-tui";

const execFileAsync = promisify(execFile);
const ORIGINAL_CONTENT_FIELD = "__richRendererOriginalContent";
const CACHE_DIR = join(homedir(), ".pi", "cache", "rich-renderer");
const GLOBAL_SETTINGS_PATH = join(homedir(), ".pi", "agent", "settings.json");
const PROJECT_SETTINGS_PATH = join(process.cwd(), ".pi", "settings.json");
const TIMEOUT_MS = Number(process.env.PI_RICH_RENDER_TIMEOUT_MS ?? 15000);
const MAX_BUFFER = 16 * 1024 * 1024;
const PNG_MIME = "image/png";
const LATEX_DPI = Number(process.env.PI_RICH_RENDER_LATEX_DPI ?? 180);
/**
 * 1.0 renders a display block at its natural size: one image pixel row per cell
 * pixel row at LATEX_DPI. Below that the glyphs are downsampled and thin strokes
 * (integral signs, fraction bars, subscripts) break up.
 */
const DEFAULT_IMAGE_SCALE = 1.0;
/** Left margin for a display block. Empty: blocks align with the prose. */
const BLOCK_INDENT = "";
const DEFAULT_CACHE_TTL_MS = 7 * 24 * 60 * 60 * 1000;
const MAX_ROWS = 40;
const MAX_COLUMNS = 100;
/**
 * FIX 9: height of the `\strut` every inline formula carries, in pixels at
 * LATEX_DPI — one `\baselineskip` of a 12pt article (14.5pt). Inline images are
 * scaled to exactly one cell row, so this is the reference that makes them all
 * come out the same size on screen no matter what the formula contains.
 */
const INLINE_STRUT_PX = (14.5 / 72) * LATEX_DPI;
/**
 * How many struts — near enough, how many text rows — an inline formula may
 * naturally stand before it is given its own line instead of being squeezed into
 * one. Measured at LATEX_DPI: a plain formula, a simple fraction and a `\sqrt`
 * all come out at 1.0 (the strut dominates), `\int_0^1 f(x)dx` at 1.13, a
 * `\left(\frac{p}{q}\right)` at 1.5, a 2x2 matrix at 2.0. The default keeps
 * everything but genuinely two-dimensional constructs in the text flow; lower it
 * (`richRenderer.inlineMaxRows: 1.3`) to break bracketed fractions out as well.
 */
const DEFAULT_INLINE_MAX_ROWS = 1.7;
/** Longest span we will ever hand to latex. Anything longer is swallowed prose. */
const MAX_TEX_CHARS = 400;

type TextContent = { type: "text"; text: string; [key: string]: unknown };
type AssistantMessage = {
	role: "assistant";
	content: Array<TextContent | Record<string, unknown>>;
	stopReason?: string;
	[key: string]: unknown;
};

type RenderSegment =
	| { type: "markdown"; markdown: string }
	// `blocked`: the segment sits inside a list item or table row, where a raw
	// image escape gets word-wrapped and spills base64 (FIX 3). Such a segment can
	// never be given its own line, however tall it renders.
	| { type: "image"; kind: "math" | "dot"; source: string; inline?: boolean; blocked?: boolean; png?: string; error?: string };

type LatexBlock = { tex: string; wrapDisplay: boolean };

type RGB = { r: number; g: number; b: number };

type RendererConfig = {
	imageScale: number;
	inlineMaxRows: number;
	cacheTtlMs: number;
	inlinePlaceholders: boolean;
	imageProtocol?: "kitty" | "iterm2";
};

/** `/math off` puts the transcript back to LaTeX source, e.g. to copy a formula. */
let renderingEnabled = true;

export default function (pi: ExtensionAPI) {
	void cleanupCache();
	void applyImageProtocolOverride();

	pi.registerCommand("math", {
		description: "Toggle LaTeX/diagram rendering for this session (on|off)",
		handler: async (args: string, ctx: any) => {
			const argument = (args ?? "").trim().toLowerCase();
			renderingEnabled = argument === "on" ? true : argument === "off" ? false : !renderingEnabled;
			ctx.ui.notify(
				renderingEnabled
					? "rich-renderer: rendering formulas and diagrams as images"
					: "rich-renderer: rendering off — replies keep their LaTeX source",
				"info",
			);
		},
	});

	// Streaming pre-warm: formulas are rendered when the message finishes, so a
	// cold cache stalls the whole reply behind latex (~0.4s each). The text is
	// already streaming in, and a formula is complete as soon as its closing
	// delimiter arrives — so render it then. By message_end the cache is warm and
	// the swap is instant.
	pi.on("message_update" as any, (event: any, ctx: any) => {
		if (!renderingEnabled) return;
		void prewarm(messageText(event.message), ctx?.ui?.theme);
	});

	pi.on("context", (event: any) => {
		const messages = event.messages.map((message: any) => {
			if (message?.role === "assistant" && Array.isArray(message?.[ORIGINAL_CONTENT_FIELD])) {
				return { ...message, content: message[ORIGINAL_CONTENT_FIELD] };
			}
			return message;
		});
		return { messages };
	});

	pi.on("message_end" as any, async (event: any, ctx: any) => {
		const message = event.message as unknown as AssistantMessage;
		if (!renderingEnabled) return;
		if (message.role !== "assistant") return;
		if (message.stopReason && !["stop", "length"].includes(message.stopReason)) return;
		if ((message as any)[ORIGINAL_CONTENT_FIELD]) return;

		const markdown = messageText(message);
		if (!markdown || !shouldRender(markdown)) return;

		const [segments, config] = await Promise.all([buildSegments(markdown, ctx.ui.theme), getConfig()]);
		if (!segments.some((segment) => segment.type === "image" && segment.png)) return;

		return {
			message: {
				...message,
				[ORIGINAL_CONTENT_FIELD]: message.content,
				content: [{ type: "text", text: renderSegmentsAsText(segments, ctx.ui.theme, terminalWidth(ctx), config) }],
			},
		};
	});
}

/**
 * Honour `richRenderer.imageProtocol`. This overrides pi's env-var detection for
 * the whole TUI, not just this extension — which is the point: if the terminal
 * can draw images, pi should use them everywhere.
 */
async function applyImageProtocolOverride(): Promise<void> {
	const { imageProtocol } = await getConfig();
	if (!imageProtocol) return;
	const caps = getCapabilities();
	if (caps.images === imageProtocol) return;
	setCapabilities({ ...caps, images: imageProtocol });
}

async function cleanupCache(): Promise<void> {
	const { cacheTtlMs } = await getConfig();
	if (cacheTtlMs <= 0) return;
	const now = Date.now();
	await mkdir(CACHE_DIR, { recursive: true });
	for (const name of await readdir(CACHE_DIR).catch(() => [])) {
		if (!name.endsWith(".png")) continue;
		const path = join(CACHE_DIR, name);
		const info = await stat(path).catch(() => undefined);
		if (info && now - info.mtimeMs > cacheTtlMs) await rm(path, { force: true });
	}
}

async function getConfig(): Promise<RendererConfig> {
	const [globalSettings, projectSettings] = await Promise.all([
		readSettings(GLOBAL_SETTINGS_PATH),
		readSettings(PROJECT_SETTINGS_PATH),
	]);
	const config = { ...globalSettings?.richRenderer, ...projectSettings?.richRenderer };
	return {
		imageScale: readPositiveNumber(config.imageScale, DEFAULT_IMAGE_SCALE),
		inlineMaxRows: readPositiveNumber(config.inlineMaxRows, DEFAULT_INLINE_MAX_ROWS),
		cacheTtlMs: readNonNegativeNumber(config.cacheTtlMs ?? config.cacheTtl, DEFAULT_CACHE_TTL_MS),
		// Set false if the terminal speaks the kitty protocol but not Unicode
		// placeholders: inline math then stays as readable LaTeX source rather
		// than rendering as stray accented dots.
		inlinePlaceholders: config.inlinePlaceholders !== false,
		// Force a graphics protocol when the terminal supports one but does not
		// advertise it. pi detects images purely from environment variables
		// (KITTY_WINDOW_ID, TERM_PROGRAM, GHOSTTY_RESOURCES_DIR, TERM); launch pi
		// somewhere those are not set — a plain TERM=xterm-256color, a bare
		// login shell, some multiplexers — and it reports no image support, so
		// every formula degrades to "[Image: image/png WxH]".
		imageProtocol: config.imageProtocol === "kitty" || config.imageProtocol === "iterm2" ? config.imageProtocol : undefined,
	};
}

async function readSettings(path: string): Promise<any> {
	try {
		return JSON.parse(await readFile(path, "utf8"));
	} catch {
		return undefined;
	}
}

function readPositiveNumber(value: unknown, fallback: number): number {
	const number = Number(value);
	return Number.isFinite(number) && number > 0 ? number : fallback;
}

function readNonNegativeNumber(value: unknown, fallback: number): number {
	const number = Number(value);
	return Number.isFinite(number) && number >= 0 ? number : fallback;
}

function renderSegmentsAsText(segments: RenderSegment[], theme: Theme, width: number, config: RendererConfig): string {
	const { imageScale } = config;
	const transmits: string[] = [];
	const usePlaceholders = config.inlinePlaceholders && getCapabilities().images === "kitty";
	// FIX 5: one transmission per distinct PNG, not per occurrence. A message that
	// repeats the same formula six times used to send six copies of the base64.
	const transmitted = new Map<string, { id: number; columns: number }>();

	// FIX 5: a display block needs BLANK lines around it, not bare newlines.
	// pi-tui's Markdown treats a single newline as a soft break and keeps the
	// escape in the same paragraph as the surrounding prose — verified: the escape
	// and the following sentence came back as one line, so the terminal drew the
	// image and then printed the sentence over it.
	//
	// Only the first line carries the escape; the rest are spacer rows reserving the
	// image's height. pi-tui's isImageLine() matches the escape anywhere in the
	// line, so the indent does not cost the line its image handling.
	const asBlock = (segment: Extract<RenderSegment, { type: "image" }>) => {
		const lines = new RenderedImage(segment, theme, imageScale).render(width - BLOCK_INDENT.length);
		return `\n\n${BLOCK_INDENT}${lines[0]}\n${reserveRows(lines.length - 1)}\n\n`;
	};

	const body = segments.map((segment) => {
		if (segment.type === "markdown") return segment.markdown;
		if (!segment.png) return segment.source;

		if (segment.inline) {
			// Flowing text — mid-sentence, or inside a list item or table cell. A raw
			// escape here is drawn at the cursor and then overprinted by whatever text
			// follows on the same line (and inside a list it also spills base64), so
			// place the image with Unicode placeholders, which occupy real cells.
			if (!usePlaceholders) return segment.source;
			const cached = transmitted.get(segment.png);
			if (cached) return encodePlaceholderRow(cached.id, 0, cached.columns);
			const dimensions = getImageDimensions(segment.png, PNG_MIME);
			if (!dimensions) return segment.source;
			// FIX 9: one cell row cannot hold a two-dimensional formula. Squeezing it
			// there is what made inline matrices and bracketed fractions unreadable, so
			// give it a line of its own — or, where a raw escape would spill base64,
			// leave the LaTeX source, which at least reads.
			if (dimensions.heightPx > config.inlineMaxRows * INLINE_STRUT_PX) return segment.blocked ? segment.source : asBlock(segment);
			const id = allocatePlaceholderId();
			const columns = inlineColumns(dimensions.widthPx, dimensions.heightPx, getCellDimensions());
			transmitted.set(segment.png, { id, columns });
			transmits.push(encodeTransmit(segment.png, id, columns, 1));
			return encodePlaceholderRow(id, 0, columns);
		}

		return asBlock(segment);
	}).join("").trim();

	// Transmissions draw nothing, but must reach the terminal before the
	// placeholders that reference them. They sit alone in a leading paragraph,
	// which pi-tui recognises as an image line and passes through unwrapped.
	return transmits.length ? `${transmits.join("")}\n\n${body}` : body;
}

/**
 * FIX 6: markdown collapses consecutive blank lines, so the blank spacer rows an
 * image needs to reserve its height never survive to the renderer — a five-row
 * formula got one blank line and the next paragraph was drawn on top of it. This
 * was invisible while `imageScale` defaulted to 0.5 and every block was two rows.
 *
 * pi-tui's getKittyImageReservedRows() counts following lines of ZERO VISIBLE
 * WIDTH, which a bare colour reset satisfies while still being a non-empty line
 * that markdown will not collapse. The unit is blank-then-reset: consecutive
 * reset lines are soft-joined back into one line, so they must stay separated.
 * Measured against pi-tui 0.82.1 for 1..20 rows, this reserves the full height
 * every time, overshooting by at most two rows of harmless whitespace.
 */
export function reserveRows(rows: number): string {
	return "\n\n\x1b[0m".repeat(Math.ceil(Math.max(0, rows) / 2));
}

function terminalWidth(ctx: any): number {
	return Number(ctx?.ui?.terminal?.columns ?? ctx?.ui?.terminal?.width ?? process.stdout.columns ?? 100);
}

// --- FIX 2: math detection -------------------------------------------------

/**
 * Reject candidates that the delimiter regex matched but which are plainly not
 * formulas. Rejection-only by design: a false negative degrades to plain LaTeX
 * source in the transcript, whereas a false positive silently DELETES prose.
 */
export function looksLikeMath(tex: string): boolean {
	const body = tex.trim();
	if (!body) return false;
	// Swallowed prose: an unbalanced `$$` pairs with a later one across paragraphs.
	if (body.length > MAX_TEX_CHARS) return false;
	if (/\n\s*\n/.test(body)) return false;
	// `${...}` is nix/shell interpolation, never math.
	if (/\$\{/.test(body)) return false;
	const hasLatex = /\\[a-zA-Z]+|[\^_]|\\\\/.test(body);
	// Paths and filenames: "config.home.homeDirectory/.gemini/.../AGENTS.md".
	if (body.includes("/") && !hasLatex) return false;
	if (/\b[\w-]+\.(md|ts|js|mjs|nix|json|ya?ml|py|sh|toml|lock)\b/i.test(body) && !hasLatex) return false;
	// Running prose: a stray `$$` pairing with a later one, or "$5 and $10".
	// Four plain words with no LaTeX command is a sentence, not a formula.
	const plainWords = body.split(/\s+/).filter((word) => /^[A-Za-z][a-z]*[.,;:]?$/.test(word));
	if (plainWords.length >= 4 && !/\\[a-zA-Z]+/.test(body)) return false;
	// Positive requirement: something in here has to actually read as maths.
	// Without this, "$5 and $10 for two items" renders "5 and " as a formula.
	return MATH_TOKEN.test(body) || BARE_SYMBOL.test(body);
}

/** Operators/structure that only appear in maths, not in running prose. */
const MATH_TOKEN = /[\\^_=<>+\-*{}|]/;
/** A lone symbol such as `$x$` or `$k2$`, which carries no operator. */
const BARE_SYMBOL = /^[A-Za-z][A-Za-z0-9]?$/;

/**
 * FIX 3: character ranges where a raw image escape must never be placed.
 *
 * pi-tui's Markdown renders a top-level image line verbatim, but `renderList()`
 * re-wraps item content to `itemWidth` first — which splits the escape's single
 * enormous base64 "word" across several lines. Only the first keeps the \x1b_G
 * prefix, so the terminal draws a partial image and prints the remaining chunks
 * as visible base64. Table cells survive without spilling but blow out the row
 * layout.
 *
 * Math here is rendered with Unicode placeholders instead (see FIX 4), which
 * carry no base64 in the wrapped text and so cannot spill.
 */
function structuredRanges(markdown: string): Array<[number, number]> {
	const ranges: Array<[number, number]> = [];
	let offset = 0;
	let inList = false;
	for (const line of markdown.split("\n")) {
		const start = offset;
		const end = offset + line.length;
		offset = end + 1;

		const isBlank = !line.trim();
		const isListItem = /^\s*([-*+]|\d+[.)])\s/.test(line);
		const isTableRow = /^\s*\|/.test(line);
		const isIndented = /^\s+\S/.test(line);

		if (isListItem) inList = true;
		else if (!isBlank && !isIndented) inList = false;

		if (isListItem || isTableRow || (inList && !isBlank)) ranges.push([start, end]);
	}
	return ranges;
}

/**
 * FIX 5: a formula may be rendered as a real image escape only when it owns its
 * line. Anything sharing a line with text must flow inline as placeholders.
 *
 * An escape is drawn at the cursor and does not advance it (moveCursor: false),
 * so text emitted afterwards on the same line lands on top of the image. Bare
 * newlines around the escape do not save it: markdown joins a paragraph's soft
 * breaks back into one line before the terminal ever sees it.
 */
/**
 * `$$…$$`, `\[…\]` and the equation environments are *display* math: they mean
 * "put this on its own line", so they are rendered as blocks even when the model
 * writes them mid-sentence. Squeezing an integral with limits into the one cell
 * row that inline placement allows makes it illegible.
 */
export function isDisplayDelimited(source: string): boolean {
	const trimmed = source.trim();
	return trimmed.startsWith("$$") || trimmed.startsWith("\\[") || trimmed.startsWith("\\begin{");
}

export function isStandaloneMath(markdown: string, start: number, end: number): boolean {
	const lineStart = markdown.lastIndexOf("\n", Math.max(0, start - 1)) + 1;
	const nextBreak = markdown.indexOf("\n", end);
	const lineEnd = nextBreak === -1 ? markdown.length : nextBreak;
	return !markdown.slice(lineStart, start).trim() && !markdown.slice(end, lineEnd).trim();
}

function shouldRender(markdown: string): boolean {
	return splitMarkdown(markdown).some((segment) => segment.type === "image");
}

/** Concurrent latex runs. Each render has its own temp dir, so they cannot clash. */
const RENDER_CONCURRENCY = 4;
/** Re-scan a streaming message only after this much new text has arrived. */
const PREWARM_STEP = 48;

function messageText(message: any): string {
	return (message?.content ?? [])
		.filter((part: any) => part?.type === "text" && typeof part.text === "string")
		.map((part: any) => part.text)
		.join("\n\n")
		.trim();
}

/**
 * Render every *complete* formula in a partially streamed message, so the cache
 * is warm by the time message_end swaps the content. Fire-and-forget: failures
 * are irrelevant here, message_end renders again (and hits the cache) anyway.
 *
 * `message_update` fires per token, so this is throttled by text length and
 * remembers what it has already started — otherwise a long reply would rescan
 * itself hundreds of times.
 */
const prewarmed = new Set<string>();
let prewarmMark = 0;

async function prewarm(markdown: string, theme?: Theme): Promise<void> {
	// A shorter text than last time means a new message started; without this the
	// throttle would stay parked at the previous message's length.
	if (markdown.length < prewarmMark) prewarmMark = 0;
	if (markdown.length < prewarmMark + PREWARM_STEP) return;
	prewarmMark = markdown.length;
	// The theme is part of the cache key (it sets the glyph colour), so prewarming
	// with anything else would fill the cache with entries message_end never reads.
	const foreground = dvipngForeground(theme);
	for (const segment of splitMarkdown(markdown)) {
		if (segment.type !== "image") continue;
		const key = renderKey(segment);
		if (prewarmed.has(key)) continue;
		prewarmed.add(key);
		void renderSource(segment, foreground).catch(() => undefined);
	}
}

async function buildSegments(markdown: string, theme: Theme): Promise<RenderSegment[]> {
	const raw = splitMarkdown(markdown);
	const foreground = dvipngForeground(theme);
	const out: RenderSegment[] = [];

	// FIX 8: render the formulas up front, deduplicated and in parallel. This used
	// to be a serial await inside the loop: a real "Maxwell's equations" reply had
	// 22 formulas, and at ~0.5s per latex+dvipng pair that is a ten-second stall
	// before any of the message appears.
	const pending = new Map<string, Extract<RenderSegment, { type: "image" }>>();
	for (const segment of raw) if (segment.type === "image") pending.set(renderKey(segment), segment);
	const wanted = [...pending.entries()];
	const renders = new Map<string, { png?: string; error?: string }>();
	for (let i = 0; i < wanted.length; i += RENDER_CONCURRENCY) {
		const batch = wanted.slice(i, i + RENDER_CONCURRENCY);
		const results = await Promise.all(batch.map(([, segment]) => renderSource(segment, foreground)));
		batch.forEach(([key], index) => renders.set(key, results[index]));
	}

	for (const segment of raw) {
		if (segment.type === "markdown") {
			const previous = out[out.length - 1];
			if (previous?.type === "markdown") previous.markdown += segment.markdown;
			else out.push(segment);
			continue;
		}
		out.push({ ...segment, ...renders.get(renderKey(segment)) });
	}

	return out.filter((segment) => segment.type !== "markdown" || segment.markdown.trim().length > 0);
}

export function splitMarkdown(markdown: string): RenderSegment[] {
	const segments: RenderSegment[] = [];
	let cursor = 0;
	// Order matters: fenced blocks and inline code spans are consumed BEFORE any
	// math alternative so that `$foo$` inside code is never treated as a formula.
	// `(?!\{)` stops `${...}` from opening inline math.
	const regex =
		/(```[\s\S]*?```|~~~[\s\S]*?~~~|`[^`\n]+`|\$\$[\s\S]*?\$\$|\\\[[\s\S]*?\\\]|\\begin\{(?:equation|align|gather|multline|flalign|alignat)\*?\}[\s\S]*?\\end\{(?:equation|align|gather|multline|flalign|alignat)\*?\}|(?<!\\)\$(?!\{)[^\n$]+(?<!\\)\$)/g;
	let match: RegExpExecArray | null;
	const blockedRanges = structuredRanges(markdown);
	const isBlocked = (index: number) => blockedRanges.some(([start, end]) => index >= start && index < end);

	const pushMarkdown = (text: string) => {
		if (!text) return;
		const previous = segments[segments.length - 1];
		if (previous?.type === "markdown") previous.markdown += text;
		else segments.push({ type: "markdown", markdown: text });
	};

	while ((match = regex.exec(markdown))) {
		if (match.index > cursor) pushMarkdown(markdown.slice(cursor, match.index));
		const source = match[0];
		const isCode = source.startsWith("```") || source.startsWith("~~~") || source.startsWith("`");
		const graph = isCode ? parseGraphFence(source) : undefined;
		if (graph) segments.push({ type: "image", kind: "dot", source: graph, inline: false });
		else if (isCode || !looksLikeMath(parseLatexBlock(source).tex)) pushMarkdown(source);
		else {
			// Block rendering needs a formula that owns its line — or display
			// delimiters, which claim one — and a line that is not inside a list or
			// table, where renderList() re-wraps the content and spills base64.
			const wantsBlock = isDisplayDelimited(source) || isStandaloneMath(markdown, match.index, match.index + source.length);
			const blocked = isBlocked(match.index);
			segments.push({ type: "image", kind: "math", source, inline: !(wantsBlock && !blocked), blocked });
		}
		cursor = match.index + source.length;
	}
	if (cursor < markdown.length) pushMarkdown(markdown.slice(cursor));
	return segments;
}

/**
 * A ```dot / ```graphviz fence, unwrapped to its graph source. Mermaid would fit
 * here too, but `mmdc` pulls in a headless browser, so only graphviz is wired up.
 */
export function parseGraphFence(source: string): string | undefined {
	const match = /^(?:```|~~~)[ \t]*(dot|graphviz)[ \t]*\r?\n([\s\S]*?)(?:```|~~~)$/.exec(source.trim());
	const body = match?.[2]?.trim();
	return body ? body : undefined;
}

function renderSource(segment: Extract<RenderSegment, { type: "image" }>, foreground: string): Promise<{ png?: string; error?: string }> {
	return segment.kind === "dot" ? renderDot(segment.source, foreground) : renderLatex(segment.source, foreground, !!segment.inline);
}

/**
 * Cache/dedup key for a segment. FIX 9 made the same source render differently
 * inline (text style, strutted) and as a block (display style), so placement has
 * to be part of the key — otherwise a formula that appears both ways in one
 * message gets whichever image was rendered first.
 */
function renderKey(segment: Extract<RenderSegment, { type: "image" }>): string {
	return `${segment.kind}\0${segment.inline ? "inline" : "block"}\0${segment.source}`;
}

/**
 * Graphviz honours no theme, so the ink is forced to the terminal's text colour
 * on a transparent background — otherwise the default black is invisible on a
 * dark theme.
 */
async function renderDot(source: string, foreground: string): Promise<{ png?: string; error?: string }> {
	const ink = rgbToHex(parseDvipngForeground(foreground));
	const key = createHash("sha256").update("dot-v1\0").update(JSON.stringify({ source, ink, dpi: LATEX_DPI })).digest("hex");
	const pngPath = join(CACHE_DIR, `${key}.png`);
	await mkdir(CACHE_DIR, { recursive: true });
	if (existsSync(pngPath)) return { png: (await readFile(pngPath)).toString("base64") };

	const dir = await mkdtemp(join(tmpdir(), "pi-rich-dot-"));
	try {
		await writeFile(join(dir, "input.dot"), source, "utf8");
		await execFileAsync(
			"dot",
			["-Tpng", `-Gdpi=${LATEX_DPI / 2}`, "-Gbgcolor=transparent", `-Gfontcolor=${ink}`, `-Gcolor=${ink}`,
				`-Nfontcolor=${ink}`, `-Ncolor=${ink}`, `-Efontcolor=${ink}`, `-Ecolor=${ink}`,
				"-o", "output.png", "input.dot"],
			{ cwd: dir, timeout: TIMEOUT_MS, maxBuffer: MAX_BUFFER },
		);
		const png = await readFile(join(dir, "output.png"));
		await writeFile(pngPath, png);
		return { png: png.toString("base64") };
	} catch (error) {
		return { error: compactError(error) };
	} finally {
		await rm(dir, { recursive: true, force: true }).catch(() => {});
	}
}

async function renderLatex(source: string, foreground: string, inline: boolean): Promise<{ png?: string; error?: string }> {
	const block = parseLatexBlock(source);
	const key = createHash("sha256").update("latex-v5\0").update(JSON.stringify({ block, inline, foreground, dpi: LATEX_DPI })).digest("hex");
	const pngPath = join(CACHE_DIR, `${key}.png`);
	await mkdir(CACHE_DIR, { recursive: true });
	if (existsSync(pngPath)) return { png: (await readFile(pngPath)).toString("base64") };

	const dir = await mkdtemp(join(tmpdir(), "pi-rich-latex-"));
	try {
		await writeFile(join(dir, "input.tex"), latexDocument(block, inline), "utf8");
		await execFileAsync("latex", ["-interaction=nonstopmode", "input.tex"], { cwd: dir, timeout: TIMEOUT_MS, maxBuffer: MAX_BUFFER });
		await execFileAsync("dvipng", ["-T", "tight", "-D", String(LATEX_DPI), "-bg", "Transparent", "-fg", foreground, "--truecolor", "-o", "output.png", "input.dvi"], {
			cwd: dir,
			timeout: TIMEOUT_MS,
			maxBuffer: MAX_BUFFER,
		});
		const png = await readFile(join(dir, "output.png"));
		await writeFile(pngPath, png);
		return { png: png.toString("base64") };
	} catch (error) {
		return { error: compactError(error) };
	} finally {
		await rm(dir, { recursive: true, force: true }).catch(() => {});
	}
}

function parseLatexBlock(source: string): LatexBlock {
	const trimmed = source.trim();
	if (trimmed.startsWith("$$") && trimmed.endsWith("$$")) return { tex: trimmed.slice(2, -2).trim(), wrapDisplay: true };
	if (trimmed.startsWith("\\[") && trimmed.endsWith("\\]")) return { tex: trimmed.slice(2, -2).trim(), wrapDisplay: true };
	if (trimmed.startsWith("$") && trimmed.endsWith("$")) return { tex: trimmed.slice(1, -1).trim(), wrapDisplay: true };
	return { tex: trimmed, wrapDisplay: false };
}

function latexDocument(block: LatexBlock, inline: boolean): string {
	// FIX 9: an inline formula is drawn into exactly one cell row, so its on-screen
	// size is cellHeight / imageHeight — the tight ink crop, and nothing else,
	// decides how big it looks. `\strut` (zero width, one \baselineskip tall, and
	// counted by tightpage even though it lays down no ink — verified) pins that
	// denominator, so `$x$` is no longer magnified 2x and a `\frac` is no longer
	// shrunk to fit; both land at about the size of the surrounding text, sitting on
	// the strut's baseline so they line up with it too. Text style rather than
	// \displaystyle for the same reason: \displaystyle stacks the limits of \int and
	// \sum above and below and draws full-height fraction bars, which is 40-60% more
	// height to give away. An environment (align, gather) brings its own display
	// context and is never wrapped.
	const body = block.wrapDisplay ? (inline ? `\\strut\\(${block.tex}\\)` : `\\(\\displaystyle ${block.tex}\\)`) : block.tex;
	// No border, inline or display. Every point of it is dead space inside the
	// image: inline math is scaled to one cell tall, so padding is height stolen
	// from the glyphs, and a display block is sized from its own pixel height, so
	// padding just inflates the rows reserved around the formula. The blank line
	// that markdown puts above and below a block is spacing enough.
	return String.raw`\documentclass[12pt]{article}
\usepackage[active,tightpage]{preview}
\usepackage{amsmath,amssymb,mathtools,bm}
\usepackage[version=4]{mhchem}
\setlength\PreviewBorder{0pt}
\pagestyle{empty}
\begin{document}
\begin{preview}
${body}
\end{preview}
\end{document}
`;
}

function dvipngForeground(theme?: Theme): string {
	const rgb = (theme ? ansiToRgb(theme.getFgAnsi("text")) : undefined) ?? DEFAULT_INK;
	return `rgb ${rgb.r / 255} ${rgb.g / 255} ${rgb.b / 255}`;
}

const DEFAULT_INK: RGB = { r: 230, g: 237, b: 243 };

/** Read back the `rgb r g b` string dvipng takes, so other tools can share it. */
function parseDvipngForeground(foreground: string): RGB {
	const parts = foreground.split(/\s+/).slice(1).map(Number);
	if (parts.length !== 3 || parts.some((value) => !Number.isFinite(value))) return DEFAULT_INK;
	return { r: Math.round(parts[0] * 255), g: Math.round(parts[1] * 255), b: Math.round(parts[2] * 255) };
}

function rgbToHex({ r, g, b }: RGB): string {
	return `#${[r, g, b].map((value) => value.toString(16).padStart(2, "0")).join("")}`;
}

function ansiToRgb(ansi: string): RGB | undefined {
	const trueColor = ansi.match(/38;2;(\d+);(\d+);(\d+)/);
	if (trueColor) return { r: byte(trueColor[1]), g: byte(trueColor[2]), b: byte(trueColor[3]) };
	const color256 = ansi.match(/38;5;(\d+)/);
	if (!color256) return undefined;
	return ansi256ToRgb(byte(color256[1]));
}

function ansi256ToRgb(index: number): RGB {
	const ansi16: RGB[] = [
		{ r: 0, g: 0, b: 0 }, { r: 128, g: 0, b: 0 }, { r: 0, g: 128, b: 0 }, { r: 128, g: 128, b: 0 },
		{ r: 0, g: 0, b: 128 }, { r: 128, g: 0, b: 128 }, { r: 0, g: 128, b: 128 }, { r: 192, g: 192, b: 192 },
		{ r: 128, g: 128, b: 128 }, { r: 255, g: 0, b: 0 }, { r: 0, g: 255, b: 0 }, { r: 255, g: 255, b: 0 },
		{ r: 0, g: 0, b: 255 }, { r: 255, g: 0, b: 255 }, { r: 0, g: 255, b: 255 }, { r: 255, g: 255, b: 255 },
	];
	if (index < 16) return ansi16[index];
	const cube = [0, 95, 135, 175, 215, 255];
	if (index < 232) {
		const n = index - 16;
		return { r: cube[Math.floor(n / 36) % 6], g: cube[Math.floor(n / 6) % 6], b: cube[n % 6] };
	}
	const gray = 8 + (index - 232) * 10;
	return { r: gray, g: gray, b: gray };
}

function byte(value: string): number {
	const n = Number(value);
	return Number.isFinite(n) ? Math.max(0, Math.min(255, n)) : 0;
}

function compactError(error: unknown): string {
	const err = error as { stderr?: unknown; stdout?: unknown; message?: unknown };
	return String(err.stderr || err.stdout || err.message || error).split("\n").slice(0, 2).join(" ") || "render failed";
}

// --- FIX 4: Unicode placeholders for math inside wrapped text ---------------
//
// A raw kitty escape cannot survive inside a list item or table cell, because
// the renderer word-wraps its huge base64 payload (FIX 3). Kitty's Unicode
// placeholder mode splits the job in two:
//
//   1. transmit the PNG once, out of band, with U=1 — nothing is drawn, and the
//      escape sits alone on a top-level line where pi-tui leaves image lines
//      unwrapped;
//   2. place it with one U+10EEEE character per cell, each carrying diacritics
//      that encode its row and column, coloured with the image id.
//
// Only the short placeholder run lives in the wrapped text, so no amount of
// re-wrapping can spill base64. Worst case a wrapped line splits the image.

/** Kitty's row/column diacritics: index i encodes row/column i. */
const DIACRITICS = [
	0x0305, 0x030d, 0x030e, 0x0310, 0x0312, 0x033d, 0x033e, 0x033f, 0x0346, 0x034a,
	0x034b, 0x034c, 0x0350, 0x0351, 0x0352, 0x0357, 0x035b, 0x0363, 0x0364, 0x0365,
	0x0366, 0x0367, 0x0368, 0x0369, 0x036a, 0x036b, 0x036c, 0x036d, 0x036e, 0x036f,
	0x0483, 0x0484, 0x0485, 0x0486, 0x0487, 0x0592, 0x0593, 0x0594, 0x0595, 0x0597,
	0x0598, 0x0599, 0x059c, 0x059d, 0x059e, 0x059f, 0x05a0, 0x05a1, 0x05a8, 0x05a9,
	0x05ab, 0x05ac, 0x05af, 0x05c4, 0x0610, 0x0611, 0x0612, 0x0613, 0x0614, 0x0615,
	0x0616, 0x0617, 0x0657, 0x0658, 0x0659, 0x065a, 0x065b, 0x065d, 0x065e, 0x06d6,
	0x06d7, 0x06d8, 0x06d9, 0x06da, 0x06db, 0x06dc, 0x06df, 0x06e0, 0x06e1, 0x06e2,
	0x06e4, 0x06e7, 0x06e8, 0x06eb, 0x06ec, 0x0730, 0x0732, 0x0733, 0x0735, 0x0736,
	0x073a, 0x073d, 0x073f, 0x0740, 0x0741, 0x0743, 0x0745, 0x0747, 0x0749, 0x074a,
];
const PLACEHOLDER_CHAR = String.fromCodePoint(0x10eeee);
/** Ids stay inside 24 bits so the foreground colour alone identifies the image. */
const MAX_PLACEHOLDER_ID = 0xffffff;
/**
 * FIX 7: seed randomly, never from 0. The terminal keeps transmitted images per
 * window, keyed by id — so a counter that restarts at 1 in every pi process makes
 * the second session overwrite the first session's images. Observed directly: a
 * formula already drawn in a table cell changed into a different formula when the
 * next process transmitted its own id 1. Ids are only ever compared for equality,
 * so a random start costs nothing.
 */
let nextPlaceholderId = Math.floor(Math.random() * MAX_PLACEHOLDER_ID);

function allocatePlaceholderId(): number {
	nextPlaceholderId = (nextPlaceholderId % MAX_PLACEHOLDER_ID) + 1;
	return nextPlaceholderId;
}

/** Transmit-only escape (U=1): defines the image without drawing anything. */
export function encodeTransmit(base64Data: string, id: number, columns: number, rows: number): string {
	const params = ["a=T", "f=100", "q=2", "U=1", `i=${id}`, `c=${columns}`, `r=${rows}`];
	const CHUNK_SIZE = 4096;
	if (base64Data.length <= CHUNK_SIZE) return `\x1b_G${params.join(",")};${base64Data}\x1b\\`;
	const chunks: string[] = [];
	let offset = 0;
	let isFirst = true;
	while (offset < base64Data.length) {
		const chunk = base64Data.slice(offset, offset + CHUNK_SIZE);
		const isLast = offset + CHUNK_SIZE >= base64Data.length;
		if (isFirst) {
			chunks.push(`\x1b_G${params.join(",")},m=1;${chunk}\x1b\\`);
			isFirst = false;
		} else {
			chunks.push(`\x1b_Gm=${isLast ? 0 : 1};${chunk}\x1b\\`);
		}
		offset += CHUNK_SIZE;
	}
	return chunks.join("");
}

/** One line of placeholder cells addressing row `row` of image `id`. */
export function encodePlaceholderRow(id: number, row: number, columns: number): string {
	const r = (id >> 16) & 0xff;
	const g = (id >> 8) & 0xff;
	const b = id & 0xff;
	let out = `\x1b[38;2;${r};${g};${b}m`;
	for (let column = 0; column < columns; column++) {
		out += PLACEHOLDER_CHAR + String.fromCodePoint(DIACRITICS[row]) + String.fromCodePoint(DIACRITICS[column]);
	}
	return `${out}\x1b[0m`;
}

/**
 * Inline math is placed on a single text row, so the image is scaled to one cell
 * tall and the columns follow from its true aspect. What keeps the glyphs at a
 * sane size is the `\strut` in latexDocument(), which makes every inline image
 * about one baselineskip tall whatever the formula is (FIX 9); without it the
 * scale factor is whatever the ink crop happened to be.
 */
export function inlineColumns(widthPx: number, heightPx: number, cell: { widthPx: number; heightPx: number }): number {
	const scale = cell.heightPx / heightPx;
	const columns = Math.round((widthPx * scale) / cell.widthPx);
	return Math.max(1, Math.min(columns, DIACRITICS.length));
}

// --- FIX 1: aspect-correct geometry ----------------------------------------

/**
 * Pick a c x r cell box whose aspect ratio matches the image's own. Rows are
 * derived first (the vertical rounding error is what destroyed legibility:
 * one cell out of two is a 50% stretch, whereas one column out of ~56 is <2%).
 */
export function computeImageBox(
	widthPx: number,
	heightPx: number,
	cell: { widthPx: number; heightPx: number },
	widthBudget: number,
	imageScale: number,
): { columns: number; rows: number } {
	const budget = Math.max(1, Math.min(widthBudget, MAX_COLUMNS));
	let rows = Math.max(1, Math.min(MAX_ROWS, Math.round((heightPx / cell.heightPx) * imageScale)));
	let scale = (rows * cell.heightPx) / heightPx;
	let columns = Math.max(1, Math.round((widthPx * scale) / cell.widthPx));
	if (columns > budget) {
		// Too wide for the viewport: re-derive from the width budget instead, then
		// round rows to whatever that scale implies so the box keeps its aspect.
		columns = budget;
		scale = (columns * cell.widthPx) / widthPx;
		rows = Math.max(1, Math.min(MAX_ROWS, Math.round((heightPx * scale) / cell.heightPx)));
	}
	return { columns, rows };
}

class RenderedImage implements Component {
	private cachedWidth?: number;
	private cachedLines?: string[];
	private segment: Extract<RenderSegment, { type: "image" }>;
	private theme: Theme;
	private imageScale: number;
	// Explicit fields rather than TS parameter properties: parameter properties
	// are not strip-only syntax, so they break `node --experimental-strip-types`
	// and anything else that erases types without transforming them.
	constructor(segment: Extract<RenderSegment, { type: "image" }>, theme: Theme, imageScale: number) {
		this.segment = segment;
		this.theme = theme;
		this.imageScale = imageScale;
	}
	render(width: number): string[] {
		if (this.cachedWidth === width && this.cachedLines) return this.cachedLines;
		const lines = this.segment.png ? this.renderPng(width, this.segment.png) : this.renderError(width, this.segment.error ?? "render failed");
		this.cachedWidth = width;
		this.cachedLines = lines;
		return lines;
	}
	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}
	private renderPng(width: number, png: string): string[] {
		const dimensions = getImageDimensions(png, PNG_MIME);
		if (!dimensions) return this.renderError(width, "invalid PNG");
		const caps = getCapabilities();
		if (caps.images !== "kitty") {
			// iterm2 / no-image terminals: let pi-tui handle it, including its
			// "[Image: image/png WxH]" placeholder.
			const image = new Image(
				png,
				PNG_MIME,
				{ fallbackColor: (text: string) => this.theme.fg("dim", text) },
				{ maxWidthCells: Math.max(1, Math.min(width - 2, MAX_COLUMNS)) },
				dimensions,
			);
			return image.render(width);
		}
		const { columns, rows } = computeImageBox(
			dimensions.widthPx,
			dimensions.heightPx,
			getCellDimensions(),
			width - 2,
			this.imageScale,
		);
		const sequence = encodeKitty(png, { columns, rows, imageId: allocateImageId(), moveCursor: false });
		// The escape lives on one line; the remaining rows must exist as blank
		// lines so pi-tui's getKittyImageReservedRows() keeps that space clear.
		const lines = [sequence];
		for (let i = 1; i < rows; i++) lines.push("");
		return lines;
	}
	private renderError(width: number, error: string): string[] {
		return new Text(this.theme.fg("error", `render error: ${error}`), 1, 0).render(width);
	}
}
