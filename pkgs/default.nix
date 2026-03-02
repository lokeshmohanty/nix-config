{ pkgs, inputs }:
{
  nvim = import ./nvim { inherit pkgs inputs; };
}
