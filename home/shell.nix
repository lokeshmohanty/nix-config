{ pkgs, ... }:
{
  home.packages = with pkgs; [
    exiftool # Read and write meta information in files
    nix-your-shell # use fish in nix develop / nix shell ...
  ];
  home.shell.enableShellIntegration = true;
  programs = {
    fzf = {
      enable = true;
      tmux.enableShellIntegration = true;
    };
    zoxide.enable = true;
    starship.enable = true;
    starship.presets = [
      # "tokyo-night"
      # "gruvbox-rainbow"
      # "jetpack"
      # "no-runtime-versions"
    ];
    yazi = {
      enable = true;
      settings = {
        mgr = {
          show_hidden = false;
          sort_by = "mtime";
          sort_dir_first = true;
          sort_reverse = true;
        };
      };
      keymap = {
        mgr.prepend_keymap = [
          {
            on = [ "<C-n>" ];
            run = ''
              shell '${pkgs.ripdrag}/bin/ripdrag "$@" -x 2>/dev/null &' --confirm
            '';
            desc = "Drag and drop";
          }
        ];
      };
    };
    # direnv = {
    #   enable = true;
    #   nix-direnv.enable = true;
    # };
  };
  programs.nushell = {
    enable = true;
    configFile.text = ''
      $env.config = {
        edit_mode: vi
      }
    '';
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings

      if command -q nix-your-shell
        nix-your-shell fish | source
      end
    '';
    shellAbbrs = {
      e = "emacsclient -c -a 'nvim'";
      d = "docker";
      g = "git";
      s = "sudo -E";
      p = "python";
      x = "env -u WAYLAND_DISPLAY";

      # docker
      di = "docker image";
      dc = "docker container";
      de = "distrobox enter";

      # tmux
      t = "tmux";
      ta = "tmux attach -t";
      tn = "tmux new-session -t";
      tl = "tmux list-sessions";
      tk = "tmux kill-session -t";

      # nix
      nd = "nix develop";
      nl = "nix-locate";
      nr = "nix run nixpkgs#";
      ns = "nix search nixpkgs";
      nq = "nix-env -qaP";
      nsh = "nix-shell -p";

      # hypr = "dbus-run-session Hyprland";
    };
    functions = {
      gitignore = "curl -sL https://www.gitignore.io/api/$argv";
    };
    plugins = [
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
          sha256 = "3d/qL+hovNA4VMWZ0n1L+dSM1lcz7P5CQJyy+/8exTc=";
        };
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
    ];
  };
}
