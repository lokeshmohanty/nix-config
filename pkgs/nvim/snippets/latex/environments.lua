-- LaTeX environment snippets (replaces basic.lua)

return {
  -- ── Generic ──────────────────────────────────────────────────────────────
  {
    prefix = "beg",
    body = { "\\begin{$1}", "\t${0:${TM_SELECTED_TEXT}}", "\\end{$1}" },
    desc = "generic environment",
  },

  -- ── Math display environments ─────────────────────────────────────────────
  { prefix = "eq",    body = { "\\begin{equation}", "\t$0", "\\end{equation}" },     desc = "equation" },
  { prefix = "eq*",   body = { "\\begin{equation*}", "\t$0", "\\end{equation*}" },   desc = "equation*" },
  { prefix = "ali",   body = { "\\begin{align}", "\t$1 \\\\\\\\", "\t$0", "\\end{align}" }, desc = "align" },
  { prefix = "ali*",  body = { "\\begin{align*}", "\t$1 \\\\\\\\", "\t$0", "\\end{align*}" }, desc = "align*" },
  { prefix = "gat",   body = { "\\begin{gather}", "\t$0", "\\end{gather}" },          desc = "gather" },
  { prefix = "gat*",  body = { "\\begin{gather*}", "\t$0", "\\end{gather*}" },        desc = "gather*" },
  { prefix = "spl",   body = { "\\begin{split}", "\t$0", "\\end{split}" },            desc = "split" },
  { prefix = "mlt",   body = { "\\begin{multline}", "\t$0", "\\end{multline}" },      desc = "multline" },
  { prefix = "mlt*",  body = { "\\begin{multline*}", "\t$0", "\\end{multline*}" },    desc = "multline*" },

  -- ── Lists ─────────────────────────────────────────────────────────────────
  { prefix = "ite", body = { "\\begin{itemize}", "\t\\item $0", "\\end{itemize}" },     desc = "itemize" },
  { prefix = "enu", body = { "\\begin{enumerate}", "\t\\item $0", "\\end{enumerate}" }, desc = "enumerate" },
  { prefix = "des", body = { "\\begin{description}", "\t\\item[$1] $0", "\\end{description}" }, desc = "description" },

  -- ── Theorem-like ─────────────────────────────────────────────────────────
  { prefix = "thm",  body = { "\\begin{theorem}[$1]", "\t$0", "\\end{theorem}" },     desc = "theorem" },
  { prefix = "lem",  body = { "\\begin{lemma}[$1]", "\t$0", "\\end{lemma}" },         desc = "lemma" },
  { prefix = "cor",  body = { "\\begin{corollary}[$1]", "\t$0", "\\end{corollary}" }, desc = "corollary" },
  { prefix = "prop", body = { "\\begin{proposition}[$1]", "\t$0", "\\end{proposition}" }, desc = "proposition" },
  { prefix = "def",  body = { "\\begin{definition}[$1]", "\t$0", "\\end{definition}" }, desc = "definition" },
  { prefix = "rmk",  body = { "\\begin{remark}", "\t$0", "\\end{remark}" },           desc = "remark" },
  { prefix = "exm",  body = { "\\begin{example}", "\t$0", "\\end{example}" },         desc = "example" },
  { prefix = "prf",  body = { "\\begin{proof}", "\t$0", "\\end{proof}" },             desc = "proof" },

  -- ── Floats ───────────────────────────────────────────────────────────────
  {
    prefix = "fig",
    body = {
      "\\begin{figure}[${1:htbp}]",
      "\t\\centering",
      "\t\\includegraphics[width=${2:0.8}\\textwidth]{${3:filename}}",
      "\t\\caption{${4:caption}}",
      "\t\\label{fig:${5:label}}",
      "\\end{figure}$0",
    },
    desc = "figure",
  },
  {
    prefix = "fig*",
    body = {
      "\\begin{figure*}[${1:htbp}]",
      "\t\\centering",
      "\t\\includegraphics[width=${2:0.9}\\textwidth]{${3:filename}}",
      "\t\\caption{${4:caption}}",
      "\t\\label{fig:${5:label}}",
      "\\end{figure*}$0",
    },
    desc = "figure* (full width)",
  },
  {
    prefix = "tab",
    body = {
      "\\begin{table}[${1:htbp}]",
      "\t\\centering",
      "\t\\caption{${2:caption}}",
      "\t\\label{tab:${3:label}}",
      "\t\\begin{tabular}{${4:cc}}",
      "\t\t\\toprule",
      "\t\t$5 \\\\\\\\",
      "\t\t\\midrule",
      "\t\t$0",
      "\t\t\\bottomrule",
      "\t\\end{tabular}",
      "\\end{table}",
    },
    desc = "table (booktabs)",
  },

  -- ── Algorithm ─────────────────────────────────────────────────────────────
  {
    prefix = "algo",
    body = {
      "\\begin{algorithm}",
      "\t\\caption{${1:Algorithm}}",
      "\t\\label{alg:${2:label}}",
      "\t\\begin{algorithmic}[1]",
      "\t\t\\Require $3",
      "\t\t\\Ensure $4",
      "\t\t$0",
      "\t\\end{algorithmic}",
      "\\end{algorithm}",
    },
    desc = "algorithm (algpseudocode)",
  },

  -- ── Beamer ────────────────────────────────────────────────────────────────
  {
    prefix = "frm",
    body = {
      "\\begin{frame}{${1:Title}}",
      "\t$0",
      "\\end{frame}",
    },
    desc = "beamer frame",
  },

  -- ── Sectioning ────────────────────────────────────────────────────────────
  { prefix = "s",   body = "\\section{$1}$0",         desc = "section" },
  { prefix = "ss",  body = "\\subsection{$1}$0",      desc = "subsection" },
  { prefix = "sss", body = "\\subsubsection{$1}$0",   desc = "subsubsection" },

  -- ── Text formatting ───────────────────────────────────────────────────────
  { prefix = "tb",  body = "\\textbf{${1:${TM_SELECTED_TEXT}}}$0",  desc = "bold" },
  { prefix = "ti",  body = "\\textit{${1:${TM_SELECTED_TEXT}}}$0",  desc = "italic" },
  { prefix = "te",  body = "\\emph{${1:${TM_SELECTED_TEXT}}}$0",    desc = "emph" },
  { prefix = "tt",  body = "\\texttt{${1:${TM_SELECTED_TEXT}}}$0",  desc = "monospace" },
  { prefix = "ul",  body = "\\underline{${1:${TM_SELECTED_TEXT}}}$0", desc = "underline" },
  { prefix = "tsc", body = "\\textsc{${1:${TM_SELECTED_TEXT}}}$0",  desc = "small caps" },
}
