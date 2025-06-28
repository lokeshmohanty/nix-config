{
  description = "Lokesh's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nvf.url = "github:notashelf/nvf";
    nix-alien.url = "github:thiagokokada/nix-alien";
    stylix.url = "github:danth/stylix";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    home-manager,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [];
      flake = {
        nixosConfigurations = {
          sudarshan = nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs;};
            modules = [
              inputs.nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
              inputs.lix-module.nixosModules.default
              ./nixos/configuration.nix
              ./nixos/desktop-environment.nix
            ];
          };
        };
        homeConfigurations = {
          "lokesh@sudarshan" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = {inherit inputs;};
            modules = [
              ./home/home.nix
            ];
          };
        };
      };
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        packages = import ./pkgs {inherit pkgs inputs;};
        formatter = pkgs.alejandra;
      };
    };
}
