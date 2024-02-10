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
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    # ./hardware-configuration.nix
    # ./syncthing.nix
    ./hardware-configuration.nix
    ./security.nix
    ./greeter.nix
    ./gaming.nix
    ./syncthing.nix
    # ./ssh.nix
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
        "https://nix-community.cachix.org"
        # "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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

  programs.dconf.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "qt";
    enableSSHSupport = true;
  };
  programs.light.enable = true;
  programs.fish.enable = true;
  users.users = {
    lokesh = {
      # If you do, you can skip setting a root password by
      # passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "nixos";
      isNormalUser = true;
      description = "Lokesh Mohanty";
      extraGroups = [ "wheel" "input" "video" "networkmanager" "libvirtd" ];
    };
  };
  users.defaultUserShell = pkgs.fish;
  environment.binsh = "${pkgs.dash}/bin/dash";

  environment.systemPackages = with pkgs; [
    inxi neofetch shellcheck bat duf
    gnumake libtool zip unzip file
    ripgrep tldr yt-dlp ffmpeg
    powertop nvtop htop bottom
    gh                         # to fix auth error, remove it later

    pandoc pass rclone rsync

    interception-tools
    cmakeWithGui
    nix-index

    quickemu                   # for easy vm creation

    waypipe

    xdg-desktop-portal xdg-desktop-portal-hyprland
    pinentry-qt
    waybar dunst libnotify
    fuzzel swaybg waypaper
    networkmanagerapplet mpv vimiv-qt gimp
    grim slurp swappy wl-clipboard
    swayidle swaylock-effects wlogout
    pamixer pavucontrol
    nwg-displays wlr-randr
    qt5.qtwayland qt6.qtwayland
    cliphist pywal hyprpicker
    # udisks2 gvfs
    jmtpfs
    tesseract
  ];

  programs.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common = {
        default = [ "gtk" ];
      };
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  services.flatpak.enable = true;

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

  # services.teamviewer.enable = true;
  services.gvfs.enable = true;
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    localuser = null;
  };

  # Capslock as Control + Escape, Escape as Capslock 
  services.interception-tools = {
    enable = true;
    plugins = lib.mkForce [
      pkgs.interception-tools-plugins.caps2esc
    ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          NAME: "AT Translated Set 2 keyboard"
          EVENTS:
            EV_KEY: [[KEY_CAPSLOCK, KEY_ESC]]
    '';
  };

  services.printing = {
    enable = true;
    browsing = true;
  };
  services.blueman.enable = true;

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
    docker = {
      enable = true;
      rootless.enable = true;
      rootless.setSocketVariable = true;
    };
    libvirtd.enable = true;
    # waydroid.enable = true;
  };
  programs.virt-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
