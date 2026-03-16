{
  description = "Lokesh's NixOS Configuration";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    sysc-greet = {
      url = "github:Nomadcxx/sysc-greet";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    musnix.url = "github:musnix/musnix";

    nix-alien.url = "github:thiagokokada/nix-alien";
    stylix.url = "github:danth/stylix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nix-openclaw.url = "github:openclaw/nix-openclaw";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    "plugins-slimline" = {
      url = "github:sschleemilch/slimline.nvim";
      flake = false;
    };
    "plugins-himalaya-ui" = {
      url = "github:aliyss/vim-himalaya-ui";
      flake = false;
    };
    "plugins-everforest" = {
      url = "github:neanias/everforest-nvim";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./hosts
        # required to export flake.homeConfigurations and flake.homeModules
        inputs.home-manager.flakeModules.home-manager
      ];

      perSystem =
        { pkgs, ... }:
        let
          pkgs-with-overlays = pkgs.extend inputs.nix-openclaw.overlay;
          packages = import ./pkgs { inherit pkgs inputs; };
          apps = builtins.mapAttrs (name: drv: {
            type = "app";
            program =
              let
                main = drv.meta.mainProgram or name;
              in
              "${drv}/bin/${main}";
          }) packages;
        in
        {
          inherit packages apps;
          formatter = pkgs.nixfmt;
          devShells.default = pkgs-with-overlays.mkShell {
            packages = with pkgs-with-overlays; [
              openclaw
            ];
          };
        };
    };
}
