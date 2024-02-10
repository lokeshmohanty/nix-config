{ inputs, nixpkgs, self, ... }: {
  sudarshan = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit self inputs; };
    system = "x86_64-linux";
    modules = [ ./configuration.nix ];
  };
}
