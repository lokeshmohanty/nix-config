{ config, lib, ... }:
with lib;
{
  options.vars = rec {
    username = mkOption {
      type = types.str;
      default = "lokesh";
      description = "My username";
    };
    homeDirectory = mkOption {
      type = types.str;
      default = "/home/${config.vars.username}";
      description = "Home directory for the configured user";
    };
    nixDir = mkOption {
      type = types.str;
      default = "${config.vars.homeDirectory}/.nix";
      description = "Path to the NixOS configuration directory";
    };
    fontName = mkOption {
      type = types.str;
      default = "Cascadia Code";
      description = "Main font name";
    };
  };
}
