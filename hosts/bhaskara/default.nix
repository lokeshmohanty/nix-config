{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = {
    bhaskara = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs self;};
      modules = [
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.musnix.nixosModules.musnix
        ./configuration.nix
        ./hardware-configuration.nix
        ./syncthing.nix
      ];
    };
  };
}
