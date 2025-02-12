{ pkgs, ... }: {
  vim = {
    useSystemClipboard = true;
    enableLuaLoader = true;
    luaConfigPost = "${builtins.readFile ./nvim.lua}";
    options = { 
      tabstop = 2; 
      shiftwidth = 0; 
      expandtab = true;
    };
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };
    keymaps = [
      { key = "<leader><leader>i"; mode = "n"; 
        action = "<cmd>IconPickerYank<cr>"; }
      { key = "<leader><leader>p"; mode = "n"; 
        action = "<cmd>MarkdownPreviewToggle<cr>"; }
      { key = "<leader>sd"; mode = "n";
        action = "<cmd>lua MiniFiles.open()<cr>"; }
      { key = "<leader>sf"; mode = "n";
        action = "<cmd>Pick files<cr>"; }
      { key = "<leader>sb"; mode = "n";
        action = "<cmd>Pick buffers<cr>"; }
      { key = "<leader>ss"; mode = "n";
        action = "<cmd>Pick grep_live<cr>"; }
      { key = "<leader>sm"; mode = "n";
        action = "<cmd>Neogit<cr>"; }

      # { key = "<localleader>mi"; mode = "n";
      #   action = "<cmd>MoltenInit<cr>"; }
      # { key = "<localleader>e"; mode = "n";
      #   action = "<cmd>MoltenEvaluateOperator<cr>"; }
      # { key = "<localleader>rl"; mode = "n";
      #   action = "<cmd>MoltenEvaluateLine<cr>"; }
      # { key = "<localleader>rr"; mode = "n";
      #   action = "<cmd>MoltenReevaluateCell<cr>"; }
      # { key = "<localleader>r"; mode = "v";
      #   action = "<cmd>MoltenEvaluateVisual<cr>"; }
      # { key = "<localleader>rd"; mode = "n";
      #   action = "<cmd>MoltenDelete<cr>"; }
      # { key = "<localleader>oh"; mode = "n";
      #   action = "<cmd>MoltenHideOutput<cr>"; }
      # { key = "<localleader>os"; mode = "n";
      #   action = "<cmd>MoltenEnterOuput<cr>"; }
    ];
    spellcheck.enable = false;
    spellcheck.programmingWordlist.enable = true;
    statusline.lualine.enable = true;
    autocomplete.nvim-cmp = {
      enable = true;
      mappings.next = "<C-n>";
      mappings.previous = "<C-p>";
    };

    terminal.toggleterm.enable = true;
    binds.whichKey.enable = true;
    dashboard.startify.enable = true;
    telescope.enable = true;
    projects.project-nvim.enable = true;

    snippets.luasnip.enable = true;
    treesitter.context.enable = true;

    # runner.run-nvim.enable = true;
    debugger.nvim-dap.enable = true;
    debugger.nvim-dap.ui.enable = true;
    lsp.enable = true;
    languages = {
      enableLSP = true;
      enableDAP = true;
      enableFormat = true;
      enableExtraDiagnostics = true;
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
      sessions.enable = true;
      # starter.enable = true;
    };
    utility = {
      # ccc.enable = true;
      icon-picker.enable = true;
      # diffview-nvim.enable = true;
      images.image-nvim.enable = true;
      images.image-nvim.setupOpts = {
        integrations.markdown.downloadRemoteImages = true;
      };
      surround.enable = true;
      outline.aerial-nvim.enable = true;
      preview.markdownPreview.enable = true;
    };

    ui = {
      borders.enable = false;
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
      neogit.package = neogit;
      jupytext.package = jupytext-nvim;
      jupytext.setup = "require('jupytext').setup()";
      quarto.package = quarto-nvim;
      molten = {
        package = molten-nvim;
        setup = ''
          vim.g.molten_image_provider = "image.nvim"
        '';
      };
    };
    withPython3 = true; withNodeJs = true;
    extraPackages = with pkgs; [ ripgrep imagemagick ];
    luaPackages = [ "magick" ];
    python3Packages = [
      "pynvim" 
      "jupyter-client" 
      "nbformat"
      "cairosvg" 
      "pnglatex"
      "plotly" 
      "pyperclip" 
    ];
  };
}
