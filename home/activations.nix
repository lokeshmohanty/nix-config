{ lib, config, ... }:
{
  options.modules.activations.enable = lib.mkEnableOption "desktop activation symlinks";

  config = lib.mkIf config.modules.activations.enable {
    home.activation = {
      hyprland = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/config/hypr ${config.xdg.configHome}
        ln -sf ${config.vars.nixDir}/config/waybar ${config.xdg.configHome}
        ln -sf ${config.vars.nixDir}/config/wlogout ${config.xdg.configHome}
        ln -sf ${config.vars.nixDir}/config/swappy ${config.xdg.configHome}
        ln -sf ${config.vars.nixDir}/config/gtk.css ${config.xdg.configHome}
        ln -sf ${config.vars.nixDir}/config/icons ${config.xdg.configHome}
      '';
      niri = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/config/niri ${config.xdg.configHome}
      '';
      noctalia = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/config/noctalia ${config.xdg.configHome}
      '';
      scripts = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/scripts/* ${config.home.homeDirectory}/.local/bin/
      '';
      inkscape = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/config/inkscape ${config.xdg.configHome}/inkscape
      '';
      # Agentic harness (see config/agentic-harness/agents/docs/layout.md).
      # ~/.agents is a whole-dir symlink; ~/.claude and ~/.pi stay REAL dirs
      # (runtime state, credentials) with selective links inside.
      # ln -sfn, never ln -sf: -sf on an existing dir drops the link INSIDE it.
      agents = lib.mkAfter ''
        ln -sfn ${config.vars.nixDir}/config/agentic-harness/agents ${config.home.homeDirectory}/.agents
      '';
      claude = lib.mkAfter ''
        mkdir -p ${config.home.homeDirectory}/.claude
        ln -sfn ${config.home.homeDirectory}/.agents/AGENTS.md ${config.home.homeDirectory}/.claude/CLAUDE.md
        ln -sfn ${config.home.homeDirectory}/.agents/skills ${config.home.homeDirectory}/.claude/skills
        ln -sfn ${config.vars.nixDir}/config/agentic-harness/claude/settings.json ${config.home.homeDirectory}/.claude/settings.json
        ln -sfn ${config.vars.nixDir}/config/agentic-harness/claude/rules ${config.home.homeDirectory}/.claude/rules
      '';
      pi = lib.mkAfter ''
        mkdir -p ${config.home.homeDirectory}/.pi/agent
        ln -sfn ${config.vars.nixDir}/config/agentic-harness/pi/web-search.json ${config.home.homeDirectory}/.pi/web-search.json
        ln -sfn ${config.vars.nixDir}/config/agentic-harness/pi/agent/settings.json ${config.home.homeDirectory}/.pi/agent/settings.json
        ln -sfn ${config.vars.nixDir}/config/agentic-harness/pi/agent/models.json ${config.home.homeDirectory}/.pi/agent/models.json
        ln -sfn ${config.home.homeDirectory}/.agents/AGENTS.md ${config.home.homeDirectory}/.pi/agent/APPEND_SYSTEM.md
        ln -sfn ${config.home.homeDirectory}/.agents/skills ${config.home.homeDirectory}/.pi/agent/skills
      '';
      codex = lib.mkAfter ''
        mkdir -p ${config.home.homeDirectory}/.codex
        ln -sfn ${config.home.homeDirectory}/.agents/AGENTS.md ${config.home.homeDirectory}/.codex/AGENTS.md
        ln -sfn ${config.home.homeDirectory}/.agents/skills ${config.home.homeDirectory}/.codex/skills
      '';
      gemini = lib.mkAfter ''
        mkdir -p ${config.home.homeDirectory}/.gemini
        ln -sfn ${config.home.homeDirectory}/.agents/AGENTS.md ${config.home.homeDirectory}/.gemini/GEMINI.md
      '';
      antigravity = lib.mkAfter ''
        mkdir -p ${config.home.homeDirectory}/.gemini/antigravity
        ln -sfn ${config.home.homeDirectory}/.agents/AGENTS.md ${config.home.homeDirectory}/.gemini/antigravity/AGENTS.md
        ln -sfn ${config.home.homeDirectory}/.agents/skills ${config.home.homeDirectory}/.gemini/antigravity/skills
        ln -sfn ${config.vars.nixDir}/config/agentic-harness/antigravity/mcp_config.json ${config.home.homeDirectory}/.gemini/antigravity/mcp_config.json
      '';
      harness-bin = lib.mkAfter ''
        ln -sf ${config.vars.nixDir}/config/agentic-harness/bin/* ${config.home.homeDirectory}/.local/bin/
      '';
    };
  };
}
