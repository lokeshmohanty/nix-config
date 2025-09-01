{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nvim.homeModule
  ];
  home.packages = with pkgs; [
    isync   # sync emails
    maim    # screenshots
    nixfmt  # nix formatter
    nim
    sqlite
    isort
    python3Packages.pytest
    python3Packages.setuptools
    logseq
  ];
  home.sessionVariables.EDITOR = "vi";
  nvim = {
    enable = true;
    packageNames = ["nvim"];
    # packageNames = ["nvim" "vi"];
  };
  # programs.emacs = {
  #   enable = true;
  #   extraPackages = epkgs:
  #     with epkgs; [
  #       treesit-grammars.with-all-grammars
  #       vterm
  #       mu4e
  #     ];
  # };
  # services.emacs.enable = true;
  programs.neovide = {
    enable = true;
    # settings = {
    #   font = {
    #     normal = "Cascadia Code";
    #     size = 14.0;
    #   };
    # };
  };
}
