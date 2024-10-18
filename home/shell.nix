{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    zoxide                      #  A faster way to navigate your filesystem
    yazi                        #  A fast and minimalistic fuzzy finder
    exiftool                    #  Read and write meta information in files
  ];
  programs.starship.enable = true;
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings
      zoxide init fish | source
    '';
    shellAbbrs = {
      e = "emacsclient -c -a 'nvim'";
      # e = "emacsclient -nw -a 'nvim'";
      d = "docker";
      g = "git";
      s = "sudo -u lokesh";
      p = "python";
      x = "env -u WAYLAND_DISPLAY";
      di = "docker image";
      dc = "docker container";
      de = "distrobox enter";
      nl = "nix-locate";
      ns = "nix search nixpkgs";
      nq = "nix-env -qaP";
      nsh = "nix-shell --command fish -p";
      hypr = "dbus-run-session Hyprland";
    };
    functions = {
      nr = "nix run nixpkgs#$argv";
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
          echo "$pythonVersion"

          for el in $argv
            set ppkgs $ppkgs "python"$pythonVersion"Packages.$el"
          end

          nix-shell --command fish -p $ppkgs
        '';
      };
    };
    plugins = [ { name = "bass"; src = pkgs.fishPlugins.bass; } ];
  };
}
