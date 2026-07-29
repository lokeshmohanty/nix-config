// Regression tests for the placement fixes (FIX 5/6/7).
//
// Run from a directory where `@earendil-works/pi-tui` resolves — the extension
// dir has no node_modules of its own:
//
//   cd "$(mktemp -d)" && ln -s ~/.pi/agent/npm/node_modules node_modules \
//     && cp ~/.agents/../pi/agent/extensions/rich-renderer/index*.ts . \
//     && node --experimental-strip-types index.test.ts
//
// The file must stay strip-only-clean: no TS parameter properties, and
// `import type` rather than `import { type ... }`.
import { Markdown, setCapabilities, getCapabilities, setCellDimensions } from "@earendil-works/pi-tui";
import extension, { splitMarkdown, isStandaloneMath, isDisplayDelimited, reserveRows } from "./index.ts";

setCapabilities({ ...getCapabilities(), images: "kitty" });
setCellDimensions({ widthPx: 10, heightPx: 20 });

let failures = 0;
function check(name: string, actual: unknown, expected: unknown): void {
	const ok = JSON.stringify(actual) === JSON.stringify(expected);
	if (!ok) failures++;
	console.log(`${ok ? "PASS" : "FAIL"}  ${name}`);
	if (!ok) console.log(`        expected ${JSON.stringify(expected)}\n        actual   ${JSON.stringify(actual)}`);
}

const theme: any = { fg: (_key: string, text: string) => text, getFgAnsi: () => "38;2;230;237;243" };
const inlineFlags = (markdown: string) =>
	splitMarkdown(markdown).filter((segment) => segment.type === "image").map((segment) => (segment as any).inline);

// --- FIX 5: what becomes a block, what flows inline ------------------------
check("mid-sentence $…$ flows inline", inlineFlags("The identity is $E = mc^2$ and that is that."), [true]);
check("display math on its own line is a block", inlineFlags("Result:\n\n$$\\int_0^1 x^2 dx$$\n\nDone."), [false]);
check("display math mid-sentence is promoted to a block", inlineFlags("Result: $$\\int_0^1 x^2 dx$$ and done."), [false]);
check("math in a list item stays inline", inlineFlags("- energy $E = mc^2$ here"), [true]);
check("math alone in a list item stays inline", inlineFlags("- $E = mc^2$"), [true]);
check("mixed inline + block", inlineFlags("The identity is $E = mc^2$ and:\n\n$$\\sqrt{\\pi}$$"), [true, false]);
check("isDisplayDelimited", [isDisplayDelimited("$$x$$"), isDisplayDelimited("$x$"), isDisplayDelimited("\\[x\\]")], [true, false, true]);
check("isStandaloneMath: mid-line", isStandaloneMath("a $x$ b\n$$y$$\n", 2, 5), false);
check("isStandaloneMath: own line", isStandaloneMath("a $x$ b\n$$y$$\n", 8, 13), true);

// A raw escape must never share a rendered line with prose: the terminal draws
// the image at the cursor and then prints the text over it.
const escape = "\x1b_Ga=T,f=100,c=20,r=2;iVBORw0KGgo=\x1b\\";
const sharesLine = (lines: string[]) =>
	lines.some((line) => line.includes("\x1b_G") && line.replace(/\x1b_G[^\x1b]*\x1b?\\?/g, "").replace(/\x1b\[[0-9;]*m/g, "").trim().length > 0);
check("bare newlines leave the escape sharing a line", sharesLine(new Markdown(`is \n${escape}\n and done.`, 0, 0, theme).render(80)), true);
check("blank lines put the escape on its own line", sharesLine(new Markdown(`is\n\n${escape}\n\nand done.`, 0, 0, theme).render(80)), false);

// --- FIX 6: reserved rows survive markdown --------------------------------
const visibleWidth = (line: string) =>
	line.replace(/\x1b_G[^\x1b]*\x1b?\\?/g, "").replace(/\x1b\[[0-9;]*m/g, "").trim().length;
for (const rows of [1, 2, 3, 5, 8, 12, 20]) {
	const image = `\x1b_Ga=T,f=100,c=20,r=${rows};iVBORw0KGgo=\x1b\\`;
	const lines = new Markdown(`intro\n\n${image}\n${reserveRows(rows - 1)}\n\ntail`, 0, 0, theme).render(60);
	const index = lines.findIndex((line) => line.includes("\x1b_G"));
	let reserved = 0;
	for (let i = index + 1; i < lines.length && visibleWidth(lines[i]) === 0; i++) reserved++;
	check(`${rows}-row image reserves >= ${rows - 1} rows below (got ${reserved})`, reserved >= rows - 1, true);
}

// --- FIX 5/7: one transmission per distinct formula ------------------------
const handlers: Record<string, Function> = {};
extension({ on: (name: string, fn: Function) => { handlers[name] = fn; } } as any);
const rendered = await handlers["message_end"](
	{ message: { role: "assistant", content: [{ type: "text", text: "First $x^2$, then $x^2$, and again $x^2$." }], stopReason: "stop" } },
	{ ui: { theme, terminal: { columns: 100 } } },
);
const text: string = rendered?.message?.content?.[0]?.text ?? "";
check("three identical formulas transmit once", (text.match(/\x1b_Ga=T/g) ?? []).length, 1);
check("placeholder cells are emitted", text.includes(String.fromCodePoint(0x10eeee)), true);

console.log(failures ? `\n${failures} FAILED` : "\nall passed");
process.exit(failures ? 1 : 0);
