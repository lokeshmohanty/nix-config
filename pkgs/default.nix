{ pkgs, inputs }:
{
  axi-tools = import ./axi-tools { inherit pkgs; };
  nvim = import ./nvim { inherit pkgs inputs; };
  ghost-build = import ./ghost-build { inherit pkgs; };
}
