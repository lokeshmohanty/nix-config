# Shell for bootstrapping flake-enabled nix and home-manager
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
# Taken from https://github.com/spl3g/nixfiles
{pkgs ? (import ./nixpkgs.nix) {}}: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [nix home-manager git nvim];
  };
}
