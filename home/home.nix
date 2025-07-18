{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./editor
    ./terminal
    ./browser
    ./fuzzel.nix
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
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {
      LESSHISTFILE = config.xdg.cacheHome + "/less/history";
      LESSKEY = config.xdg.configHome + "/less/lesskey";
      WINEPREFIX = config.xdg.dataHome + "/wine";

      # set default applications
      BROWSER = "firefox";

      # enable scrolling in git diff
      DELTA_PAGER = "less -R";
    };
    packages = with pkgs; [
      # Misc
      tlrc # rust client for tldr
      cowsay
      gnupg
      gnumake

      imagemagick
      pandoc
      pass
      rclone
      yt-dlp
      ffmpeg

      # Modern cli tools, replacement of grep/sed/...

      # Interactively filter its input using fuzzy searching, not limit to filenames.
      fzf
      fd # search for files by name, faster than find
      ripgrep
      ast-grep # A fast and polyglot tool for code searching, linting, rewriting at large scale

      yq-go # yaml processor https://github.com/mikefarah/yq
      just # a command runner like make, but simpler
      delta # A viewer for git and diff output
      lazygit # Git terminal UI.
      git-lfs
      hyperfine # command-line benchmarking tool
      gping # ping, but with a graph(TUI)
      doggo # DNS client for humans
      duf # Disk Usage/Free Utility - a better 'df' alternative
      gdu # disk usage analyzer(replacement of `du`)

      # nix related
      #
      nix-alien # run unpatched binaries
      # it provides the command `nom` works just like `nix
      # with more details log output
      nix-output-monitor
      nix-index # A small utility to index nix store paths
      nix-init # generate nix derivation from url
      # https://github.com/nix-community/nix-melt
      nix-melt # A TUI flake.lock viewer
      # https://github.com/utdemir/nix-tree
      nix-tree # A TUI to visualize the dependency graph of a nix derivation

      # productivity
      # croc # File transfer between computers securely and easily

      # other
      remmina
      freerdp # remote desktop client
    ];
  };

  stylixConfig.enable = true;
  stylixConfig.theme = "everforest-dark-hard"; #"terracotta";
  wallpaper = ./../wallpapers/0016.jpg;

  # Hyprland
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   plugins = [
  #     # inputs.hyprspace.packages.${pkgs.system}.Hyprspace
  #     inputs.woomer.packages.${pkgs.system}.default
  #   ];
  # };

  programs.zathura = {
    enable = true;
    extraConfig = ''
      set synctex true
      set synctex-editor-command "nvim --headless -c \"VimtexInverseSearch %{line} '%{input}'\""
    '';
  };
  programs.obs-studio = {
    enable = true;
    # plugins = with pkgs.obs-studio-plugins; [
    #   obs-backgroundremoval
    #   obs-move-transition
    #   advanced-scene-switcher
    # ];
  };
  programs.firefox.enable = true;
  # programs.keychain = { enable = true; keys = [ "id_ed25519" ]; };
  programs.gh = {
    enable = true;
    extensions = [pkgs.gh-dash];
  };
  programs.nix-index.enable = true;

  services.gammastep = {
    enable = true;
    temperature = {
      day = 5000;
      night = 2500;
    };
    latitude = 13.0;
    longitude = 77.5;
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
