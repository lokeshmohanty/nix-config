{ pkgs, config, ... }:

{
  home.file."${config.xdg.configHome}/hypr/volume.sh" = {source = ../config/hypr/volume.sh;};
  home.file."${config.xdg.configHome}/hypr/brightness.sh" = {source = ../config/hypr/brightness.sh;};

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
    # theme = "capitaine-cursors";
  };
  # home.sessionVariables = {
  #   WLR_NO_HARDWARE_CURSORS = "1";    # prevent cursor from becoming invisible
  #   NIXOS_OZONE_WL = "1";             # hint electron apps to use wayland
  #   # XDG_SESSION_DESKTOP = "Hyprland"; # sway
  #   # XDG_SESSION_TYPE = "wayland";
  #   # _JAVA_AWT_WM_NONREPARENTING = "1";
  #   # QT_QPA_PLATFORM = "wayland";
  # };
  # home.packages = with pkgs; [
  #   pinentry-qt
  #   waybar dunst libnotify
  #   fuzzel swaybg waypaper
  #   networkmanagerapplet mpv vimiv-qt gimp
  #   grim slurp swappy wl-clipboard
  #   swayidle swaylock-effects wlogout
  #   pamixer pavucontrol
  #   nwg-displays wlr-randr
  #   qt5.qtwayland qt6.qtwayland
  #   cliphist pywal hyprpicker
  #   # udisks2 gvfs
  #   jmtpfs
  # ];

  wayland.windowManager.hyprland = {
    enable = true;
    # settings = {};
    extraConfig = ''
      monitor=,highres,auto,1

      exec-once = gtk-launch org.kde.polkit-kde-authentication-agent-1.desktop
      exec-once = waybar
      exec-once = foot --server
      exec-once = [workspace 2 silent] fiefox
      exec-once = nm-applet --indicator
      exec-once = dunst
      exec-once = waypaper --restore
      exec-once = [workspace special:default silent] kitty
      exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once=xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2

      misc {
        force_default_wallpaper = 0
        # disable_autoreload = true
        disable_hyprland_logo = true
        disable_splash_rendering = true
        mouse_move_enables_dpms = true
        enable_swallow = true
        no_direct_scanout = true #for fullscreen games
        vrr = 2
      }

      input {
          kb_layout = us
          touchpad {
              natural_scroll = yes
          }
          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      general {
          gaps_in = 3
          gaps_out = 7
          border_size = 2
          col.active_border = rgba(7aa2f7aa) rgba(c4a7e7aa) 45deg
          col.inactive_border = rgba(414868aa)
          layout = dwindle
      }

      dwindle {
        pseudotile = yes
        preserve_split = yes
        special_scale_factor = 0.8
      }

      decoration {
        rounding = 4
        drop_shadow = no
        shadow_range = 4
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)
        blur {
          enabled = true	
          size = 8
          passes = 2
          new_optimizations = true
        }
      }

      animations {
          enabled = yes
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      dwindle {
          pseudotile = yes
          preserve_split = yes
      }

      master {
          new_is_master = true
      }

      gestures {
          workspace_swipe = on
      }

      windowrule = float, ^(nwg-displays)$
      windowrule = float, ^(qt5ct|qt6ct)$
      windowrule = float, ^(waypaper)$
      windowrulev2 = float, title:^(Picture-in-Picture)$
      windowrulev2 = pin, title:^(Picture-in-Picture)$
      windowrulev2 = float, title:^(Qalculate!)$
      windowrulev2 = float, class:^(org.kde.polkit-kde-authentication-agent-1)$
      layerrule=noanim,selection

      # idle inhibit while watching videos
      windowrulev2 = idleinhibit focus, class:^(mpv)$
      windowrulev2 = idleinhibit fullscreen, class:^(firefox)$

      $mainMod = SUPER
      bind = $mainMod, RETURN, exec, footclient
      bind = $mainMod, B, exec, firefox
      bind = $mainMod, X, killactive, 
      bind = $mainMod, D, exec, pkill fuzzel || fuzzel
      bind = $mainMod, E, exec, pcmanfm-qt
      bind = $mainMod, F, fullscreen,
      bind = $mainMod, I, exec, emacsclient -c -a 'emacs'
      bind = $mainMod, O, exec, pkill fuzzel || ~/scripts/commands.sh
      bind = $mainMod, M, togglespecialworkspace, default
      bind = $mainMod, P, pseudo,
      bind = $mainMod, Q, exec, wlogout 
      bind = $mainMod, R, exec, pkill -SIGUSR2 waybar # reload waybar
      bind = $mainMod, T, togglefloating, 
      bind = $mainMod, W, exec, waypaper
      bind = $mainMod, Z, togglesplit,

      bind = $mainMod SHIFT, C, centerwindow,
      bind = $mainMod SHIFT, F, exec, pkill -SIGUSR1 waybar # toggle waybar
      bind = $mainMod SHIFT, M, movetoworkspace, special:default
      bind = $mainMod SHIFT, P, pin,
      bind = $mainMod SHIFT, X, exec, hyprctl kill

      bind = $mainMod  CTRL, F, fakefullscreen,

      bind = $mainMod ALT, H, movewindoworgroup, l
      bind = $mainMod ALT, J, movewindoworgroup, d
      bind = $mainMod ALT, K, movewindoworgroup, u
      bind = $mainMod ALT, L, movewindoworgroup, r

      bind = $mainMod ALT, G, togglegroup
      bind = $mainMod ALT, N, changegroupactive, f

      bind = $mainMod, H, movefocus, l
      bind = $mainMod, J, movefocus, d
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, L, movefocus, r

      bind = $mainMod SHIFT, H, resizeactive, -100 0
      bind = $mainMod SHIFT, J, resizeactive, 0 -100
      bind = $mainMod SHIFT, K, resizeactive, 0 100
      bind = $mainMod SHIFT, L, resizeactive, 100 0

      ${builtins.concatStringsSep "\n"
        (map
          (x: "bind = $mainMod, " + (toString x)
              + ", workspace, " + (toString x))
          [1 2 3 4 5 6 7 8 9])}

      ${builtins.concatStringsSep "\n"
        (map
          (x: "bind = $mainMod SHIFT, " + (toString x)
              + ", movetoworkspace, " + (toString x))
          [1 2 3 4 5 6 7 8 9])}

      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow


      bind = , Print                , exec, grim -g "$(slurp)" - | swappy -f -
      bind = , xf86audioraisevolume , exec, ~/.config/hypr/volume.sh up
      bind = , xf86audiolowervolume , exec, ~/.config/hypr/volume.sh down
      bind = , xf86audiomute        , exec, ~/.config/hypr/volume.sh mute
      bind = , xf86audiomicmute     , exec, ~/.config/hypr/volume.sh mute-mic
      bind = , xf86monbrightnessup  , exec, ~/.config/hypr/brightness.sh up
      bind = , xf86monbrightnessdown, exec, ~/.config/hypr/brightness.sh down
      bind = , xf86display          , exec, nwg-displays
      bind = , xf86calculator       , exec, qalculate-qt
      bind = , xf86Launch2          , exec, grim - | swappy -f -
      bind = SHIFT, Print           , exec, grim -g "$(slurp)" -t ppm - | ${pkgs.tesseract5}/bin/tesseract - - | wl-copy

      bind = , cancel,  pass, ^(com\.obsproject\.Studio)$

      bind = $mainMod, Insert, submap, passthru
      submap = passthru
      bind = $mainMod, Escape, submap, reset
      submap = reset
      '';
  };
}
