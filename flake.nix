{
  description = "Lokesh's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { nixpkgs, self, ... } @ inputs:
    {
      nixosConfigurations = import ./nixos { inherit self nixpkgs inputs; };
      homeConfigurations = import ./home { inherit self nixpkgs inputs; };
    };

  # outputs = {
  #   self,
  #   nixpkgs,
  #   home-manager,
  #   ...
  # } @ inputs: let
  #   inherit (self) outputs;
  # in {
  #   # NixOS configuration entrypoint
  #   # Available through 'nixos-rebuild --flake .#your-hostname'
  #   nixosConfigurations = {
  #     sudarshan = nixpkgs.lib.nixosSystem {
  #       specialArgs = {inherit inputs outputs;};
  #       modules = [./nixos/configuration.nix];
  #     };
  #   };

  #   # Standalone home-manager configuration entrypoint
  #   # Available through 'home-manager --flake .#your-username@your-hostname'
  #   homeConfigurations = {
  #     "lokesh@sudarshan" = home-manager.lib.homeManagerConfiguration {
  #       pkgs = nixpkgs.legacyPackages.x86_64-linux;
  #       extraSpecialArgs = {inherit inputs outputs;};
  #       modules = [./home-manager/home.nix];
  #     };
  #   };
  # };
}
