{ pkgs, config, ... }:

{
  programs.starship.enable = true;
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings
      zoxide init fish | source
    '';
    shellAbbrs = {
      e = "emacsclient -nw -a 'nvim'";
      g = "git";
      x = "env -u WAYLAND_DISPLAY";
      nl = "nix-locate";
      ns = "nix search nixpkgs";
      nsh = "nix-shell --command fish -p";
      hypr = "dbus-run-session Hyprland";
    };
    functions = {
      nr = "nix run nixpkgs#$argv";
    };
    plugins = [ { name = "bass"; src = pkgs.fishPlugins.bass; } ];
  };
}
