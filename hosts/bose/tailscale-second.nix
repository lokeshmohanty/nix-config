{ pkgs, ... }:

{
  systemd.services.tailscale-second = {
    description = "Tailscale second instance";
    documentation = [ "https://tailscale.com/kb/" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.tailscale}/bin/tailscaled -tun=userspace-networking -state=/var/lib/tailscale-second/tailscaled.state -socket=/run/tailscale-second/tailscaled.sock -socks5-server=127.0.0.1:1080";
      RuntimeDirectory = "tailscale-second";
      RuntimeDirectoryMode = "0755";
      StateDirectory = "tailscale-second";
      StateDirectoryMode = "0700";
      Type = "notify";
      Restart = "on-failure";
    };
  };
}
