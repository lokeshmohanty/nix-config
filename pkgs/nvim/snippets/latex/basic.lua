return {
  { prefix = "_", body = "_{${1:${TM_SELECTED_TEXT}}}", desc = "subscript" },
  { prefix = "^", body = "^{${1:${TM_SELECTED_TEXT}}}", desc = "superscript" },
  {
    prefix = { "ali*" },
    body = { "\\begin{align*}", "\t$1", "\\end{align*}$0" },
    desc = "Create an align environment when the context is in the text environment."
  },
  {
    prefix = "ali",
    body = { "\\begin{align}", "\t$0", "\\end{align}" },
    desc = "Align(ed)"
  },
  {
    prefix = "cases",
    body = {
      "\\begin{cases}",
      "\t${1:equation}, &\\text{ if }${2:case}\\\\\\\\",
      "\t$0",
      "\\end{cases}"
    },
    desc = "Cases"
  },
  desc = {
    prefix = "desc",
    body = {
      "\\\\begin{description}",
      "\t\\item{ $1 } $0",
      "\\\\end{description}"
    },
    desc = "Description"
  },
  {
    prefix = "math",
    body = { "\\begin{math}", "\t$1", "\\end{math}", "$0" },
    desc = "Add a Math"
  },
  {
    prefix = "dm",
    body = { "\\begin{displaymath}", "\t$1", "\\end{displaymath}", "$0" },
    desc = "Display Math"
  },
  {
    prefix = "eq",
    body = {
      "\\begin{equation}",
      "\t$0",
      "\t\\label{eq:$1}",
      "\\end{equation}"
    },
    desc = "Add a Equation"
  },
  {
    prefix = "$$",
    body = { "\\[", "\t$TM_SELECTED_TEXT$1", "\\]" },
    desc = "Display Math"
  },
  {
    prefix = "theorem",
    body = {
      "\\begin{theorem}",
      "\t$1",
      "\t\\begin{displaymath}",
      "\t\t$2",
      "\t\\end{displaymath}",
      "\t$3",
      "\\end{theorem}",
      "$0"
    },
    desc = "Add a theorem"
  },
  {
    prefix = "definition",
    body = {
      "\\begin{definition}",
      "\t$1",
      "\t\\begin{displaymath}",
      "\t\t$2",
      "\t\\end{displaymath}",
      "\t$3",
      "\\end{definition}",
      "$0"
    },
    desc = "Add a definition"
  },
  {
    prefix = "proof",
    body = {
      "\\begin{proof}",
      "\t$1",
      "\t\\begin{displaymath}",
      "\t\t$2",
      "\t\\end{displaymath}",
      "\t$3",
      "\\end{proof}",
      "$0"
    },
    desc = "Add a proof"
  },
  {
    prefix = "algo",
    body = {
      "% \\usepackage{algorithm,algorithmicx,algpseudocode}",
      "\\begin{algorithm}",
      "\t\\floatname{algorithm}{${1:Algorithm}}",
      "\t\\algrenewcommand\\algorithmicrequire{\\textbf{${2:Input: }}}",
      "\t\\algrenewcommand\\algorithmicensure{\\textbf{${3:Output: }}}",
      "\t\\caption{$4}\\label{alg:$5}",
      "\t\\begin{algorithmic}{ 1 }",
      "\t\t\\Require \\$input\\$",
      "\t\t\\Ensure \\$output\\$",
      "\t\t$6",
      "\t\t\\State \\textbf{return} \\$state\\$",
      "\t\\end{algorithmic}",
      "\\end{algorithm}",
      "$0"
    },
    desc = "Add an algorithm"
  },
  {
    prefix = "cite",
    body = { "\\cite{$1}$0" },
    desc = "Add a cite"
  },
  {
    prefix = "empty",
    body = { "\\null\\thispagestyle{empty}", "\\newpage", "$0" },
    desc = "Add a empty page"
  },
  {
    prefix = "it",
    body = "\n\\item ",
    desc = "\\item on a newline"
  },
  {
    prefix = "_",
    body = "_{${1:${TM_SELECTED_TEXT}}}",
    desc = "subscript"
  },
  {
    prefix = "^",
    body = "^{${1:${TM_SELECTED_TEXT}}}",
    desc = "superscript"
  },

  {
    prefix = "eq",
    body = "\\begin{equation}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{equation}",
    desc = "equation environment"
  },
  {
    prefix = "eq*",
    body = "\\begin{equation*}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{equation*}",
    desc = "equation* environment"
  },
  {
    prefix = "al",
    body = "\\begin{align}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{align}",
    desc = "align environment"
  },
  {
    prefix = "al*",
    body = "\\begin{align*}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{align*}",
    desc = "align* environment"
  },
  {
    prefix = "ga",
    body = "\\begin{gather}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{gather}",
    desc = "gather environment"
  },
  {
    prefix = "ga*",
    body = "\\begin{gather*}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{gather*}",
    desc = "gather* environment"
  },
  {
    prefix = "multline",
    body = "\\begin{multline}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{multline}",
    desc = "multline environment"
  },
  {
    prefix = "multline*",
    body = "\\begin{multline*}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{multline*}",
    desc = "multline* environment"
  },
  {
    prefix = "ite",
    body = "\\begin{itemize}\n\t\\item ${0:${TM_SELECTED_TEXT}}\n\\end{itemize}",
    desc = "itemize environment"
  },
  {
    prefix = "enu",
    body = "\\begin{enumerate}\n\t\\item ${0:${TM_SELECTED_TEXT}}\n\\end{enumerate}",
    desc = "enumerate environment"
  },
  {
    prefix = "sp",
    body = "\\begin{split}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{split}",
    desc = "split environment"
  },
  {
    prefix = "cases",
    body = "\\begin{cases}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{cases}",
    desc = "cases environment"
  },
  {
    prefix = "fr",
    body = "\\begin{frame}\n\t\\frametitle{${1:<title>}}\n\n\t${0:${TM_SELECTED_TEXT}}\n\n\\end{frame}",
    desc = "frame"
  },
  {
    prefix = "fig",
    body = "\\begin{figure}{ ${1:htbp} }\n\t\\centering\n\t${0:${TM_SELECTED_TEXT}}\n\t\\caption{${2:<caption>}}\\label{${3:<label>}}\n\\end{figure}",
    desc = "figure"
  },
  {
    prefix = "tab",
    body = "\\begin{table}{ ${1:htbp} }\n\t\\centering\\begin{tabular}{${4:<columns>}}\n\t\t${0:${TM_SELECTED_TEXT}}\n\t\\end{tabular}\n\t\\caption{${2:<caption>}}\\label{${3:<label>}}\n\\end{table}",
    desc = "table"
  },
  {
    prefix = "tk",
    body = "\\begin{tikzpicture}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{tikzpicture}",
    desc = "tikzpicture"
  },
  {
    prefix = "fs",
    body = "${1|\\Huge,\\huge,\\LARGE,\\Large,\\large,\\normalsize,\\small,\\footnotesize,\\scriptsize,\\tiny|}",
    desc = "Select a font size"
  },
  {
    prefix = "tno",
    body = "\\textnormal{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "normal font"
  },
  {
    prefix = "trm",
    body = "\\textrm{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "roman font"
  },
  {
    prefix = "emph",
    body = "\\emph{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "emphasis font"
  },
  {
    prefix = "tsf",
    body = "\\textsf{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "sans serif font"
  },
  {
    prefix = "ttt",
    body = "\\texttt{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "typewriter font"
  },
  {
    prefix = "tit",
    body = "\\textit{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "italic font"
  },
  {
    prefix = "tsl",
    body = "\\textsl{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "slanted font"
  },
  {
    prefix = "tsc",
    body = "\\textsc{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "smallcaps font"
  },
  {
    prefix = "ul",
    body = "\\underline{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "Underline text"
  },
  {
    prefix = "uc",
    body = "\\uppercase{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "Make text uppercase (all caps)"
  },
  {
    prefix = "lc",
    body = "\\lowercase{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "Make text lowercase (no caps)"
  },
  {
    prefix = "tb",
    body = "\\textbf{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "bold font"
  },
  {
    prefix = "t^",
    body = "\\textsuperscript{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "Make text a superscript"
  },
  {
    prefix = "t_",
    body = "\\textsubscript{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "Make text a superscript"
  },
  {
    prefix = "mrm",
    body = "\\mathrm{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "math roman font"
  },
  {
    prefix = "mbf",
    body = "\\mathbf{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "math bold font"
  },
  {
    prefix = "mbb",
    body = "\\mathbb{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "math blackboard bold font"
  },
  {
    prefix = "mc",
    body = "\\mathcal{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "math caligraphic font"
  },
  {
    prefix = "mit",
    body = "\\mathit{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "math italic font"
  },
  {
    prefix = "mtt",
    body = "\\mathtt{${1:${TM_SELECTED_TEXT:text}}}",
    desc = "math typewriter font"
  },
  {
    prefix = "(",
    body = "\\left( ${1:${TM_SELECTED_TEXT}} \\right)",
    desc = "left( ... right)"
  },
  {
    prefix = "{",
    body = "\\left\\{ ${1:${TM_SELECTED_TEXT}} \\right\\\\\\}",
    desc = "left{ ... right}"
  },
  {
    prefix = "[",
    body = "\\left{  ${1:${TM_SELECTED_TEXT}} \\right }",
    desc = "left{  ... right }"
  },
  {
    prefix = "beg",
    body = "\n\\begin{$1}\n\t${0:${TM_SELECTED_TEXT}}\n\\end{$1}",
    desc = "Wrap selection into an environment"
  },
  {
    prefix = "part",
    body = "\\part{${1:${TM_SELECTED_TEXT}}}",
    desc = "part"
  },
  {
    prefix = "chap",
    body = "\\chapter{${1:${TM_SELECTED_TEXT}}}",
    desc = "chapter"
  },
  {
    prefix = "s",
    body = "\\section{${1:${TM_SELECTED_TEXT}}}",
    desc = "section"
  },
  {
    prefix = "ss",
    body = "\\subsection{${1:${TM_SELECTED_TEXT}}}",
    desc = "subsection"
  },
  {
    prefix = "sss",
    body = "\\subsubsection{${1:${TM_SELECTED_TEXT}}}",
    desc = "subsubsection"
  },
  {
    prefix = "pg",
    body = "\\paragraph{${1:${TM_SELECTED_TEXT}}}",
    desc = "paragraph"
  },
  {
    prefix = "spg",
    body = "\\subparagraph{${1:${TM_SELECTED_TEXT}}}",
    desc = "subparagraph"
  },

  {
    prefix = { "sumlarge", "\\sumlarge" },
    body = { "\\displaystyle\\sum_{$1}^{$2}$3" },
    desc = "Insert a large summation notation."
  },
  {
    prefix = { "sum", "\\suminline" },
    body = { "\\sum_{$1}^{$2}$3" },
    desc = "Insert an inline summation notation, (only in the cases when the environment is inline math environment)."
  },
  {
    prefix = { "ml", "\\mathinline" },
    body = { "\\$ $1 \\$$0" },
    desc = "Insert inline Math Environment."
  },
  {
    prefix = { "mc", "\\mathcentered" },
    body = { "\\$$ $0 \\$$" },
    desc = "Insert centered Math Environment."
  },
  {
    prefix = { "sec", "\\sec" },
    body = { "\\section{$1}$0" },
    desc = "Insert a new section."
  },
  {
    prefix = { "subsection", "\\subsection" },
    body = { "\\subsection{$1}$0" },
    desc = "Insert a new subsection."
  },
  {
    prefix = { "header", "\\header", "##" },
    body = "\\section*{$1}$0",
    desc = "Insert a section without index."
  },
  {
    prefix = { "headersmall", "\\headersmall", "###" },
    body = "\\subsection*{$1}$0",
    desc = "Insert a subsection without index."
  },
  {
    prefix = { "italic", "\\italic", "*" },
    body = "\\textit{$1}$0",
    desc = "Insert italic text."
  },
  {
    prefix = { "bold", "\\bold", "**" },
    body = "\\textbf{$1}$0",
    desc = "Insert bold text."
  },
  {
    prefix = { "bolditalic", "\\bolditalic", "***" },
    body = "\\textbf{\\textit{$1}}$0",
    desc = "Insert bold italic text."
  },
  {
    prefix = { "- ", "\\itemize", "itemize" },
    body = { "\\begin{itemize}", "\t\\item $1", "\\end{itemize}$0" }
  },
  {
    prefix = { "to", "\\to" },
    body = { "^ {$1}$0" },
    desc = "Superscript notation, as well as the power notation."
  },
  {
    prefix = { "theorem", "\\theorem" },
    body = {
      "\\begin{theorem}{ ${1:name of the theorem} }",
      "\t$0",
      "\\end{theorem}"
    },
    desc = "Insert a theorem, whose style is already defined in the template. The serial number is automatically generated according to the section."
  },
  {
    prefix = { "problem", "\\problem" },
    body = {
      "\\begin{problem}{ ${1:name of the problem} }",
      "\t$0",
      "\\end{problem}"
    },
    desc = "Insert a problem, whose style is already defined in the template. The serial number is automatically generated according to the section."
  },
  {
    prefix = { "tab", "\\tab" },
    body = { "\\indent " },
    desc = "The equivalent of \"\\t\", also known as \"Tab\""
  },
  {
    prefix = { "definition", "\\definition" },
    body = {
      "\\begin{definition}{ ${1:name of the definition} }",
      "\t$0",
      "\\end{definition}"
    },
    desc = "Insert a definition, whose style is already defined in the template. The serial number is automatically generated according to the section."
  },
  {
    prefix = { "proof", "\\proof" },
    body = {
      "\\begin{proof}{ Proof ${1:Other Information} }",
      "\t$0",
      "\\end{proof}"
    },
    desc = "Insert a proof, whose style is already defined in the template. The serial number is automatically generated according to the section."
  },
  {
    prefix = { "integrallarge", "\\integrallarge" },
    body = { "\\displaystyle\\int_{$1}^{$2}$3" },
    desc = "Insert large integral notation."
  },
  {
    prefix = { "integralinline", "\\integralinline" },
    body = { "\\int_{$1}^{$2}$3" },
    desc = "Insert inline integral notation, (only in the cases when the environment is inline math environment)."
  },
  {
    prefix = { "fractioninline", "\\fractioninline" },
    body = { "\\frac{$1}{$2}$0" },
    desc = {
      "Insert inline fraction notation, (only in the cases when the environment is inline math environment)."
    }
  },
  {
    prefix = { "fractionlarge", "\\fractionlarge" },
    body = { "\\displaystyle\\frac{$1}{$2}$0" },
    desc = { "Insert large fraction notation" }
  },
  {
    prefix = { "plotenvironment2d", "\\plotenvironment2d" },
    body = {
      "\\begin{tikzpicture}",
      "\\begin{axis}[",
      "legend pos=outer north east,",
      "title=${1:Example},",
      "axis lines =${2| box, left, middle, center, right, none|},",
      "xlabel = \\$x\\$,",
      "ylabel = \\$y\\$,",
      "variable = t,",
      "trig format plots = rad,",
      "]",
      "$3",
      "\\end{axis}",
      "\\end{tikzpicture}$0"
    },
    desc = "Create a 2DPlot Environment of pgfplots. The style declarations are already included in the snippet."
  },
  {
    prefix = { "plotgraph2d", "\\plotgraph2d" },
    body = {
      "\\addplot [",
      "\tdomain=${1:-10}:${2:10},",
      "\tsamples=70,",
      "\tcolor=${3:blue},",
      "\t]",
      "\t{${4:x^2 + 2*x + 1}};",
      "\\addlegendentry{\\$${5:x^2 + 2x + 1}\\$}",
      "$0"
    },
    desc = "Plot a 2D Graph in the 2D graph environment, noted that this can also be used in the 3D environment."
  },
  {
    prefix = { "plotcircle2d", "\\plotcircle2d" },
    body = {
      "\\addplot [",
      "\tdomain=0:2*3.14159265,",
      "\tsamples=70,",
      "\tcolor=${4:blue},",
      "\t]",
      "\t({${1:r}*cos(t)+${2:a}},{${1:r}*sin(t)+${3:b}});",
      "\\addlegendentry{\\$(x-${2:a})^2+(y-${3:b})^2=${1:r}^2\\$}$0"
    },
    desc = "Plot a 2D Circle in the 2D graph environment, noted that this can also be used in the 3D environment."
  },
  {
    prefix = { "plotline2d", "\\plotline2d" },
    body = {
      "\\addplot [",
      "\tdomain=${4:x1}:${5:x2},",
      "\tsamples=70,",
      "\tcolor=${3:blue},",
      "\t]",
      "\t{${1:a}*x+${2:b}};",
      "\\addlegendentry{\\$ y=${1:a}x+${2:b}\\$}$0"
    },
    desc = "Plot a 2D Line in the 2D graph environment, noted that this can also be used in the 3D environment."
  },
  {
    prefix = { "plotellipse2d", "\\plotellipse2d" },
    body = {
      "\\addplot [",
      "\tdomain=0:2*3.14159265,",
      "\tsamples=70,",
      "\tcolor=${5:blue},",
      "\t]",
      "\t({${1:a}*cos(t)+${3:x}},{${2:b}*sin(t)+${4:y}});",
      "\\addlegendentry{\\$\\frac{(x-${3:x})^2}{${1:a}^2}+\\frac{(y-${4:y})^2}{${2:b}^2}=1\\$}$0"
    },
    desc = "Plot a 2D Ellipse in the 2D graph environment, noted that this can also be used in the 3D environment."
  },
  {
    prefix = {
      "plotquadraticfunction2dbypoint",
      "\\plotquadraticfunction2dbypoint"
    },
    body = {
      "\\addplot [",
      "\tdomain=${4:x1}:${5:x2},",
      "\tsamples=70,",
      "\tcolor=${6:blue},",
      "\t]",
      "\t{${1:a}*(x-${2:m})*(x-${2:m})+${3:b}};",
      "\\addlegendentry{\\$ y=${1:a}(x-${2:m})^2+${3:b}\\$}$0"
    },
    desc = "Plot a 2D graph of a quadratic function in the 2D graph environment by the given extrema, noted that this can also be used in the 3D environment."
  },
  {
    prefix = { "plotsmoothcurvebypointset", "\\plotsmoothcurvebypointset" },
    body = {
      "\\addplot+{ smooth }",
      "coordinates",
      "{",
      "${1:seperate the coordinates with spaces}",
      "};$0"
    },
    desc = "Plot a Smooth Curve by point set (2D)."
  },
  {
    prefix = { "plotenvironment3d", "\\plotenvironment3d" },
    body = {
      "\\begin{tikzpicture}",
      "\\begin{axis}[",
      "legend pos=outer north east,",
      "title=${1:Example},",
      "axis lines =${2| box, left, middle, center, right, none|},",
      "colormap/${3|hot,hot2,jet,blackwhite,bluered,cool,greenyellow,redyellow,violet|},",
      "xlabel = \\$x\\$,",
      "ylabel = \\$y\\$,",
      "zlabel = \\$z\\$,",
      "variable = t,",
      "trig format plots = rad,",
      "]",
      "$4",
      "\\end{axis}",
      "\\end{tikzpicture}$0"
    },
    desc = "Create a 3DPlot Environment of pgfplots. The style declarations are already included in the snippet."
  },
  {
    prefix = { "plotgraph3d", "\\plotgraph3d" },
    body = {
      "\\addplot3[",
      "\t${1|surf,mesh|},",
      "\tsamples=50,",
      "]",
      "{${2:x^2+y^2}};",
      "\\addlegendentry{\\$${3:x}\\$}$0"
    },
    desc = "Plot a 3D Graph in the 3D graph environment created."
  },
  {
    prefix = "state",
    body = { "\\State $1" },
    desc = "Add an statement of algorithm"
  },
  {
    prefix = "if",
    body = { "\\If{$1}", "\\ElsIf{$2}", "\\Else", "\\EndIf" },
    desc = "Add an if statement of algorithm"
  },
  {
    prefix = "for",
    body = { "\\For{i=0:$1}", "\t\\State $0", "\\EndFor" },
    desc = "Add an for statement of algorithm"
  },
  {
    prefix = "while",
    body = { "\\While{$1}", "\t\\State $0", "\\EndWhile" },
    desc = "Add an for statement of algorithm"
  },
  {
    prefix = "algo:ref",
    body = { "${1:Algorithm}~\\ref{algo:$2}$0" },
    desc = "Ref for Algorithm"
  },
  {
    prefix = "figure:ref",
    body = { "${1:Figure}~\\ref{fig:$2}$0" },
    desc = "Ref for Figure"
  },
  {
    prefix = "gat",
    body = { "\\begin{gather}", "\t$0", "\\end{gather}" },
    desc = "Gather(ed)"
  },
  {
    prefix = "item",
    body = { "\\\\begin{itemize}", "\t\\item $0", "\\\\end{itemize}" },
    desc = "Itemize"
  },
  {
    prefix = "listing:ref",
    body = { "${1:Listing}~\\ref{lst:$2}$0" },
    desc = "Listing"
  },
  {
    prefix = "mat",
    body = {
      "\\begin{${1:p/b/v/V/B/small}matrix}",
      "\t$0",
      "\\end{${1:p/b/v/V/B/small}matrix}"
    },
    desc = "Matrix"
  },
  {
    prefix = "page",
    body = { "${1:page}~\\pageref{$2}$0" },
    desc = "Page"
  },
  {
    prefix = "par",
    body = {
      "\\paragraph{${1:paragraph name}}\\label{par:${1/({ a-zA-Z]+)|([^a-zA-Z }+)/${1:/downcase}${2:+_}/g}} % (fold)",
      "${0:$TM_SELECTED_TEXT}",
      "% paragraph $1 (end)"
    },
    desc = "Paragraph"
  },
  {
    prefix = "part",
    body = {
      "\\part{${1:part name}}\\label{prt:${1/({ a-zA-Z]+)|([^a-zA-Z }+)/${1:/downcase}${2:+_}/g}} % (fold)",
      "${0:$TM_SELECTED_TEXT}",
      "% part $1 (end)"
    },
    desc = "Part"
  },
  {
    prefix = "#region",
    body = { "%#Region $0" },
    desc = "Folding Region Start"
  },
  {
    prefix = "#endregion",
    body = { "%#Endregion" },
    desc = "Folding Region End"
  },
  {
    prefix = "section:ref",
    body = { "${1:Section}~\\ref{sec:$2}$0" },
    desc = "Section Reference"
  },
  {
    prefix = "spl",
    body = { "\\begin{split}", "\t$0", "\\end{split}" },
    desc = "Split"
  },
  {
    prefix = "sec",
    body = {
      "\\section{$1}\\label{sec:${1/({ a-zA-Z]+)|([^a-zA-Z }+)/${1:/downcase}${2:+_}/g}} % (fold)",
      "${0:$TM_SELECTED_TEXT}",
      "% section $1 (end)"
    },
    desc = "Section"
  },
  {
    prefix = "subp",
    body = {
      "\\subparagraph{$1}\\label{subp:${1/({ a-zA-Z]+)|([^a-zA-Z }+)/${1:/downcase}${2:+_}/g}} % (fold)",
      "${0:$TM_SELECTED_TEXT}",
      "% subparagraph $1 (end)"
    },
    desc = "Sub Paragraph"
  },
  {
    prefix = "sub",
    body = {
      "\\subsection{$1}\\label{sub:${1/({ a-zA-Z]+)|([^a-zA-Z }+)/${1:/downcase}${2:+_}/g}} % (fold)",
      "${0:$TM_SELECTED_TEXT}",
      "% subsection $1 (end)"
    },
    desc = "Sub Section"
  },
  {
    prefix = "subs",
    body = {
      "\\subsubsection{${1:subsubsection name}}\\label{sec:${1/({ a-zA-Z]+)|([^a-zA-Z }+)/${1:/downcase}${2:+_}/g}} % (fold)",
      "${0:$TM_SELECTED_TEXT}",
      "% subsubsection $1 (end)"
    },
    desc = "Sub Sub Section"
  },
  {
    prefix = "table:ref",
    body = { "${1:Table}~\\ref{tab:$2}$0" },
    desc = "Table Reference"
  },
  {
    prefix = "tab",
    body = {
      "\\\\begin{${1:t}${1/(t)$|(a)$|(.*)/(?1:abular)(?2:rray)/}}{${2:c}}",
      "$0${2/((?<={ clr])([ | }*(c|l|r)))|./(?1: & )/g}",
      "\\\\end{${1:t}${1/(t)$|(a)$|(.*)/(?1:abular)(?2:rray)/}}"
    },
    desc = "Tabular"
  },
  {
    prefix = "begin",
    body = {
      "\\\\begin{${1:env}}",
      "\t${1/(enumerate|itemize|list)|(description)|(.*)/${1:+\\item }${2:+\\item{  } }${3:+}/}$0",
      "\\\\end{${1:env}}"
    },
    desc = "Begin - End"
  },
  {
    prefix = "figure",
    body = {
      "\\begin{figure}",
      "\t\\begin{center}",
      "\t\t\\includegraphics{ width=0.95\\textwidth }{figures/$1}",
      "\t\\end{center}",
      "\t\\caption{$3}\\label{fig:$4}",
      "\\end{figure}",
      "$0"
    },
    desc = "Add a figure"
  },
  {
    prefix = "figure:acm",
    body = {
      "\\begin{figure}",
      "\t\\includegraphics{ width=0.45\\textwidth }{figures/$1}",
      "\t\\caption{$2}\\label{fig:$3}",
      "\\end{figure}",
      "$0"
    },
    desc = "Add a figure (ACM)"
  },
  {
    prefix = "figure:acm:*",
    body = {
      "\\begin{figure*}",
      "\t\\includegraphics{ width=0.45\\textwidth }{figures/$1}",
      "\t\\caption{$2}\\label{fig:$3}",
      "\\end{figure*}",
      "$0"
    },
    desc = "Add a figure (ACM)"
  },
  {
    prefix = "table",
    body = {
      "\\begin{table}",
      "\t\\caption{$1}\\label{tab:$2}",
      "\t\\begin{center}",
      "\t\t\\begin{tabular}{ c }{l|l}",
      "\t\t\t\\hline",
      "\t\t\t\\multicolumn{1}{c|}{\\textbf{$3}} & ",
      "\t\t\t\\multicolumn{1}{c}{\\textbf{$4}} \\\\\\\\",
      "\t\t\t\\hline",
      "\t\t\ta & b \\\\\\\\",
      "\t\t\tc & d \\\\\\\\",
      "\t\t\t$5",
      "\t\t\t\\hline",
      "\t\t\\end{tabular}",
      "\t\\end{center}",
      "\\end{table}",
      "$0"
    },
    desc = "Add a table"
  },
  {
    prefix = "table:acm",
    body = {
      "\\begin{table}",
      "\t\\caption{$1}\\label{tab:$2}",
      "\t\\begin{tabular}{${3:ccl}}",
      "\t\t\\toprule",
      "\t\t$4",
      "\t\ta & b & c \\\\\\\\",
      "\t\t\\midrule",
      "\t\td & e & f \\\\\\\\",
      "\t\t\\bottomrule",
      "\t\\end{tabular}",
      "\\end{table}",
      "$0"
    },
    desc = "Add a table (ACM)"
  },
  {
    prefix = "table:acm:*",
    body = {
      "\\begin{table*}",
      "\t\\caption{$1}\\label{tab:$2}",
      "\t\\begin{tabular}{${3:ccl}}",
      "\t\t\\toprule",
      "\t\t$4",
      "\t\ta & b & c \\\\\\\\",
      "\t\t\\midrule",
      "\t\td & e & f \\\\\\\\",
      "\t\t\\bottomrule",
      "\t\\end{tabular}",
      "\\end{table*}",
      "$0"
    },
    desc = "Add a table (ACM)"
  },
  {
    prefix = "enumerate",
    body = { "\\\\begin{enumerate}", "\t\\item $0", "\\\\end{enumerate}" },
    desc = "Add a enumerate"
  },
  {
    prefix = "compactitem",
    body = {
      "\\begin{compactitem}",
      "\t\\item $1",
      "\\end{compactitem}",
      "$0"
    },
    desc = "Add a compactitem (from package paralist)"
  },
}

