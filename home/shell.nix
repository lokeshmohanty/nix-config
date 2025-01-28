{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    exiftool                    #  Read and write meta information in files
  ];
  programs = {
    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
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
      eval "$(${pkgs.micromamba}/bin/micromamba shell hook -s fish)"
    '';
    shellAbbrs = {
      e = "emacsclient -c -a 'nvim'";
      d = "docker";
      g = "git";
      s = "sudo -u lokesh";
      p = "python";
      x = "env -u WAYLAND_DISPLAY";
      di = "docker image";
      dc = "docker container";
      de = "distrobox enter";
      mm = "micromamba";
      nd = "nix develop";
      nl = "nix-locate";
      nr = "nix run nixpkgs#";
      ns = "nix search nixpkgs";
      nq = "nix-env -qaP";
      nsh = "nix-shell --command fish -p";
      hypr = "dbus-run-session Hyprland";
    };
    functions = {
      gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';

      haskellEnv = ''
        for el in $argv
          set hpkgs $hpkgs "haskellPackages.ghcWithPackages.$el"
        end
        nix-shell --command fish -p $hpkgs
      '';

      pythonEnv = {
        description = "start a nix-shell with the given python packages";
        argumentNames = [ "pythonVersion" ];
        body = ''
          if set -q argv[2]
            # set pythonVersion $argv[1]
            set argv $argv[2..-1]
          end
          echo "Python Version: $pythonVersion"

          for el in $argv
            set ppkgs $ppkgs "python"$pythonVersion"Packages.$el"
          end

          nix-shell --command fish -p $ppkgs
        '';
      };
    };
    plugins = [
      { name = "bass"; src = pkgs.fishPlugins.bass; }
      { name = "colored-man-output"; src = pkgs.fishPlugins.colored-man-pages.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
    ];
  };
}
