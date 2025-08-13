-- Mini Files
require("mini.files").setup({})
vim.keymap.set("n", "<leader>,", "<cmd>lua MiniFiles.open()<cr>")
vim.keymap.set("n", "<leader>.", "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>")

local show_dotfiles = true
local filter_show = function(fs_entry)
	return true
end
local filter_hide = function(fs_entry)
	return not vim.startswith(fs_entry.name, ".")
end
local toggle_dotfiles = function()
	show_dotfiles = not show_dotfiles
	local new_filter = show_dotfiles and filter_show or filter_hide
	MiniFiles.refresh({ content = { filter = new_filter } })
end
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local buf_id = args.data.buf_id
		-- Tweak left-hand side of mapping to your liking
		vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
	end,
})

-- Oil.nvim
vim.g.loaded_netrwPlugin = 1

require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true
  },
  columns = {
    "icon",
    "permissions",
    "size",
    -- "mtime",
  },
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-s>"] = "actions.select_vsplit",
    ["<C-h>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["<C-l>"] = "actions.refresh",
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = "actions.tcd",
    ["gs"] = "actions.change_sort",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
    ["g\\"] = "actions.toggle_trash",
  },
})

vim.keymap.set("n", "-", "<cmd>Oil<CR>", { noremap = true, desc = 'Open Parent Directory' })
-- vim.keymap.set("n", "<leader>-", "<cmd>Oil .<CR>", { noremap = true, desc = 'Open nvim root directory' })
