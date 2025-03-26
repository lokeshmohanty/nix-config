{
  programs.qutebrowser = {
    enable = true;
    searchEngines = {
      DEFAULT = "https://www.google.com/search?hl=en&q={}";
      g = "https://www.google.com/search?hl=en&q={}";
      y = "https://youtube.com/results?search_query={}";
      ai = "https://www.perplexity.ai/search/new?q={}";
      ud = "https://www.urbandictionary.com/define.php?term={}";
    };
  };
}

