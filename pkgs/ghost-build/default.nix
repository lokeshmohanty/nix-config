{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  pname = "ghost-build";
  version = "0.19.0";

  src = pkgs.fetchurl {
    url = "https://install.ghost.build/releases/v${version}/ghost_Linux_x86_64.tar.gz";
    hash = "sha256-XdvkbUtA8dRuNqd/hfq9y0tuzvC6HwuhKtZ8T9uLdqM=";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 ghost $out/bin/ghost
    mkdir -p $out/share/fish/vendor_completions.d
    $out/bin/ghost completion fish > $out/share/fish/vendor_completions.d/ghost.fish
  '';

  passthru.updateScript = pkgs.writeShellScriptBin "ghost-update-nix" ''
    set -euo pipefail
    version=$(${pkgs.curl}/bin/curl -fsSL https://install.ghost.build/latest.txt)
    version_clean=''${version#v}
    url="https://install.ghost.build/releases/''${version}/ghost_Linux_x86_64.tar.gz"
    hash=$(${pkgs.nix}/bin/nix-prefetch-url --type sha256 "$url" 2>/dev/null | xargs ${pkgs.nix}/bin/nix hash to-sri --type sha256)
    ${pkgs.gnused}/bin/sed -i \
      -e "s|version = \".*\";|version = \"''${version_clean}\";|" \
      -e "s|hash = \".*\";|hash = \"''${hash}\";|" \
      ${builtins.toString ./default.nix}
    echo "Updated ghost-build to ''${version}"
  '';

  meta = {
    description = "Ghost CLI - managed database and AI agent tooling";
    homepage = "https://ghost.build";
    mainProgram = "ghost";
  };
}
