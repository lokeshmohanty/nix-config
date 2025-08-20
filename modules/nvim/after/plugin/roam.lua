require("orgmode").setup({
  org_agenda_files = "~/Documents/Org/*",
  org_default_notes_file = "~/Documents/Org/notes.org",
  mappings = {
    global = {
      org_agenda = '<leader>na',
      org_capture = '<leader>nC'
    }
  }
})
-- Needs to be present in /after/ to prevent error during startup
require("org-roam").setup({ directory = "~/Documents/Org/Roam", })

