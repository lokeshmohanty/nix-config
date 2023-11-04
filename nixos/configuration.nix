# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
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
      # Disable if you don't want unfree packages
      allowUnfree = true;
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
    };
  };

  # FIXME: Add the rest of your current configuration
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
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.fish.enable = true;
  users.users = {
    lokesh = {
      # If you do, you can skip setting a root password by
      # passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      description = "Lokesh Mohanty";
      extraGroups = [ "wheel" "networkmanager" "docker" ];
    };
  };
  users.defaultUserShell = pkgs.fish;

  programs.neovim.enable = true;
  environment.binsh = "${pkgs.dash}/bin/dash";
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    PATH = [ "$HOME/.local/bin" ];
    EDITOR = "emacsclient -nw -a 'nvim'";
  };

  environment.systemPackages = with pkgs; [
    gitFull gh zoxide
    vim emacs29 emacsPackages.vterm ledger notmuch
    inxi neofetch powertop shellcheck
    rofi ripgrep tldr yt-dlp ffmpeg
    zip unzip file
    nodejs_20                   # use fnm after configuring it

    pandoc pass rclone rsync

    interception-tools
    cmakeWithGui

    # hyprland
    waybar eww
    (pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      }))

    dunst libnotify             # mako
    swww                        # hyprpaper swaybg wpaperd mpvpaper
    kitty alacritty
    rofi-wayland wofi           # bemenu fuzzel tofi
    networkmanagerapplet
    grim slurp wl-clipboard
  ];

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    oxygen
    plasma-browser-integration
  ];

  fonts.fonts = with pkgs; [
    roboto-mono
    fira-code
    font-awesome

    iosevka-comfy.comfy-duo
    iosevka-comfy.comfy-fixed

    # lohit-fonts.devanagari # already provided by noto fonts
    lohit-fonts.odia
    lohit-fonts.telugu
    lohit-fonts.kannada

    emojione
  ];

  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PermitRootLogin = "no";
  #     PasswordAuthentication = false;
  #   };
  # };

  services.locate = {
    enable = true;
    locate = pkgs.plocate;
    localuser = null;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Load amdgpu driver for Xorg and Wayland
  # services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.desktopManager.plasma5.enable = true;

  ## Hyprland
  programs.hyprland = {
    enable = true;
    nvidiaPatches = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; # prevent cursor from becoming invisible
    NIXOS_OZONE_WL = "1";          # hint electron apps to use wayland
  };

  # XDG portal
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Enable XMonad
  # services.xserver.windowManager.xmonad = {
  #   enable = true;
  #   enableContribAndExtras = true;
  # };

  # services.xserver.displayManager.sessionCommands = ''
  #   xset -dpms 
  #   xset s blank
  #   xset s 300
  #   ${pkgs.lightlocker}/bin/light-locker --idle-hint &
  # '';
  # systemd.targets.hybrid-sleep.enable = true;
  # services.logind.extraConfig = ''
  #   IdleAction=hybrid-sleep
  #   IdleActionSec=20s
  # '';

  # Configure keymap in X11
  # services.xserver = {
  #   layout = "us";
  #   xkbVariant = "";
  # };

  # Capslock as Control + Escape everywhere
  services.interception-tools = let
    dfkConfig = pkgs.writeText "dual-function-keys.yaml" ''
      MAPPINGS:
        - KEY: KEY_CAPSLOCK
          TAP: KEY_ESC
          HOLD: KEY_LEFTCTRL
    '';
  in {
    enable = true;
    plugins = lib.mkForce [
      pkgs.interception-tools-plugins.dual-function-keys
    ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c ${dfkConfig} | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          NAME: "AT Translated Set 2 keyboard"
          EVENTS:
            EV_KEY: [[KEY_CAPSLOCK, KEY_ESC, KEY_LEFTCTRL]]
    '';
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
    rootless.setSocketVariable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
