{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # gui applications
    google-chrome
    onlyoffice-desktopeditors
    motrix
    zotero
    (inkscape-with-extensions.override { inkscapeExtensions = [ inkscape-extensions.textext ]; })
    # krita
    vscode-fhs
    bruno

    # cli applications
    # tesseract
    aria2
    gh

    # system utilities
    inxi
    fastfetch
    bat
    duf
    libtool
    zip
    unzip
    unrar
    file
    powertop
    htop
    bottom
    openconnect
    networkmanager-openconnect
    bluetuith

    # other utilities
    quickemu
    waypipe
    distrobox
    docker-compose
    # hledger

    ## programming languages
    uv
    swig
    (pkgs.python3.withPackages (
      ps: with ps; [
        pip
        ipython
        matplotlib
        jupyterlab
        setuptools
        pytest
      ]
    ))
    gnumake
    gcc
    nodejs
    lua
    # cmakeWithGui
    # shellcheck
    # quarto

    ## latex
    texlive.combined.scheme-full
    texlab
    typst

    ## nix
    nix-your-shell # use fish in nix develop / nix shell ...
    nixd
    nixfmt # language server and formatter
    devenv
  ];
}
