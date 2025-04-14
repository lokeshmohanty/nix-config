{
  pkgs,
  inputs,
  ...
}: {
  neovim =
    (inputs.nvf.lib.neovimConfiguration {
      pkgs = pkgs;
      modules = [../modules/neovim];
    })
    .neovim;
}
