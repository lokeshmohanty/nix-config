{ pkgs, ... }: {
  vim = {
    options = { 
      tabstop = 2; 
      shiftwidth = 0; 
    };
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };
    keymaps = [
      { key = "<leader><leader>i"; mode = "n"; 
        action = "<cmd>IconPickerYank<cr>"; }
      { key = "<leader><leader>a"; mode = "n"; 
        action = "<cmd>AerialToggle<cr>"; }
      { key = "<leader>ad"; mode = "n";
        action = "<cmd>lua MiniFiles.open()<cr>"; }
      { key = "<leader>af"; mode = "n";
        action = "<cmd>Pick files<cr>"; }
      { key = "<leader>ab"; mode = "n";
        action = "<cmd>Pick buffers<cr>"; }
      { key = "<leader>ag"; mode = "n";
        action = "<cmd>Neogit<cr>"; }
    ];
    statusline.lualine.enable = true;
    autocomplete.nvim-cmp = {
      enable = true;
      mappings.next = "<C-n>";
      mappings.previous = "<C-p>";
    };

    binds.whichKey.enable = true;
    telescope.enable = true;

    snippets.luasnip.enable = true;
    treesitter.context.enable = true;

    languages = {
      enableLSP = true;
      enableTreesitter = true;

      nix.enable = true;
      clang.enable = true;
      python.enable = true;
      haskell.enable = true;
      # rust.enable = true;
      markdown.enable = true;
      html.enable = true;
      lua.enable = true;
    };
    # notify.nvim-notify.enable = true;
    notes.orgmode.enable = true;

    mini = {
      icons.enable = true;
      files.enable = true;
      basics.enable = true;
      surround.enable = true;
      pairs.enable = true;
      comment.enable = true;
      bracketed.enable = true;
      move.enable = true;
      jump2d.enable = true;
      notify.enable = true;
      pick.enable = true;
    };
    utility = {
      ccc.enable = true;
      icon-picker.enable = true;
      diffview-nvim.enable = true;

      # images.image-nvim.enable = true;
    };

    ui = {
      borders.enable = true;
      noice.enable = false;
      colorizer.enable = true;
      fastaction.enable = true;
    };

    assistant = {
      copilot = {
        enable = true;
        cmp.enable = true;
      };
    };

    # can use lazy.plugins as well
    extraPlugins = with pkgs.vimPlugins; {
      aerial = {
        package = aerial-nvim;
        setup = "require('aerial').setup {}";
      };
      neogit.package = neogit;
    };
  };
}
