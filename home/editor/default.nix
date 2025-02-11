{ pkgs, inputs, ... }:

{
  imports = [ ./emacs.nix ];

  home.sessionVariables.EDITOR = "vi";
  # home.sessionVariables.EDITOR = "emacsclient -c -a 'vi'";
  home.packages = [
    (inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [ ../../modules/neovim.nix ];
    }).neovim
  ];
}
