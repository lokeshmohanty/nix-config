{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      vim-commentary
      vim-surround
      lightline-vim
      lightline-bufferline
      telescope-nvim
    ];
  };
}
