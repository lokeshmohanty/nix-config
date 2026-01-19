{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nvim.homeModule
  ];
  home.packages = with pkgs; [
    logseq
  ];
  home.sessionVariables.EDITOR = "vi";
  nvim = {
    enable = true;
    packageNames = ["nvim"];
  };
  programs.neovide = {
    enable = true;
    # settings = {
    #   font = {
    #     normal = "Cascadia Code";
    #     size = 14.0;
    #   };
    # };
  };
}
