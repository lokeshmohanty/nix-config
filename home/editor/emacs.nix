{ pkgs, ... }:

{
  home.packages = with pkgs; [ pyright ledger notmuch ];
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
    extraPackages = epkgs: [ epkgs.multi-vterm ];
  };

  services.emacs.enable = true;
}
