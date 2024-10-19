{ inputs, nixpkgs, self, ... }: {
  sudarshan = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit self inputs; };
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
      ./configuration.nix
      ./desktop-environment.nix
    ];
  };
}
