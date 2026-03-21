# Reference: https://github.com/Satty-org/Satty
{
  programs.satty = {
    enable = true;
    settings = {
      general = {
        corner-roundness = 12;
        initial-tool = "brush";
        output-filename = "~/Pictures/Screenshots/%Y-%m-%d_%H:%M:%S.png";
      };
      font.family = "Cascadia Code";
    };
  };
}
