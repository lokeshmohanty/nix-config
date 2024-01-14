{ pkgs, ... }:

{
  programs.neovim = {
    enable = true; viAlias = true; vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      vim-commentary
      vim-surround
      vim-unimpaired
      nvim-treesitter.withAllGrammars
      mason-nvim
      lazy-nvim
    ];
  };
}
