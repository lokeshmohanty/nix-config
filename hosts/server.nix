{
  self,
  ...
}:
let
  envOr =
    name: fallback:
    let
      value = builtins.getEnv name;
    in
    if value == "" then fallback else value;
  username = envOr "LOKESH_CONFIG_USER" "lokesh";
  homeDirectory = envOr "LOKESH_CONFIG_HOME" "/home/${username}";
  nixDir = envOr "LOKESH_CONFIG_DIR" "${homeDirectory}/.nix";
in
{
  flake.homeConfigurations = {
    "lokesh@server" = self.hostlib.mkHomeHost {
      imports = [ ../home ];
      vars = {
        inherit username homeDirectory nixDir;
      };
      stylixConfig.enable = false;
      modules = {
        ai.enable = true;
        activations.enable = true;
        editor.enable = true;
        shell.enable = true;
        tui.enable = true;
      };
    };
  };
}
