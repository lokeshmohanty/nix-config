{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./nixCats
  ];
  home.packages = with pkgs; [notmuch];
  home.sessionVariables.EDITOR = "nvim";
  programs.vim.enable = true;
  nixCats.enable = true;
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
