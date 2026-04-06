{ pkgs }: pkgs.writers.writePython3Bin "oauthman" { flakeIgnore = [ "E501" "E265" ]; } (builtins.readFile ../../scripts/oauthman)
