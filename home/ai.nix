{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.modules.ai.enable = lib.mkEnableOption "AI CLI tooling";

  config = lib.mkIf config.modules.ai.enable {
    home.packages = with pkgs; [
      qwen-code
      gemini-cli
      # codex claude-code antigravity
      # pi
    ];
  };
}
