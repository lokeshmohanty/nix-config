{
  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = true;
    searchEngines = {
      DEFAULT = "https://www.google.com/search?hl=en&q={}";
      g = "https://www.google.com/search?hl=en&q={}";
      y = "https://youtube.com/results?search_query={}";
      ai = "https://www.perplexity.ai/search/new?q={}";
      ud = "https://www.urbandictionary.com/define.php?term={}";
      gr = "https://grok.com/?q={}";
    };
    settings = {
      auto_save.session = true;
      url.default_page = "qute://bookmarks";
      url.start_pages = ["qute://bookmarks"];
      content.autoplay = false;
    };
    keyBindings = {
      normal = {
        "H" = "tab-prev";
        "L" = "tab-next";
        "J" = "back";    # back in history
        "K" = "forward"; # forward in history
      };
    };
  };
}

