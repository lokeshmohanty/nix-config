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
    # neovim-config.url = "github:lokeshmohanty/neovim-config";
    nvf.url = "github:notashelf/nvf";
    nix-alien.url = "github:thiagokokada/nix-alien";
    stylix.url = "github:danth/stylix";
  };

  outputs = { nixpkgs, self, ... } @ inputs:
    {
      nixosConfigurations = import ./nixos { inherit self nixpkgs inputs; };
      homeConfigurations = import ./home { inherit self nixpkgs inputs; };
      packages."x86_64-linux".neovim =
        (inputs.nvf.lib.neovimConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./modules/neovim ];
        }).neovim;
    };
}
