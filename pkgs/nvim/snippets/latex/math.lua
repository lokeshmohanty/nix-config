-- Math snippets for mini.snippets
-- condition = 'math'  → only expands inside math zones (checked in ft.lua)
-- no condition        → expands anywhere (prefixes are non-conflicting)
-- \$ in body = literal dollar sign (LSP snippet escaping)

local M = {}

-- ── Inline / display math wrappers ───────────────────────────────────────
vim.list_extend(M, {
  { prefix = "im",  body = "\\$$1\\$ $0",                    desc = "inline math $…$" },
  { prefix = "dm",  body = { "\\[", "\t$1", "\\]$0" },       desc = "display math \\[…\\]" },
  { prefix = "II",  body = "\\($1\\) $0",                    desc = "inline math \\(…\\)" },
})

-- ── Greek lowercase (prefix ') ────────────────────────────────────────────
vim.list_extend(M, {
  { prefix = "'a", body = "\\alpha ",   desc = "α" },
  { prefix = "'b", body = "\\beta ",    desc = "β" },
  { prefix = "'c", body = "\\chi ",     desc = "χ" },
  { prefix = "'d", body = "\\delta ",   desc = "δ" },
  { prefix = "'e", body = "\\epsilon ", desc = "ε" },
  { prefix = "'f", body = "\\phi ",     desc = "φ" },
  { prefix = "'g", body = "\\gamma ",   desc = "γ" },
  { prefix = "'h", body = "\\eta ",     desc = "η" },
  { prefix = "'i", body = "\\iota ",    desc = "ι" },
  { prefix = "'k", body = "\\kappa ",   desc = "κ" },
  { prefix = "'l", body = "\\lambda ",  desc = "λ" },
  { prefix = "'m", body = "\\mu ",      desc = "μ" },
  { prefix = "'n", body = "\\nu ",      desc = "ν" },
  { prefix = "'p", body = "\\pi ",      desc = "π" },
  { prefix = "'q", body = "\\theta ",   desc = "θ" },
  { prefix = "'r", body = "\\rho ",     desc = "ρ" },
  { prefix = "'s", body = "\\sigma ",   desc = "σ" },
  { prefix = "'t", body = "\\tau ",     desc = "τ" },
  { prefix = "'u", body = "\\upsilon ", desc = "υ" },
  { prefix = "'w", body = "\\omega ",   desc = "ω" },
  { prefix = "'x", body = "\\xi ",      desc = "ξ" },
  { prefix = "'y", body = "\\psi ",     desc = "ψ" },
  { prefix = "'z", body = "\\zeta ",    desc = "ζ" },
})

-- ── Greek uppercase (prefix ') ────────────────────────────────────────────
vim.list_extend(M, {
  { prefix = "'D", body = "\\Delta ",   desc = "Δ" },
  { prefix = "'F", body = "\\Phi ",     desc = "Φ" },
  { prefix = "'G", body = "\\Gamma ",   desc = "Γ" },
  { prefix = "'L", body = "\\Lambda ",  desc = "Λ" },
  { prefix = "'P", body = "\\Pi ",      desc = "Π" },
  { prefix = "'Q", body = "\\Theta ",   desc = "Θ" },
  { prefix = "'S", body = "\\Sigma ",   desc = "Σ" },
  { prefix = "'U", body = "\\Upsilon ", desc = "Υ" },
  { prefix = "'W", body = "\\Omega ",   desc = "Ω" },
  { prefix = "'X", body = "\\Xi ",      desc = "Ξ" },
  { prefix = "'Y", body = "\\Psi ",     desc = "Ψ" },
})

-- ── Greek variants ────────────────────────────────────────────────────────
vim.list_extend(M, {
  { prefix = "ve",  body = "\\varepsilon ", desc = "ε (var)" },
  { prefix = "vf",  body = "\\varphi ",     desc = "φ (var)" },
  { prefix = "vk",  body = "\\varkappa ",   desc = "ϰ (var)" },
  { prefix = "vp",  body = "\\varpi ",      desc = "ϖ (var)" },
  { prefix = "vq",  body = "\\vartheta ",   desc = "ϑ (var)" },
  { prefix = "vr",  body = "\\varrho ",     desc = "ϱ (var)" },
  { prefix = "'H",  body = "\\hbar ",       desc = "ℏ" },
  { prefix = "'0",  body = "\\emptyset ",   desc = "∅" },
  { prefix = "'8",  body = "\\infty ",      desc = "∞" },
})

-- ── Arrow shortcuts (j prefix) ───────────────────────────────────────────
vim.list_extend(M, {
  { prefix = "jl", body = "\\to ",             desc = "→" },
  { prefix = "jL", body = "\\Rightarrow ",     desc = "⇒" },
  { prefix = "jh", body = "\\leftarrow ",      desc = "←" },
  { prefix = "jH", body = "\\Leftarrow ",      desc = "⇐" },
  { prefix = "jk", body = "\\uparrow ",        desc = "↑" },
  { prefix = "jK", body = "\\Uparrow ",        desc = "⇑" },
  { prefix = "jj", body = "\\downarrow ",      desc = "↓" },
  { prefix = "jJ", body = "\\Downarrow ",      desc = "⇓" },
  { prefix = "jb", body = "\\leftrightarrow ", desc = "↔" },
  { prefix = "jB", body = "\\Leftrightarrow ", desc = "⇔" },
  { prefix = "jm", body = "\\mapsto ",         desc = "↦" },
})

-- ── Fast math shortcuts (condition = 'math') ─────────────────────────────
vim.list_extend(M, {
  -- Fractions
  { prefix = "ff",  body = "\\frac{$1}{$2}$0",           condition = 'math', desc = "frac" },
  { prefix = "//",  body = "\\frac{$1}{$2}$0",           condition = 'math', desc = "frac (/)" },
  { prefix = "df",  body = "\\dfrac{$1}{$2}$0",          condition = 'math', desc = "dfrac" },

  -- Roots
  { prefix = "sq",  body = "\\sqrt{$1}$0",               condition = 'math', desc = "sqrt" },
  { prefix = "sr",  body = "\\sqrt[$1]{$2}$0",           condition = 'math', desc = "nth root" },

  -- Sub/superscript (double trigger to avoid single _ ^ conflicts)
  { prefix = "__",  body = "_{$1}$0",                    condition = 'math', desc = "subscript {}" },
  { prefix = "^^",  body = "^{$1}$0",                    condition = 'math', desc = "superscript {}" },

  -- Auto-sized delimiters
  { prefix = "((", body = "\\left( $1 \\right)$0",       condition = 'math', desc = "( … )" },
  { prefix = "[[", body = "\\left[ $1 \\right]$0",       condition = 'math', desc = "[ … ]" },
  { prefix = "{{", body = "\\left\\{ $1 \\right\\}$0",   condition = 'math', desc = "{ … }" },
  { prefix = "<<", body = "\\langle $1 \\rangle$0",      condition = 'math', desc = "⟨ … ⟩" },
  { prefix = "||", body = "\\left| $1 \\right|$0",       condition = 'math', desc = "| … |" },
  { prefix = "nrm",body = "\\left\\| $1 \\right\\|$0",   condition = 'math', desc = "‖ … ‖" },
  { prefix = "flr",body = "\\lfloor $1 \\rfloor$0",      condition = 'math', desc = "⌊ … ⌋" },
  { prefix = "cl", body = "\\lceil $1 \\rceil$0",        condition = 'math', desc = "⌈ … ⌉" },

  -- Calculus
  { prefix = "dv",  body = "\\frac{d${1:f}}{d${2:x}}$0",                       condition = 'math', desc = "deriv" },
  { prefix = "pdv", body = "\\frac{\\partial ${1:f}}{\\partial ${2:x}}$0",     condition = 'math', desc = "partial" },
  { prefix = "int", body = "\\int_{$1}^{$2} $3 \\, d${4:x}$0",                condition = 'math', desc = "integral" },
  { prefix = "iint",body = "\\iint_{$1} $2 \\, d${3}\\, d${4}$0",             condition = 'math', desc = "double ∫" },
  { prefix = "oint",body = "\\oint_{$1} $2 \\, d${3}$0",                       condition = 'math', desc = "contour ∮" },
  { prefix = "lim", body = "\\lim_{${1:x} \\to ${2:\\infty}} $0",              condition = 'math', desc = "limit" },
  { prefix = "sm",  body = "\\sum_{${1:i=0}}^{${2:\\infty}} $0",               condition = 'math', desc = "sum ∑" },
  { prefix = "pr",  body = "\\prod_{${1:i=1}}^{${2:n}} $0",                    condition = 'math', desc = "product ∏" },

  -- Decorations
  { prefix = "ht",  body = "\\hat{$1}$0",             condition = 'math', desc = "x̂" },
  { prefix = "wht", body = "\\widehat{$1}$0",         condition = 'math', desc = "wide hat" },
  { prefix = "br",  body = "\\bar{$1}$0",             condition = 'math', desc = "x̄" },
  { prefix = "ol",  body = "\\overline{$1}$0",        condition = 'math', desc = "overline" },
  { prefix = "vc",  body = "\\vec{$1}$0",             condition = 'math', desc = "x⃗" },
  { prefix = "ovr", body = "\\overrightarrow{$1}$0",  condition = 'math', desc = "→ over" },
  { prefix = "td",  body = "\\tilde{$1}$0",           condition = 'math', desc = "x̃" },
  { prefix = "wt",  body = "\\widetilde{$1}$0",       condition = 'math', desc = "wide tilde" },
  { prefix = "dot", body = "\\dot{$1}$0",             condition = 'math', desc = "ẋ" },
  { prefix = "ddt", body = "\\ddot{$1}$0",            condition = 'math', desc = "ẍ" },
  { prefix = "ob",  body = "\\overbrace{$1}^{$2}$0",  condition = 'math', desc = "overbrace" },
  { prefix = "ub",  body = "\\underbrace{$1}_{$2}$0", condition = 'math', desc = "underbrace" },

  -- Math fonts
  { prefix = "mbf", body = "\\mathbf{$1}$0",   condition = 'math', desc = "mathbf" },
  { prefix = "mbb", body = "\\mathbb{$1}$0",   condition = 'math', desc = "mathbb" },
  { prefix = "mca", body = "\\mathcal{$1}$0",  condition = 'math', desc = "mathcal" },
  { prefix = "mfr", body = "\\mathfrak{$1}$0", condition = 'math', desc = "mathfrak" },
  { prefix = "mrm", body = "\\mathrm{$1}$0",   condition = 'math', desc = "mathrm" },
  { prefix = "msc", body = "\\mathscr{$1}$0",  condition = 'math', desc = "mathscr" },

  -- Common number sets (NN, ZZ, etc.)
  { prefix = "NN", body = "\\mathbb{N}",  condition = 'math', desc = "ℕ" },
  { prefix = "ZZ", body = "\\mathbb{Z}",  condition = 'math', desc = "ℤ" },
  { prefix = "QQ", body = "\\mathbb{Q}",  condition = 'math', desc = "ℚ" },
  { prefix = "RR", body = "\\mathbb{R}",  condition = 'math', desc = "ℝ" },
  { prefix = "CC", body = "\\mathbb{C}",  condition = 'math', desc = "ℂ" },
  { prefix = "PP", body = "\\mathbb{P}",  condition = 'math', desc = "ℙ" },

  -- Relations
  { prefix = "leq", body = "\\leq ",    condition = 'math', desc = "≤" },
  { prefix = "geq", body = "\\geq ",    condition = 'math', desc = "≥" },
  { prefix = "neq", body = "\\neq ",    condition = 'math', desc = "≠" },
  { prefix = "app", body = "\\approx ", condition = 'math', desc = "≈" },
  { prefix = "sme", body = "\\simeq ",  condition = 'math', desc = "≃" },
  { prefix = "eqv", body = "\\equiv ",  condition = 'math', desc = "≡" },
  { prefix = "prp", body = "\\propto ", condition = 'math', desc = "∝" },

  -- Set relations
  { prefix = "sub", body = "\\subset ",   condition = 'math', desc = "⊂" },
  { prefix = "sbe", body = "\\subseteq ", condition = 'math', desc = "⊆" },
  { prefix = "spe", body = "\\supseteq ", condition = 'math', desc = "⊇" },
  { prefix = "inn", body = "\\in ",       condition = 'math', desc = "∈" },
  { prefix = "nin", body = "\\notin ",    condition = 'math', desc = "∉" },
  { prefix = "cup", body = "\\cup ",      condition = 'math', desc = "∪" },
  { prefix = "cap", body = "\\cap ",      condition = 'math', desc = "∩" },
  {
    prefix = "bcup",
    body = "\\bigcup_{${1:i=1}}^{${2:n}} $0",
    condition = 'math', desc = "⋃",
  },
  {
    prefix = "bcap",
    body = "\\bigcap_{${1:i=1}}^{${2:n}} $0",
    condition = 'math', desc = "⋂",
  },
  { prefix = "opl", body = "\\oplus ",  condition = 'math', desc = "⊕" },
  { prefix = "otp", body = "\\otimes ", condition = 'math', desc = "⊗" },

  -- Logic
  { prefix = "AA",  body = "\\forall ",  condition = 'math', desc = "∀" },
  { prefix = "EE",  body = "\\exists ",  condition = 'math', desc = "∃" },
  { prefix = "imp", body = "\\implies ", condition = 'math', desc = "⟹" },
  { prefix = "iff", body = "\\iff ",     condition = 'math', desc = "⟺" },
  { prefix = "neg", body = "\\neg ",     condition = 'math', desc = "¬" },

  -- Misc operators
  { prefix = "oo",  body = "\\infty ",   condition = 'math', desc = "∞" },
  { prefix = "xx",  body = "\\times ",   condition = 'math', desc = "×" },
  { prefix = "cdt", body = "\\cdot ",    condition = 'math', desc = "·" },
  { prefix = "pm",  body = "\\pm ",      condition = 'math', desc = "±" },
  { prefix = "grd", body = "\\nabla ",   condition = 'math', desc = "∇" },
  { prefix = "del", body = "\\partial ", condition = 'math', desc = "∂" },
  { prefix = "'.",  body = "\\cdot ",    condition = 'math', desc = "·" },
  { prefix = "'*",  body = "\\times ",   condition = 'math', desc = "×" },
  { prefix = "'[",  body = "\\subseteq ", condition = 'math', desc = "⊆" },
  { prefix = "'+",  body = "\\dagger ",  condition = 'math', desc = "†" },

  -- Matrix environments (inside math)
  {
    prefix = "pmat",
    body = { "\\begin{pmatrix}", "\t$0", "\\end{pmatrix}" },
    condition = 'math', desc = "pmatrix",
  },
  {
    prefix = "bmat",
    body = { "\\begin{bmatrix}", "\t$0", "\\end{bmatrix}" },
    condition = 'math', desc = "bmatrix",
  },
  {
    prefix = "vmat",
    body = { "\\begin{vmatrix}", "\t$0", "\\end{vmatrix}" },
    condition = 'math', desc = "vmatrix",
  },
  {
    prefix = "cas",
    body = { "\\begin{cases}", "\t$1 & $2 \\\\\\\\", "\t$0", "\\end{cases}" },
    condition = 'math', desc = "cases",
  },
})

return M
