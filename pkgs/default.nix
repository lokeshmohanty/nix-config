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
  nixCats = inputs.nixCats.utils.mkAllWithDefault (import ../home/editor/nixCats (inputs // { inherit pkgs; }));
}
