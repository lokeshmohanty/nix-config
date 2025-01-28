{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;
  environment.systemPackages = with pkgs; [
    # wineWowPackages.waylandFull
    winetricks
    gamescope
  ];
}
