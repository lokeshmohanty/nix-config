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
const DEFAULT_IMAGE_SCALE = 0.5;
const DEFAULT_CACHE_TTL_MS = 7 * 24 * 60 * 60 * 1000;
const MAX_ROWS = 40;
const MAX_COLUMNS = 100;
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
	| { type: "image"; kind: "math"; source: string; png?: string; error?: string };

type LatexBlock = { tex: string; wrapDisplay: boolean };

type RGB = { r: number; g: number; b: number };

type RendererConfig = {
	imageScale: number;
	cacheTtlMs: number;
};

export default function (pi: ExtensionAPI) {
	void cleanupCache();

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
		if (message.role !== "assistant") return;
		if (message.stopReason && !["stop", "length"].includes(message.stopReason)) return;
		if ((message as any)[ORIGINAL_CONTENT_FIELD]) return;

		const markdown = message.content
			.filter((part): part is TextContent => part.type === "text" && typeof part.text === "string")
			.map((part) => part.text)
			.join("\n\n")
			.trim();
		if (!markdown || !shouldRender(markdown)) return;

		const [segments, config] = await Promise.all([buildSegments(markdown, ctx.ui.theme), getConfig()]);
		if (!segments.some((segment) => segment.type === "image" && segment.png)) return;

		return {
			message: {
				...message,
				[ORIGINAL_CONTENT_FIELD]: message.content,
				content: [{ type: "text", text: renderSegmentsAsText(segments, ctx.ui.theme, terminalWidth(ctx), config.imageScale) }],
			},
		};
	});
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
		cacheTtlMs: readNonNegativeNumber(config.cacheTtlMs ?? config.cacheTtl, DEFAULT_CACHE_TTL_MS),
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

function renderSegmentsAsText(segments: RenderSegment[], theme: Theme, width: number, imageScale: number): string {
	return segments.map((segment) => {
		if (segment.type === "markdown") return segment.markdown;
		if (!segment.png) return segment.source;
		return `\n${new RenderedImage(segment, theme, imageScale).render(width).join("\n")}\n`;
	}).join("").trim();
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

function shouldRender(markdown: string): boolean {
	return splitMarkdown(markdown).some((segment) => segment.type === "image");
}

async function buildSegments(markdown: string, theme: Theme): Promise<RenderSegment[]> {
	const raw = splitMarkdown(markdown);
	const foreground = dvipngForeground(theme);
	const out: RenderSegment[] = [];

	for (const segment of raw) {
		if (segment.type === "markdown") {
			const previous = out[out.length - 1];
			if (previous?.type === "markdown") previous.markdown += segment.markdown;
			else out.push(segment);
			continue;
		}
		out.push({ ...segment, ...(await renderLatex(segment.source, foreground)) });
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
		if (isCode || !looksLikeMath(parseLatexBlock(source).tex)) pushMarkdown(source);
		else segments.push({ type: "image", kind: "math", source });
		cursor = match.index + source.length;
	}
	if (cursor < markdown.length) pushMarkdown(markdown.slice(cursor));
	return segments;
}

async function renderLatex(source: string, foreground: string): Promise<{ png?: string; error?: string }> {
	const block = parseLatexBlock(source);
	const key = createHash("sha256").update("latex-v1\0").update(JSON.stringify({ block, foreground, dpi: LATEX_DPI })).digest("hex");
	const pngPath = join(CACHE_DIR, `${key}.png`);
	await mkdir(CACHE_DIR, { recursive: true });
	if (existsSync(pngPath)) return { png: (await readFile(pngPath)).toString("base64") };

	const dir = await mkdtemp(join(tmpdir(), "pi-rich-latex-"));
	try {
		await writeFile(join(dir, "input.tex"), latexDocument(block), "utf8");
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

function latexDocument(block: LatexBlock): string {
	const body = block.wrapDisplay ? `\\(\\displaystyle ${block.tex}\\)` : block.tex;
	return String.raw`\documentclass[12pt]{article}
\usepackage[active,tightpage]{preview}
\usepackage{amsmath,amssymb,mathtools,bm}
\setlength\PreviewBorder{2pt}
\pagestyle{empty}
\begin{document}
\begin{preview}
${body}
\end{preview}
\end{document}
`;
}

function dvipngForeground(theme: Theme): string {
	const rgb = ansiToRgb(theme.getFgAnsi("text")) ?? { r: 230, g: 237, b: 243 };
	return `rgb ${rgb.r / 255} ${rgb.g / 255} ${rgb.b / 255}`;
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
