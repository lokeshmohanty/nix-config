{ pkgs, inputs, ... }:

{
  imports = [ 
    ./emacs.nix 
    inputs.nvf.homeManagerModules.default
  ];

  home.sessionVariables.EDITOR = "vi";
  # home.sessionVariables.EDITOR = "emacsclient -c -a 'vi'";
  programs.nvf = {
    enable = true;
    enableManpages = true;
    settings = import ../../modules/neovim { inherit pkgs; };
  };
}
