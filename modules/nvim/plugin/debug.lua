local dap = require('dap')

require('lze').load({{
  "dap-python",
  ft = "python",
  after = function (_)
    vim.cmd.packadd("nvim-dap-python")
    require("dap-python").setup("uv")
  end,
}})

-- Basic debugging keymaps, feel free to change to your liking!
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'Debug: Set Conditional Breakpoint' })
vim.keymap.set('n', '<leader>dq', dap.terminate, { desc = 'Debug: Terminate' })
vim.keymap.set('n', '<leader>dr', dap.restart, { desc = 'Debug: Terminate' })

vim.keymap.set('n', '<leader>du', "<cmd>DapViewToggle<cr>", { desc = 'Debug: Toggle UI' })

require('dap-view').setup({
  winbar = {
    show = true,
    sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
    -- sections = { "repl", "console" },
    default_section = "console",
    controls = {
      enabled = true,
      position = "right",
      buttons = {
        "play",
        "step_into",
        "step_over",
        "step_out",
        "step_back",
        "run_last",
        "terminate",
        "disconnect",
      },
      custom_buttons = {},
    },
  },
})

-- dap.listeners.after.event_initialized['dapui_config'] = dapui.open
-- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
-- dap.listeners.before.event_exited['dapui_config'] = dapui.close


require("nvim-dap-virtual-text").setup {
  enabled = true,                       -- enable this plugin (the default)
  enabled_commands = true,              -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
  highlight_changed_variables = true,   -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
  highlight_new_as_changed = false,     -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
  show_stop_reason = true,              -- show stop reason when stopped for exceptions
  commented = false,                    -- prefix virtual text with comment string
  only_first_definition = true,         -- only show virtual text at first definition (if there are multiple)
  all_references = false,               -- show virtual text on all all references of the variable (not only definitions)
  clear_on_continue = false,            -- clear virtual text on "continue" (might cause flickering when stepping)
  --- A callback that determines how a variable is displayed or whether it should be omitted
  --- variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
  --- buf number
  --- stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
  --- node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
  --- options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
  --- string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
  display_callback = function(variable, buf, stackframe, node, options)
    if options.virt_text_pos == 'inline' then
      return ' = ' .. variable.value
    else
      return variable.name .. ' = ' .. variable.value
    end
  end,
  -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
  virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

  -- experimental features:
  all_frames = false,       -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
  virt_lines = false,       -- show virtual lines instead of virtual text (will flicker!)
  virt_text_win_col = nil   -- position the virtual text at a fixed window column (starting from the first text column) ,
  -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
}
