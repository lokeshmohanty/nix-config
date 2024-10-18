{ pkgs, ... }:

{
  home.packages = with pkgs; [ nvim-pkg ];
  # programs.neovim = {
  #   enable = true;
  #   viAlias = true;
  #   vimAlias = true;
  #   vimdiffAlias = true;
  #   # plugins = with pkgs.vimPlugins; [
  #   #   vim-commentary
  #   #   vim-surround
  #   #   vim-unimpaired
  #   #   nvim-treesitter.withAllGrammars
  #   #   telescope-nvim
  #   # ];
  #   # extraConfig = ''
  #   #   set number relativenumber
  #   # '';
  #   # extraConfig = lib.fileContents ../config/nvim/init.vim;
  # };
}
