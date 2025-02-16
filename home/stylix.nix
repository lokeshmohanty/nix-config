{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  options = {
    stylixConfig = {
      enable = lib.mkEnableOption "enable stylix";
      theme = lib.mkOption { type = lib.types.str; };
    };
    wallpaper = lib.mkOption { type = with lib.types; oneOf [str path package]; };
  };
  config = lib.mkIf config.stylixConfig.enable {
    # wallpaper = with config.lib.stylix.colors.withHashtag;
    #   pkgs.runCommand "cat.png" {} ''
    #     pastel=${pkgs.pastel}/bin/pastel
    #     SHADOWS=$($pastel darken 0.1 '${base05}' | $pastel format hex)
    #     TAIL=$($pastel lighten 0.1 '${base02}' | $pastel format hex)
    #     HIGHLIGHTS=$($pastel lighten 0.1 '${base05}' | $pastel format hex)

    #     ${pkgs.imagemagick}/bin/convert ${./attachments/basecat.png} \
	  #       -fill '${base00}' -opaque black \
	  #       -fill '${base05}' -opaque white \
	  #       -fill '${base08}' -opaque blue \
	  #       -fill $SHADOWS -opaque gray \
	  #       -fill '${base02}' -opaque orange \
	  #       -fill $TAIL -opaque green \
	  #       -fill $HIGHLIGHTS -opaque brown \
	  #       $out'';
    stylix = {
      enable = true;
      targets = {
        fuzzel.enable = false;
        waybar.enable = false;
      };
      polarity = "light";
      opacity = {
        applications = 1.0;
        desktop = 1.0;
        popups = 1.0;
        terminal = 1.0;
      };
      image = config.wallpaper;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${config.stylixConfig.theme}.yaml";
      iconTheme = {
        enable = true;
        package = pkgs.material-design-icons;
        light = "material-design-icons";
      };
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
      fonts = {
        serif = config.stylix.fonts.monospace;
        sansSerif = config.stylix.fonts.monospace;
        monospace = {
          package = pkgs.cascadia-code;
          name = "Cascadia Code";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 12;
          desktop = 10;
          popups = 10;
          terminal = 14;
        };
      };
    };
  };
}
