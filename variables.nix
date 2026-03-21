{ config, lib, ... }: with lib; {
  options.vars = rec {
    username = mkOption {
      type = types.str;
      default = "lokesh";
      description = "My username";
    };
    nixDir = mkOption {
      type = types.str;
      default = "/home/${config.vars.username}/.nix";
      description = "Path to the NixOS configuration directory";
    };
    fontName = mkOption {
      type = types.str;
      default = "Cascadia Code";
      description = "Main font name";
    };
  };
}
