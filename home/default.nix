{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../variables.nix

    ./terminal
    ./browser
    ./editor.nix
    ./launcher.nix
    ./shell.nix
    ./xdg.nix
    ./stylix.nix
  ];

  nixpkgs = {
    overlays = [
      inputs.nix-alien.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "lokesh";
    homeDirectory = "/home/lokesh";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      LESSHISTFILE = config.xdg.cacheHome + "/less/history";
      LESSKEY = config.xdg.configHome + "/less/lesskey";
      WINEPREFIX = config.xdg.dataHome + "/wine";
      # enable scrolling in git diff
      DELTA_PAGER = "less -R";
      TERM = "xterm-256color";
    };
    packages = with pkgs; [
      # Misc
      tlrc # rust client for tldr
      # cowsay
      gnupg
      gnumake

      # tui applications
      # lazygit lazysql lazydocker

      pandoc
      pass
      rclone
      yt-dlp
      ffmpeg

      sqlite

      fzf
      fd # fd alternative
      sd # sed alternative
      ripgrep # grep alternative

      yq-go # yaml processor https://github.com/mikefarah/yq
      just # a command runner like make, but simpler
      delta # A viewer for git and diff output
      hyperfine # command-line benchmarking tool
      gping # ping, but with a graph(TUI)
      doggo # DNS client for humans
      duf # Disk Usage/Free Utility - a better 'df' alternative
      gdu # disk usage analyzer(replacement of `du`)

      # nix related
      nix-alien # run unpatched binaries

      # it provides the command `nom` works just like `nix
      # with more details log output
      nix-output-monitor
      nix-index # A small utility to index nix store paths

      # productivity
      # croc # File transfer between computers securely and easily

      # other
      # remmina
      # freerdp # remote desktop client
    ];
    activation.hyprland = lib.mkAfter ''
      ln -sf ${config.vars.nixDir}/config/hypr ${config.xdg.configHome}
      ln -sf ${config.vars.nixDir}/config/waybar ${config.xdg.configHome}
      ln -sf ${config.vars.nixDir}/config/wlogout ${config.xdg.configHome}
      ln -sf ${config.vars.nixDir}/config/swappy ${config.xdg.configHome}
      ln -sf ${config.vars.nixDir}/config/gtk.css ${config.xdg.configHome}
      ln -sf ${config.vars.nixDir}/config/icons ${config.xdg.configHome}
    '';
    activation.niri = lib.mkAfter ''
      ln -sf ${config.vars.nixDir}/config/niri ${config.xdg.configHome}
    '';
    activation.noctalia = lib.mkAfter ''
      ln -sf ${config.vars.nixDir}/config/noctalia ${config.xdg.configHome}
    '';
    activation.scripts = lib.mkAfter ''
      ln -sf ${config.vars.nixDir}/scripts/* ${config.home.homeDirectory}/.local/bin/
    '';
  };

  stylixConfig.enable = true;
  stylixConfig.theme = "everforest-dark-hard"; # "terracotta";
  wallpaper = ./../wallpapers/0016.jpg;

  ## Nix Helper
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "${config.home.homeDirectory}/.nix";
  };

  programs.zathura = {
    enable = true;
    extraConfig = ''
      set synctex true
      set synctex-editor-command "nvim --headless -c \"VimtexInverseSearch %{line} '%{input}'\""
    '';
  };
  # programs.keychain = { enable = true; keys = [ "id_ed25519" ]; };
  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-dash ];
  };
  programs.nix-index.enable = true;

  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = [ "qemu:///system" ];
  #     uris = [ "qemu:///system" ];
  #   };
  # };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
