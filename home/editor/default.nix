{ pkgs, inputs, ... }: {
  imports = [ inputs.nvim.homeModule ];
  home.sessionVariables.EDITOR = "vi";
  nvim = {
    enable = true;
    packageNames = ["nvim"];
  };
}
