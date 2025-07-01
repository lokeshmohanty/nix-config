{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixCats.homeModule
  ];
  home.packages = with pkgs; [
    mu
    isync
    maim
    nixfmt
    nim
    sqlite
    isort
    python3Packages.pytest
    python3Packages.setuptools
  ];
  home.sessionVariables.EDITOR = "vi";
  nixCats = {
    enable = true;
    packageNames = ["nixCats" "regularCats"];
  };
  programs.emacs = {
    enable = true;
    extraPackages = epkgs:
      with epkgs; [
        treesit-grammars.with-all-grammars
        vterm
        mu4e
      ];
  };
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
