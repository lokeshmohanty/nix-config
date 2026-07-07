-- TikZ and pgfplots snippets

return {
  -- ── TikZ ─────────────────────────────────────────────────────────────────
  {
    prefix = "tk",
    body = { "\\begin{tikzpicture}", "\t$0", "\\end{tikzpicture}" },
    desc = "tikzpicture",
  },
  {
    prefix = "tks",
    body = { "\\begin{tikzpicture}[scale=${1:1}]", "\t$0", "\\end{tikzpicture}" },
    desc = "tikzpicture (scaled)",
  },
  {
    prefix = "tkcd",
    body = {
      "\\begin{tikzcd}",
      "\t$1 \\arrow[r, \"$2\"] & $3 \\\\\\\\",
      "\t$4 \\arrow[u] & $5 \\arrow[u]",
      "\\end{tikzcd}$0",
    },
    desc = "tikz-cd commutative diagram",
  },

  -- ── TikZ drawing primitives ───────────────────────────────────────────────
  { prefix = "draw",   body = "\\draw${1:[options]} $0;",                    desc = "draw" },
  { prefix = "fill",   body = "\\fill${1:[options]} $0;",                    desc = "fill" },
  { prefix = "node",   body = "\\node${1:[options]} at ($2) {$3};$0",        desc = "node" },
  { prefix = "coord",  body = "\\coordinate (${1:name}) at ($2);$0",         desc = "coordinate" },
  { prefix = "scope",  body = { "\\begin{scope}[${1:options}]", "\t$0", "\\end{scope}" }, desc = "scope" },

  -- ── pgfplots ──────────────────────────────────────────────────────────────
  {
    prefix = "axis",
    body = {
      "\\begin{tikzpicture}",
      "\\begin{axis}[",
      "\ttitle={${1:Title}},",
      "\txlabel={$${2:x}$},",
      "\tylabel={$${3:y}$},",
      "\tlegend pos=north west,",
      "\tgrid=both,",
      "]",
      "$0",
      "\\end{axis}",
      "\\end{tikzpicture}",
    },
    desc = "pgfplots axis",
  },
  {
    prefix = "axis3",
    body = {
      "\\begin{tikzpicture}",
      "\\begin{axis}[",
      "\ttitle={${1:Title}},",
      "\txlabel={$${2:x}$},",
      "\tylabel={$${3:y}$},",
      "\tzlabel={$${4:z}$},",
      "\tview={${5:30}}{${6:30}},",
      "]",
      "$0",
      "\\end{axis}",
      "\\end{tikzpicture}",
    },
    desc = "pgfplots 3D axis",
  },
  {
    prefix = "addplot",
    body = {
      "\\addplot[${1:color=blue}]",
      "\texpression{${2:x^2}};",
      "\\addlegendentry{$${3:x^2}$}$0",
    },
    desc = "addplot expression",
  },
  {
    prefix = "addplot3",
    body = {
      "\\addplot3[${1|surf,mesh,contour filled|}]",
      "\texpression{${2:x^2+y^2}};$0",
    },
    desc = "addplot3",
  },
  {
    prefix = "plotcoords",
    body = {
      "\\addplot[${1:mark=*}]",
      "coordinates {${2:(0,0) (1,1) (2,4)}};$0",
    },
    desc = "addplot coordinates",
  },

  -- ── TikZ matrix ───────────────────────────────────────────────────────────
  {
    prefix = "tkmat",
    body = {
      "\\begin{tikzpicture}",
      "\\matrix (m) [matrix of math nodes, row sep=2em, column sep=2em] {",
      "\t$1 & $2 \\\\\\\\",
      "\t$3 & $4 \\\\\\\\",
      "};",
      "$0",
      "\\end{tikzpicture}",
    },
    desc = "tikz matrix",
  },
}
