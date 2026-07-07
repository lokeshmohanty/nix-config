-- AI/ML notation snippets (PhD-focused)
-- Most expand only in math context

return {
  -- ── Probability & Expectations ───────────────────────────────────────────
  { prefix = "EX",   body = "\\mathbb{E}\\left[$1\\right]$0",                       condition = 'math', desc = "E[·]" },
  { prefix = "EXp",  body = "\\mathbb{E}_{${1:x \\sim p}}\\left[$2\\right]$0",      condition = 'math', desc = "E_{x~p}[·]" },
  { prefix = "Var",  body = "\\mathrm{Var}\\left[$1\\right]$0",                      condition = 'math', desc = "Var[·]" },
  { prefix = "Cov",  body = "\\mathrm{Cov}\\left($1, $2\\right)$0",                 condition = 'math', desc = "Cov(·,·)" },
  { prefix = "Prb",  body = "\\mathbb{P}\\left($1\\right)$0",                        condition = 'math', desc = "P(·)" },
  { prefix = "Ent",  body = "H\\left($1\\right)$0",                                  condition = 'math', desc = "H(·) entropy" },

  -- ── KL Divergence ────────────────────────────────────────────────────────
  { prefix = "KL",   body = "D_{\\mathrm{KL}}\\left(${1:p} \\| ${2:q}\\right)$0",  condition = 'math', desc = "KL divergence" },
  { prefix = "KLr",  body = "D_{\\mathrm{KL}}\\left(${1:p} \\| ${2:q}\\right) = \\mathbb{E}_{x \\sim $1}\\left[\\log \\frac{$1(x)}{$2(x)}\\right]$0", condition = 'math', desc = "KL (expanded)" },

  -- ── ELBO / VAE ────────────────────────────────────────────────────────────
  { prefix = "ELBO", body = "\\mathcal{L}_{\\mathrm{ELBO}}$0",                       condition = 'math', desc = "ELBO" },
  {
    prefix = "elbo",
    body = "\\mathbb{E}_{q_{${1:\\phi}}(z|x)}\\left[\\log p_{${2:\\theta}}(x|z)\\right] - D_{\\mathrm{KL}}\\left(q_{$1}(z|x) \\| p(z)\\right)$0",
    condition = 'math',
    desc = "ELBO (full form)",
  },

  -- ── Score function / diffusion ────────────────────────────────────────────
  { prefix = "score",  body = "\\nabla_{${1:x}} \\log p(${2:x})$0",                condition = 'math', desc = "score function" },
  { prefix = "dff",    body = "d${1:x}_t = ${2:\\mu}(${3:x}_t, t)\\,dt + ${4:\\sigma}(t)\\,d${5:W}_t$0", condition = 'math', desc = "diffusion SDE" },
  { prefix = "noisep", body = "q(${1:x}_t | ${2:x}_0) = \\mathcal{N}(${1}_t; \\sqrt{${3:\\bar\\alpha}_t}\\,${2}_0,\\,(1-${3})\\,I)$0", condition = 'math', desc = "DDPM noise process" },

  -- ── MDP / RL ─────────────────────────────────────────────────────────────
  { prefix = "MDP",    body = "\\mathcal{M} = (\\mathcal{S}, \\mathcal{A}, P, r, \\gamma)$0", condition = 'math', desc = "MDP tuple" },
  { prefix = "pol",    body = "\\pi_{${1:\\theta}}(${2:a}|${3:s})$0",              condition = 'math', desc = "policy π_θ(a|s)" },
  { prefix = "Vpi",    body = "V^{${1:\\pi}}(${2:s})$0",                           condition = 'math', desc = "value function V^π" },
  { prefix = "Qpi",    body = "Q^{${1:\\pi}}(${2:s}, ${3:a})$0",                  condition = 'math', desc = "Q function Q^π(s,a)" },
  { prefix = "Aadv",   body = "A^{${1:\\pi}}(${2:s}, ${3:a}) = Q^{$1}($2,$3) - V^{$1}($2)$0", condition = 'math', desc = "advantage A^π" },
  { prefix = "bell",   body = "(\\mathcal{T}^\\pi Q)(s,a) = r(s,a) + \\gamma \\sum_{s'} P(s'|s,a)\\, V^\\pi(s')$0", condition = 'math', desc = "Bellman operator" },
  { prefix = "Ret",    body = "G_t = \\sum_{k=0}^{\\infty} \\gamma^k r_{t+k}$0",  condition = 'math', desc = "discounted return" },
  { prefix = "traj",   body = "\\tau = (s_0, a_0, s_1, a_1, \\ldots)$0",          condition = 'math', desc = "trajectory τ" },
  { prefix = "occ",    body = "d^\\pi(s) = (1-\\gamma)\\sum_{t=0}^\\infty \\gamma^t \\Pr(s_t = s | \\pi)$0", condition = 'math', desc = "occupancy measure" },

  -- ── Neural networks / attention ───────────────────────────────────────────
  { prefix = "attn",   body = "\\mathrm{Attn}(Q,K,V) = \\mathrm{softmax}\\!\\left(\\frac{QK^\\top}{\\sqrt{d_k}}\\right)V$0", condition = 'math', desc = "attention" },
  { prefix = "mhsa",   body = "\\mathrm{MHSA}(X) = \\mathrm{Concat}(\\mathrm{head}_1, \\ldots, \\mathrm{head}_h)W^O$0", condition = 'math', desc = "multi-head attention" },
  { prefix = "softm",  body = "\\mathrm{softmax}(${1:z})_i = \\frac{e^{${1}_i}}{\\sum_j e^{${1}_j}}$0", condition = 'math', desc = "softmax" },
  { prefix = "relu",   body = "\\mathrm{ReLU}(${1:x}) = \\max(0, ${1})$0",         condition = 'math', desc = "ReLU" },
  { prefix = "sigmoid",body = "\\sigma(${1:x}) = \\frac{1}{1 + e^{-${1}}}$0",      condition = 'math', desc = "sigmoid" },
  { prefix = "loss",   body = "\\mathcal{L}(${1:\\theta}) = $0",                    condition = 'math', desc = "loss ℒ(θ)" },
  { prefix = "param",  body = "\\theta \\in \\mathbb{R}^{${1:d}}$0",               condition = 'math', desc = "parameters θ" },

  -- ── Distributions ────────────────────────────────────────────────────────
  { prefix = "Norm",   body = "\\mathcal{N}\\left(${1:\\mu}, ${2:\\Sigma}\\right)$0",   condition = 'math', desc = "𝒩(μ,Σ)" },
  { prefix = "Bern",   body = "\\mathrm{Ber}(${1:p})$0",                                condition = 'math', desc = "Bernoulli" },
  { prefix = "Cat",    body = "\\mathrm{Cat}(${1:\\pi})$0",                              condition = 'math', desc = "Categorical" },
  { prefix = "Dir",    body = "\\mathrm{Dir}(${1:\\alpha})$0",                           condition = 'math', desc = "Dirichlet" },

  -- ── Norms / operators ─────────────────────────────────────────────────────
  { prefix = "Lnrm",   body = "\\|${1:x}\\|_{${2:2}}$0",                           condition = 'math', desc = "Lp norm" },
  { prefix = "Fnrm",   body = "\\|${1:A}\\|_F$0",                                  condition = 'math', desc = "Frobenius norm" },
  { prefix = "trace",  body = "\\mathrm{tr}\\left(${1:A}\\right)$0",               condition = 'math', desc = "trace" },
  { prefix = "diag",   body = "\\mathrm{diag}\\left(${1:v}\\right)$0",             condition = 'math', desc = "diag" },

  -- ── Environments for AI papers ────────────────────────────────────────────
  {
    prefix = "algo:rl",
    body = {
      "\\begin{algorithm}",
      "\t\\caption{${1:Algorithm Name}}",
      "\t\\label{alg:${2:label}}",
      "\t\\begin{algorithmic}[1]",
      "\t\t\\Require policy $\\pi_{\\theta}$, environment $\\mathcal{M}$",
      "\t\t\\For{episode $= 1, \\ldots, N$}",
      "\t\t\t\\State Sample trajectory $\\tau \\sim \\pi_{\\theta}$",
      "\t\t\t\\State Compute returns $G_t$",
      "\t\t\t\\State Update $\\theta \\leftarrow \\theta + \\alpha \\nabla_{\\theta} \\mathcal{L}(\\theta)$",
      "\t\t\\EndFor",
      "\t\\end{algorithmic}",
      "\\end{algorithm}$0",
    },
    desc = "RL algorithm template",
  },
}
