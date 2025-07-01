{pkgs, ...}: {
  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true;
    # dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    # extraCompatPackages = [pkgs.proton-ge-bin];
  };
  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;
  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    lutris
    bottles
    heroic
  ];
}
