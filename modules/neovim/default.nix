{ pkgs, ... }: {
  
  vim = {
    viAlias = true;
    vimAlias = false;
    searchCase = "smart";
    useSystemClipboard = true;
    enableLuaLoader = true;
    withPython3 = true; 
    withNodeJs = true;
    additionalRuntimePaths = [ ./. ];
    luaConfigRC.myConfig = ''
      require("myConfig")
      require("neovide")
      require("illustrate")
    '';
    options = { 
      tabstop = 2; 
      shiftwidth = 0; 
      expandtab = true;
    };
    spellcheck.enable = false;
    spellcheck.programmingWordlist.enable = true;
    # autocomplete.nvim-cmp = {
    #   enable = true;
    #   mappings = {
    #     complete = "<C-l>";
    #     confirm = "<TAB>";
    #     next = "<C-n>";
    #     previous = "<C-p>";
    #   };
    # };

    debugger.nvim-dap.enable = true;
    debugger.nvim-dap.ui.enable = true;
    lsp.enable = true;
    languages = {
      enableLSP = true;
      enableDAP = true;
      enableFormat = true;
      enableExtraDiagnostics = false;
      enableTreesitter = true;

      nix.enable = true;
      clang.enable = true;
      python.enable = true;
      haskell.enable = true;
      markdown.enable = true;
      typst.enable = true;
      html.enable = true;
      lua.enable = true;
      ts.enable = true;
    };
    notes.orgmode.enable = true;
    binds.whichKey.enable = true;
    mini = {
      icons.enable = true;
      files.enable = true;
      basics.enable = true;
      pairs.enable = true;
      indentscope.enable = true;
      comment.enable = true;
      notify.enable = true;
      bracketed.enable = true;
      sessions.enable = true;
      statusline.enable = true;
      sessions.setupOpts = { directory = "~/.config/nvf/sessions"; };
      starter.enable = true;
      tabline.enable = true;
      completion.enable = true;
      snippets.enable = true;
    };
    fzf-lua.enable = true;
    utility = {
      ccc.enable = true;
      icon-picker.enable = true;       # :IconPicker
      diffview-nvim.enable = true;     # :Diffview
      surround.enable = true;
      surround.useVendoredKeybindings = false;
      outline.aerial-nvim.enable = true;
      preview.markdownPreview.enable = true;
    };
    ui = {
      borders.enable = false;
      noice.enable = true;
      colorizer.enable = true;
      fastaction.enable = true;
    };
    lazy.plugins = {
      vimtex = {
        enabled = true;
        package = pkgs.vimPlugins.vimtex;
        lazy = true;
        ft = "tex";
        after =  ''
          vim.api.nvim_command('unlet b:did_ftplugin')
          vim.api.nvim_command('call vimtex#init()')
        '';
      };
    };
    startPlugins = with pkgs.vimPlugins; [
      render-markdown-nvim  # good markdown rendering
      neogit                # magit alternative
      vim-repeat
      jupytext-nvim         # convert ipynb to markdown
      bullets-vim           # markdown insert bulleted lists ...
      img-clip-nvim         # drag n drop images
      vim-floaterm          # terminal
      yazi-nvim             # file manager
      lsp_signature-nvim    # display lsp function signature
      nabla-nvim            # display math expression
      leetcode-nvim         # enable to solve leetcode problems

      # Colorschemes
      (let
        everforest-nvim = pkgs.vimUtils.buildVimPlugin {
          name = "everforest-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "neanias";
            repo = "everforest-nvim";
            rev = "135cc21a45756e688dd1a3cbeb1c80a04b569b46";
            hash = "sha256-X+GaH76afaWmszGuLYf9VHP134jvmUCVSB7C7aiPSOs=";
          };
        };
      in everforest-nvim)
    ];
    extraPlugins = with pkgs.vimPlugins; {
      lazydev = {  # neovim library for lua lsp
        package = lazydev-nvim;
        setup = "require('lazydev').setup {}";
      };
    };
    extraPackages = with pkgs; [ 
      ripgrep 
      imagemagick 
      ueberzugpp
      basedpyright
      tree-sitter
      texlab
      typescript-language-server
    ];
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
