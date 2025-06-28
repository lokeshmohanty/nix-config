{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../modules/nixCats
  ];
  home.packages = with pkgs; [notmuch];
  home.sessionVariables.EDITOR = "nvim";
  # nixCats.enable = true;
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
