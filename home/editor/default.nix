{ ... }:

{
  imports = [
    ./emacs.nix
    ./neovim.nix
  ];

  home.sessionVariables.EDITOR = "emacsclient -nw a 'vi'";
}
