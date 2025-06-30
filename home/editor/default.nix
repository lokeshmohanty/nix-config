{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixCats.homeModule
  ];
  home.packages = with pkgs; [notmuch];
  home.sessionVariables.EDITOR = "vi";
  # nixCats.enable = true;
  nixCats = {
    enable = true;
    packageNames = ["nixCats" "regularCats"];
  };
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [epkgs.vterm];
  };
  services.emacs.enable = true;
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
