return {
  { prefix = ";bash",
    body = {"```bash", "$1", "```"},
    desc = "Code block: Bash" },
  { prefix = ";sh",
    body = {"```sh", "$1", "```"},
    desc = "Code block: Shell" },
  { prefix = ";py",
    body = {"```py", "$1", "```"},
    desc = "Code block: Python" },
}

