{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  environment.systemPackages = with pkgs; [
    # wineWowPackages.waylandFull
    # winetricks
    mangohud                    # monitor CPU/GPU/temperature, ...
    protonup                    # install proton ge
  ];
}
