-- Bibliography and cross-reference snippets

return {
  -- ── biblatex citations ────────────────────────────────────────────────────
  { prefix = "ci",    body = "\\cite{$1}$0",           desc = "\\cite" },
  { prefix = "aci",   body = "\\autocite{$1}$0",       desc = "\\autocite" },
  { prefix = "tci",   body = "\\textcite{$1}$0",       desc = "\\textcite (Jones 2020)" },
  { prefix = "pci",   body = "\\parencite{$1}$0",      desc = "\\parencite (Jones, 2020)" },
  { prefix = "fci",   body = "\\footcite{$1}$0",       desc = "\\footcite" },
  { prefix = "cit",   body = "\\citetitle{$1}$0",      desc = "\\citetitle" },
  { prefix = "cia",   body = "\\citeauthor{$1}$0",     desc = "\\citeauthor" },
  { prefix = "ciy",   body = "\\citeyear{$1}$0",       desc = "\\citeyear" },
  { prefix = "mcit",  body = "\\cites{$1}{$2}$0",      desc = "\\cites (multiple)" },

  -- ── Cross-references ──────────────────────────────────────────────────────
  { prefix = "ref",   body = "\\ref{$1}$0",            desc = "\\ref" },
  { prefix = "lref",  body = "\\label{$1}$0",          desc = "\\label" },
  { prefix = "eqr",   body = "\\eqref{$1}$0",          desc = "\\eqref (equation)" },
  { prefix = "cr",    body = "\\cref{$1}$0",            desc = "\\cref (cleveref)" },
  { prefix = "Cr",    body = "\\Cref{$1}$0",            desc = "\\Cref (capitalised)" },
  { prefix = "nr",    body = "\\nameref{$1}$0",         desc = "\\nameref" },
  { prefix = "ar",    body = "\\autoref{$1}$0",         desc = "\\autoref" },
  { prefix = "pgr",   body = "\\pageref{$1}$0",         desc = "\\pageref" },

  -- ── URL / hyperlinks ─────────────────────────────────────────────────────
  { prefix = "url",   body = "\\url{$1}$0",             desc = "\\url" },
  { prefix = "href",  body = "\\href{$1}{$2}$0",        desc = "\\href{url}{text}" },

  -- ── biblatex setup ────────────────────────────────────────────────────────
  {
    prefix = "bibsetup",
    body = {
      "\\usepackage[backend=biber, style=${1|authoryear,numeric,apa,ieee|}, sorting=nyt]{biblatex}",
      "\\addbibresource{${2:refs}.bib}$0",
    },
    desc = "biblatex setup",
  },
  { prefix = "printbib", body = "\\printbibliography$0",  desc = "\\printbibliography" },
}
