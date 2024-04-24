# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    ./security.nix
    ./desktop-environment.nix
    ./gaming.nix
    ./syncthing.nix
    ./services.nix
    ./programs.nix
    # ./ssh.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      allowInsecure = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = [ "lokesh" ];

      # cachix
      substituters = [
        "https://hyprland.cachix.org"
        # "https://nix-community.cachix.org"
        # "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = [
      pkgs.rocm-opencl-icd
      pkgs.rocm-opencl-runtime
      pkgs.amdvlk
    ];
  };

  networking.hostName = "sudarshan";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  powerManagement.enable = true;
  services.thermald.enable = true;
  # services.tlp.enable = true;

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  users.users = {
    lokesh = {
      # If you do, you can skip setting a root password by
      # passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "nixos";
      isNormalUser = true;
      description = "Lokesh Mohanty";
      extraGroups = [ "wheel" "input" "video" "networkmanager" "libvirtd" "docker"];
    };
  };
  users.defaultUserShell = pkgs.fish;
  environment.binsh = "${pkgs.dash}/bin/dash";

  environment.systemPackages = with pkgs; [
    # gui applications
    google-chrome onlyoffice-bin
    tikzit motrix zotero kdenlive okular inkscape
    vscode.fhs

    # cli applications
    fd imagemagick
    ripgrep pandoc pass rclone rsync
    tesseract
    nix-index
    yt-dlp ffmpeg tldr 
    gh                          # prevent error from magit

    # system utilities
    inxi neofetch bat duf
    libtool zip unzip unrar file
    powertop nvtop htop bottom
    openconnect networkmanager-openconnect

    # other utilities
    quickemu
    waypipe
    distrobox
    docker-compose

    # programming languages
    poetry # mujoco
    (pkgs.python311.withPackages (ps: with ps; [
      pip ipython jupyterlab jupytext
      numpy pandas matplotlib seaborn tqdm
      scikit-learn torch
      gymnasium pygame pybox2d mujoco imageio

      pydantic rich dvc mlflow tensorboard
      huggingface-hub
    ]))
    gnumake gcc ghc nodejs micromamba
    cmakeWithGui shellcheck 

    ## latex
    texlive.combined.scheme-full
    texlab tectonic
  ];

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      iosevka-comfy.comfy-duo
      iosevka-comfy.comfy-fixed
      nerdfonts
      google-fonts
      font-awesome
      # noto-fonts-emoji symbola
    ];
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  virtualisation = {
    # docker = {
    #   enable = true;
    #   rootless.enable = true;
    #   rootless.setSocketVariable = true;
    # };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd.enable = true;
    # waydroid.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
