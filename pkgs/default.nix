{ pkgs, inputs }:

let
  system = pkgs.system;
  utils = inputs.nixCats.utils;
  pluginOverlay = utils.standardPluginOverlay inputs;
  nvimPkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [ pluginOverlay ];
  };
  nvim = import ./nvim { pkgs = nvimPkgs; inherit utils; };
in { inherit nvim; }
