{ pkgs, lib, ... }: {
  home.packages = [pkgs.rofi];
  home.activation.nvim = lib.mkAfter ''
  ln -sf $HOME/Documents/nix-config/home/config/rofi $HOME/.config/
  '';
}
