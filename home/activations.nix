{ lib, config, ... }:
{
  options.modules.activations.enable = lib.mkEnableOption "desktop activation symlinks";

  config = lib.mkIf config.modules.activations.enable {
    home.activation = {
      hyprland = lib.mkIf config.modules.gui.enable (
        lib.mkAfter ''
          ln -sfn ${config.vars.nixDir}/config/hypr ${config.xdg.configHome}
          ln -sfn ${config.vars.nixDir}/config/waybar ${config.xdg.configHome}
          ln -sfn ${config.vars.nixDir}/config/wlogout ${config.xdg.configHome}
          ln -sfn ${config.vars.nixDir}/config/swappy ${config.xdg.configHome}
          ln -sfn ${config.vars.nixDir}/config/gtk.css ${config.xdg.configHome}
          ln -sfn ${config.vars.nixDir}/config/icons ${config.xdg.configHome}
        ''
      );
      niri = lib.mkIf config.modules.gui.enable (
        lib.mkAfter ''
          ln -sfn ${config.vars.nixDir}/config/niri ${config.xdg.configHome}
        ''
      );
      noctalia = lib.mkIf config.modules.gui.enable (
        lib.mkAfter ''
          ln -sfn ${config.vars.nixDir}/config/noctalia ${config.xdg.configHome}
        ''
      );
      scripts = lib.mkIf config.modules.shell.enable (
        lib.mkAfter ''
          mkdir -p ${config.home.homeDirectory}/.local/bin
          ln -sfn ${config.vars.nixDir}/scripts/* ${config.home.homeDirectory}/.local/bin/
        ''
      );
      inkscape = lib.mkIf config.modules.gui.enable (
        lib.mkAfter ''
          ln -sfn ${config.vars.nixDir}/config/inkscape ${config.xdg.configHome}/inkscape
        ''
      );
      # Agentic harness (see config/agentic-harness/agents/docs/layout.md).
      # ~/.agents is a whole-dir symlink; ~/.claude and ~/.pi stay REAL dirs
      # (runtime state, credentials) with selective links inside.
      # ln -sfn, never ln -sf: -sf on an existing dir drops the link INSIDE it.
      agents = lib.mkIf config.modules.ai.enable (
        lib.mkAfter ''
          ln -sfn ${config.vars.nixDir}/config/agentic-harness/agents ${config.home.homeDirectory}/.agents
        ''
      );
      claude = lib.mkIf config.modules.ai.enable (
        lib.mkAfter ''
          ln -sfn ${config.vars.nixDir}/config/agentic-harness/claude ${config.home.homeDirectory}/.claude
        ''
      );
      pi = lib.mkIf config.modules.ai.enable (
        lib.mkAfter ''
          ln -sfn ${config.vars.nixDir}/config/agentic-harness/pi ${config.home.homeDirectory}/.pi
        ''
      );
      codex = lib.mkIf config.modules.ai.enable (
        lib.mkAfter ''
          ln -sfn ${config.vars.nixDir}/config/agentic-harness/codex ${config.home.homeDirectory}/.codex
        ''
      );
      gemini = lib.mkIf config.modules.ai.enable (
        lib.mkAfter ''
          ln -sfn ${config.vars.nixDir}/config/agentic-harness/gemini ${config.home.homeDirectory}/.gemini
        ''
      );
      harness-bin = lib.mkIf config.modules.ai.enable (
        lib.mkAfter ''
          mkdir -p ${config.home.homeDirectory}/.local/bin
          ln -sfn ${config.vars.nixDir}/config/agentic-harness/bin/* ${config.home.homeDirectory}/.local/bin/
        ''
      );
    };
  };
}
