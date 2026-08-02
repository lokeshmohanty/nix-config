# Local SearXNG meta-search instance for pi's `web_search` tool.
#
# pi-web-access (the package behind pi's web_search) has no native
# DuckDuckGo provider. SearXNG is a self-hostable meta-engine, so we run a
# localhost-only instance and point pi-web-access at it via `searxngBaseUrl`
# in config/agentic-harness/pi/web-search.json.
#
# Local-only: bound to 127.0.0.1, no nginx/uwsgi, no redis, limiter off.
# The SSRF guard in pi-web-access blocks the literal hostname "localhost" but
# allows 127.0.0.1 when 127.0.0.0/8 is listed in `ssrf.allowRanges`, so the
# config uses http://127.0.0.1:8888 (not http://localhost:8888).
{
  lib,
  config,
  ...
}:
{
  options.searxng.enable = lib.mkEnableOption "local SearXNG search backend for pi web_search";

  config = lib.mkIf config.searxng.enable {
    services.searx = {
      enable = true;
      # Use the built-in HTTP server (no uwsgi/nginx needed for localhost use).
      configureUwsgi = false;
      redisCreateLocally = false;
      settings = {
        # Load SearXNG defaults (server/outgoing/etc.) but restrict the engine
        # list to Bing only. SearXNG's settings_loader expects
        # use_default_settings.engines to be a dict with `keep_only`/`remove`,
        # NOT a boolean: a bool here crashes update_settings with
        # "'bool' object has no attribute 'get'". Engine names are lowercase
        # and the `engines` override below merges into the kept default by name.
        #
        # Why Bing only (measured 2026-08-02 on sudarshan): this host's IP is
        # reputation-flagged by the other no-API-key engines. DuckDuckGo's
        # html/lite endpoints return a CAPTCHA (SearxEngineCaptchaException);
        # Brave returns HTTP 429 (too many requests); Mojeek and Qwant return
        # HTTP 403 / access-denied. Bing (www.bing.com/search) returns 7-10
        # clean results per query reliably. SearXNG ships bing disabled by
        # default, so it is enabled explicitly here. If Bing ever degrades,
        # re-enable duckduckgo/brave/qwant/mojeek in keep_only (and add
        # `disabled = false` overrides for those SearXNG ships disabled).
        use_default_settings = {
          engines.keep_only = [ "bing" ];
        };

        general = {
          debug = false;
          instance_name = "SearXNG (local)";
        };

        server = {
          bind_address = "127.0.0.1";
          port = 8888;
          # Cookie/session signing key for a loopback-only, unauthenticated
          # instance. Not a credential: knowing it grants no access to
          # anything (the service is reachable only on this host). SearXNG
          # refuses to start with the default placeholder value, so set our own.
          secret_key = "lokesh-searxng-local";
          limiter = false; # bot protection needs redis; off for local use
          image_proxy = false;
          public_instance = false;
        };

        search = {
          # pi-web-access requests format=json, so ensure JSON is permitted.
          formats = [
            "html"
            "json"
          ];
          default_lang = "en";
        };

        engines = [
          {
            name = "bing"; # disabled by default in SearXNG -> enable here
            engine = "bing";
            shortcut = "bi";
            disabled = false;
          }
        ];
      };
    };
  };
}
