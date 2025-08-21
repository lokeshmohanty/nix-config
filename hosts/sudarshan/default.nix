{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = {
    sudarshan = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs self;};
      modules = [
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
        ./configuration.nix
        ./hardware-configuration.nix
        ./syncthing.nix
      ];
    };
  };
}
