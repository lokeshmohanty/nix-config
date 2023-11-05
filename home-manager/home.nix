# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # inputs.nix-colors.homeManagerModule
    inputs.nix-colors.homeManagerModules.default
    # ./features/alacritty.nix
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

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
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      # allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "lokesh";
    homeDirectory = "/home/lokesh";
  };

  # Add stuff for your user as you see fit:
  # programs.mtr.enable = true;
  home.packages = with pkgs; [ microsoft-edge firefox anydesk
                               # kdenlive ispell redshift
                               kate onlyoffice-bin
                               tikzit motrix
                               fd
                               # zotero -> insecure, see how to fix it

                               # mako
                             ];
  programs.starship.enable = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings
      alias e "emacsclient -a 'nvim'"
      alias nshell "nix-shell --command fish -p"
      alias ns "nix search nixpkgs"
      zoxide init fish | source
    '';
    # plugins = with pkgs.fishPlugins; [ bass ];
  };
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      set number relativenumber
    '';
    plugins = with pkgs.vimPlugins; [ vim-commentary  vim-surround ];
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  services.emacs.startWithUserSession = "graphical";
  services.picom.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
