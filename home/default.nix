{ inputs, nixpkgs, self, ... }: {
  "lokesh@sudarshan" = inputs.home-manager.lib.homeManagerConfiguration {
    extraSpecialArgs = { inherit self inputs; };
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    modules = [
      ./editor
      ./terminal
      ./home.nix
      ./fuzzel.nix
      ./lf.nix
      ./shell.nix
    ];
  };
}
