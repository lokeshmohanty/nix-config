{ ... }:

{
  imports = [
    ./emacs.nix
    ./neovim.nix
  ];

  home.sessionVariables.EDITOR = "emacsclient -c -a 'vi'";
  # home.sessionVariables.EDITOR = "emacsclient -nw -a 'vi'";
}
