{ pkgs, inputs }:
{
  oauthman = import ./oauthman { inherit pkgs; };
  nvim = import ./nvim { inherit pkgs inputs; };
}
