{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "screen-256color";
    extraConfig = ''
      # for image support in yazi
      set -g allow-passthrough all
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
    '';
    plugins = with pkgs.tmuxPlugins; [gruvbox];
  };
}
