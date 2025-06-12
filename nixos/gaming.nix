{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [pkgs.proton-ge-bin];
  };
  hardware.steam-hardware.enable = true;
  environment.systemPackages = with pkgs; [
    wineWowPackages.waylandFull
    winetricks
    gamescope

    # Games
    zeroad
    luanti
  ];
}
