{ pkgs }:
pkgs.writeScriptBin "oauthman" (builtins.readFile ../../scripts/oauthman)
