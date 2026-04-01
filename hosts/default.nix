{
  self,
  inputs,
  ...
}:
{
  flake.hostlib = import ./lib.nix { inherit inputs self; };

  imports = [
    ./sudarshan
    ./bhaskara
    ./bose
    ./server.nix
  ];
}
