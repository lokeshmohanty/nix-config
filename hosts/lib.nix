{ inputs, self }:
let
  system = "x86_64-linux";
in
{
  mkHomeHost =
    module:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs self; };
      modules = [ module ];
    };

  mkNixosHost =
    {
      hardwareModules ? [ ],
      extraModules ? [ ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs self; };
      modules = [
        inputs.determinate.nixosModules.default
        inputs.musnix.nixosModules.musnix
      ]
      ++ hardwareModules
      ++ extraModules;
    };
}
