{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamemode.enable = true;
  environment.systemPackages = with pkgs; [
    bottles gamescope
    lutris wineWowPackages.waylandFull winetricks
  ]; # mangohud 
}
