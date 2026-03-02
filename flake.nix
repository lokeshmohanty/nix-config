{
  description = "Lokesh's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    musnix.url = "github:musnix/musnix";

    nix-alien.url = "github:thiagokokada/nix-alien";
    stylix.url = "github:danth/stylix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    "plugins-slimline" = {
      url = "github:sschleemilch/slimline.nvim";
      flake = false;
    };
    "plugins-org-bullets" = {
      url = "github:nvim-orgmode/org-bullets.nvim";
      flake = false;
    };
    # "plugins-bruno" = {
    #   url = "github:romek-codes/brun.nvim";
    #   flake = false;
    # };
    "plugins-himalaya-ui" = {
      url = "github:aliyss/vim-himalaya-ui";
      flake = false;
    };
    "plugins-everforest" = {
      url = "github:neanias/everforest-nvim";
      flake = false;
    };
  };

  outputs = inputs@{flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      # import home-manager to export flake.homeConfigurations and flake.homeModules
      imports = [./hosts inputs.home-manager.flakeModules.home-manager];
      perSystem = {pkgs, ...}: 
      let
        packages = import ./pkgs { inherit pkgs inputs; };
        apps = builtins.mapAttrs (name: drv: { type = "app"; program = let main = drv.meta.mainProgram or name; in "${drv}/bin/${main}"; }) packages;
      in {
        inherit packages apps;
        formatter = pkgs.nixfmt;
      };
    };
}
