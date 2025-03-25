{ pkgs, inputs, ... }:

{
  imports = [ 
    inputs.nvf.homeManagerModules.default
  ];

  home.sessionVariables.EDITOR = "nvim";
  programs.vim.enable = true;
  programs.nvf = {
    enable = true;
    enableManpages = true;
    settings = import ../../modules/neovim { inherit pkgs; };
  };
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;
  };
  programs.neovide = {
    enable = true;
    settings = {
      font = {
        normal = "Cascadia Code";
        size = 14.0;
      };
    };
  };
}
