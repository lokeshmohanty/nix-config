{ inputs, nixpkgs, self, ... }: {
  sudarshan = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit self inputs; };
    system = "x86_64-linux";
    modules = [
      ./hardware-configuration.nix
      ./configuration.nix
      ./security.nix
      ./gaming.nix
      ./syncthing.nix
    ];
  };
}
