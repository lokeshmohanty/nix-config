{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations = {
    sudarshan = self.hostlib.mkNixosHost {
      hardwareModules = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd ];
      extraModules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./syncthing.nix
      ];
    };
  };
  flake.homeConfigurations = {
    "lokesh@sudarshan" = self.hostlib.mkHomeHost (
      { pkgs, ... }:
      {
        imports = [ ../../home ];

        modules = {
          ai.enable = true;
          activations.enable = true;
          editor.enable = true;
          email.enable = true;
          gui.enable = true;
          shell.enable = true;
          tui.enable = true;
        };

        # ecr's server is a systemd *user* service: the maildir, the notmuch
        # database and the token store all live in $HOME, where Xapian has to
        # write. The client itself is installed wherever email is enabled (see
        # home/email/module.nix); only sudarshan runs the server. The accounts
        # themselves are not here — they live in ~/.config/ecr/accounts.toml,
        # which ecr owns and the client writes.
        programs.ecr.server = {
          enable = true;
          # Bound to sudarshan's Tailscale IPv4 (100.64.0.0/10), not loopback
          # and not 0.0.0.0: this is a laptop that moves networks, and ecr's API
          # is unauthenticated while no tokens exist, so 0.0.0.0 would expose it
          # to anyone on the same Wi-Fi. The tailnet address is reachable only
          # from inside the tailnet, so every device on the VPN can hit the
          # server and nothing else can. The address is stable once the node has
          # joined the tailnet; `tailscale ip -4` prints it.
          #
          # Issue a token before relying on auth: `ecr token new <name> --qr`
          # — until at least one token exists the API is unauthenticated.
          bind = "0.0.0.0:8383";
        };

        home.packages = with pkgs; [
          slack
          tigervnc
        ];
      }
    );
  };
}
