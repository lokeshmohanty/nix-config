{ pkgs, inputs, ... }:

{
  imports = [ 
    ./emacs.nix 
    inputs.nvf.homeManagerModules.default
  ];

  home.sessionVariables.EDITOR = "vi";
  # home.sessionVariables.EDITOR = "emacsclient -c -a 'vi'";
  # home.packages = [
  #   (inputs.nvf.lib.neovimConfiguration {
  #     inherit pkgs;
  #     modules = [ ../../modules/neovim.nix ];
  #   }).neovim
  # ];
  programs.nvf = {
    enable = true;
    enableManpages = true;
    settings = import ../../modules/neovim { inherit pkgs; };
  };
}
