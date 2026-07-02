{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.modules.ai.enable = lib.mkEnableOption "AI CLI tooling";

  config = lib.mkIf config.modules.ai.enable {
    home.packages = with agents; [
      # harness
      qwen-code
      gemini-cli
      codex 
      claude-code 
      antigravity-cli 
      pi

      # tools
      agent-browser
      gitnexus
    ];
  };
}
