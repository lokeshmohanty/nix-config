{
  inputs,
  config,
  pkgs,
  self,
  ...
}:
{
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  nixpkgs = {
    overlays = [
      inputs.nix-alien.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "lokesh";
    homeDirectory = "/home/lokesh";
    sessionPath = [ "$HOME/.local/bin" "$HOME/.cargo/bin" ];
    sessionVariables = {
      LESSHISTFILE = config.xdg.cacheHome + "/less/history";
      LESSKEY = config.xdg.configHome + "/less/lesskey";
      WINEPREFIX = config.xdg.dataHome + "/wine";
      # enable scrolling in git diff
      DELTA_PAGER = "less -R";
      TERM = "xterm-256color";
      NIXCONFIG = config.vars.nixDir;
      NIXPKGS_ALLOW_UNFREE=1;
    };
    packages = with pkgs; [
      self.packages.${pkgs.stdenv.hostPlatform.system}.ghost-build
      postgresql

      # Misc
      tlrc # rust client for tldr
      # cowsay
      gnupg
      gnumake

      # tui applications
      lazygit
      lazysql
      lazydocker

      pandoc
      pass
      rclone
      yt-dlp
      ffmpeg

      sqlite

      fzf
      fd # fd alternative
      sd # sed alternative
      ripgrep # grep alternative

      yq-go # yaml processor https://github.com/mikefarah/yq
      just # a command runner like make, but simpler
      delta # A viewer for git and diff output
      hyperfine # command-line benchmarking tool
      gping # ping, but with a graph(TUI)
      doggo # DNS client for humans
      duf # Disk Usage/Free Utility - a better 'df' alternative
      gdu # disk usage analyzer(replacement of `du`)
      qrcp # for generating qr code for file transfer

      # nix related
      nix-alien # run unpatched binaries

      # it provides the command `nom` works just like `nix
      # with more details log output
      nix-output-monitor
      nix-index # A small utility to index nix store paths

      # productivity
      # croc # File transfer between computers securely and easily

      # other
      # remmina
      # freerdp # remote desktop client
    ];
  };

  ## Nix Helper
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "${config.vars.nixDir}";
  };

  programs.zathura = {
    enable = true;
    extraConfig = ''
      set synctex true
      set synctex-editor-command "nvim --headless -c \"VimtexInverseSearch %{line} '%{input}'\""
    '';
  };
  programs.sioyek = {
    enable = true;
    config = {
      # ── SyncTeX ────────────────────────────────────────────────────────────
      inverse_search_command = "nvim --headless -c \"VimtexInverseSearch %2 '%1'\"";
      should_open_new_pdf_in_existing_window = "1";
      should_load_tutorial_when_no_other_file = "0";

      # ── Rendering ──────────────────────────────────────────────────────────
      # Higher = sharper text at normal zoom levels
      linear_filter_ppm = "3000";

      # ── Scroll & zoom ──────────────────────────────────────────────────────
      smooth_scroll_speed = "3";
      vertical_move_amount = "0.15";   # fraction of screen per j/k
      horizontal_move_amount = "0.08";
      zoom_inc_factor = "1.15";        # per +/- press

      # ── Page layout ────────────────────────────────────────────────────────
      page_separator_width = "2";
      fit_to_page_width_on_load = "1";

      # ── Ruler / highlights ─────────────────────────────────────────────────
      should_use_ruler_to_highlight = "1";
      ruler_padding = "0.1";
      ruler_x_padding = "0.1";

      # ── Dark mode ──────────────────────────────────────────────────────────
      dark_mode_contrast = "0.8";
      default_dark_mode = "0";

      # ── External search engines (used by 'e' / shift_click) ────────────────
      search_url_0 = "https://scholar.google.com/scholar?q=%s";
      search_url_1 = "https://www.semanticscholar.org/search?q=%s";
      middle_click_search_engine = "0";
      shift_click_search_engine  = "1";
    };

    bindings = {
      # ── Navigation ─────────────────────────────────────────────────────────
      move_down            = "j <down>";
      move_up              = "k <up>";
      move_left            = "h <left>";
      move_right           = "l <right>";
      move_down_fast       = "J";
      move_up_fast         = "K";
      screen_down          = "<C-d>";        # half-page down
      screen_up            = "<C-u>";        # half-page up
      next_page            = "<C-f> ]";
      prev_page            = "<C-b> [";
      goto_beginning       = "gg";           # first page
      goto_end             = "G";            # last page
      goto_page_with_page_number = "ng";     # type number then ng

      # ── Zoom ───────────────────────────────────────────────────────────────
      zoom_in              = "= +";
      zoom_out             = "-";
      fit_to_page_width_smart = "z";
      fit_to_page_width    = "zw";
      fit_to_page_height   = "zh";

      # ── Search ─────────────────────────────────────────────────────────────
      search               = "/";
      search_backward      = "?";
      next_search_match    = "n";
      prev_search_match    = "N";

      # ── Marks (vim-style) ──────────────────────────────────────────────────
      set_mark             = "m";
      goto_mark            = "'";

      # ── Bookmarks ──────────────────────────────────────────────────────────
      add_bookmark         = "b";
      goto_bookmark        = "B";
      delete_bookmark      = "db";

      # ── Table of contents ──────────────────────────────────────────────────
      goto_toc             = "t";

      # ── Visual select / copy ───────────────────────────────────────────────
      toggle_visual_mode   = "v";
      copy                 = "y";
      keyboard_select      = "f";  # vimium-like label-based text select

      # ── Highlights ─────────────────────────────────────────────────────────
      add_highlight        = "H";
      next_highlight       = "]h";
      prev_highlight       = "[h";
      goto_highlight       = "gh";
      delete_highlight     = "dh";

      # ── Portals (split reference view) ─────────────────────────────────────
      portal               = "p";
      goto_portal          = "P";
      delete_portal        = "dp";
      next_portal          = "]p";
      prev_portal          = "[p";

      # ── Smart jump (figures / equations) ───────────────────────────────────
      smart_jump_under_cursor = "<C-]>";   # jump to referenced figure/eq
      overview_definition  = "gd";         # open definition in overview
      portal_to_overview   = "go";
      close_overview       = "<escape>";

      # ── SyncTeX ────────────────────────────────────────────────────────────
      turn_on_synctex      = "F4";
      synctex_under_cursor = "<C-s>";      # jump to editor from PDF location

      # ── External search ────────────────────────────────────────────────────
      external_search      = "e";          # search selected text (url 0)

      # ── UI ─────────────────────────────────────────────────────────────────
      toggle_fullscreen        = "F";
      toggle_dark_mode         = "D";
      toggle_presentation_mode = "<F5>";
      toggle_status_bar        = "S";

      # ── File operations ────────────────────────────────────────────────────
      open_document          = "o";
      open_document_embedded = "O";
      open_last_document     = "<C-o>";
      reload                 = "r";

      # ── Rotation ───────────────────────────────────────────────────────────
      rotate_clockwise        = ">";
      rotate_counterclockwise = "<";

      # ── Command palette ────────────────────────────────────────────────────
      command                = ":";
    };
  };
  # programs.keychain = { enable = true; keys = [ "id_ed25519" ]; };
  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-dash ];
  };
  programs.nix-index.enable = true;

  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = [ "qemu:///system" ];
  #     uris = [ "qemu:///system" ];
  #   };
  # };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
