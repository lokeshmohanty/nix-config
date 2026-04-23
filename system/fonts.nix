{ pkgs, ... }:
{
  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;

    packages = with pkgs; [
      cascadia-code
      iosevka-comfy.comfy-duo
      nerd-fonts.inconsolata-go
      nerd-fonts.fira-code
      victor-mono
      google-fonts
      font-awesome
      noto-fonts
      noto-fonts-color-emoji
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "Cascadia Code" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
        sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
        serif = [ "Noto Serif" "Noto Color Emoji" ];
      };
    };
  };
}
