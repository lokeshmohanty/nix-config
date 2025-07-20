{ pkgs, ... }: {
  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      iosevka-comfy.comfy-duo
      iosevka-comfy.comfy-fixed
      nerd-fonts.inconsolata-go
      cascadia-code
      victor-mono
      google-fonts
      font-awesome
      source-sans-pro
    ];
  };
}
