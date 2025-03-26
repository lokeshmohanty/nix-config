{ pkgs, config, ... }:

{
  programs.fuzzel = {
    enable = true;
    # settings.main = {
    #   font = "Cascadia Code:style=Italic:size=15";
    #   terminal = "${pkgs.foot}/bin/footclient";
    #   dpi-aware = "no";
    #   width = 50;               # default: 30
    #   layer = "overlay";
    #   # exit-on-keyboard-focus-loss = "no";
    #   # inner-pad = 15;
    # };
    # settings.colors = {
    #   background = "d0c1bbff";     # "#d0c1bb"
    #   text = "352a25ff";           # "#352a25"
    #   selection = "ce943eff";      # "#ce943e"
    #   selection-text = "241c19ff"; # "#241c19"
    # };
  };
}
