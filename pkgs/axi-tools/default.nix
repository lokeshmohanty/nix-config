{ pkgs }:
# AXI (Agent eXperience Interface) CLIs — https://axi.md
#
# These are plain npm CLIs with no nixpkgs entry. Rather than three separate
# derivations we install them as one dependency aggregate, so a single
# package-lock.json (and therefore a single npmDepsHash) covers all of them.
#
# Version bumps: edit package.json, then
#   npm install --package-lock-only --ignore-scripts
#   nix run nixpkgs#prefetch-npm-deps -- package-lock.json   # -> new npmDepsHash
pkgs.buildNpmPackage {
  pname = "axi-tools";
  version = "0.1.0";

  src = ./.;

  npmDepsHash = "sha256-36BOJjMLLxWCITgAaDnYIH6LXoDMPPZKMKyc8jhBq4A=";

  # Nothing to compile: this package only pulls in the published CLIs.
  dontNpmBuild = true;
  dontNpmPrune = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/axi-tools
    cp -r node_modules package.json $out/lib/axi-tools/

    mkdir -p $out/bin
    for bin in gh-axi chrome-devtools-axi lavish-axi; do
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/$bin \
        --add-flags $out/lib/axi-tools/node_modules/.bin/$bin \
        --prefix PATH : ${
          pkgs.lib.makeBinPath [
            pkgs.gh
            pkgs.git
          ]
        }
    done

    runHook postInstall
  '';

  meta = {
    description = "AXI-compliant agent-facing CLIs: gh-axi, chrome-devtools-axi, lavish-axi";
    homepage = "https://axi.md";
    mainProgram = "gh-axi";
  };
}
