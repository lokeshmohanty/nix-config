# My Dotfiles in Nix

## NixOS

- Apply system configuration (`nixos-install --flake .#hostname` on live installation media)

    ```sh
    sudo nixos-rebuild switch --flake .#sudarshan
    ````

- Apply home configuration

    ```sh
    nix shell nixpkgs#home-manager
    home-manager switch --flake .#lokesh@sudarshan
    ```


## Nix

- Install `nix` ([DeterminateSystems](https://github.com/DeterminateSystems/nix-installer), [Official](https://nixos.org/download.html))

    ```sh
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    ```

- Copy packages across systems over ssh ([package management](https://nixos.org/manual/nix/stable/package-management/copy-closure))

    ```sh
    nix-copy-closure --to <username>@<ip> $(type -p <package-name>)
    ```

## Neovim

- To run my configuration of neovim

```sh
    nix run github:lokeshmohanty/nix-config?dir=modules/nixCats#nixCats
```

# References

- **Template** : [nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- **Official** : [nixos](https://nixos.org/learn.html), [home-manager](https://nix-community.github.io/home-manager/index.html), [flakes](https://nixos.wiki/wiki/Flakes)
- **Examples** : [misterio77](https://github.com/misterio77/nix-config)
- **Blogs**    : [flakes: tweag](https://www.tweag.io/blog/2020-05-25-flakes/), [flakes: Li Yang](https://tech.aufomm.com/my-nixos-journey-flakes/), [nix: Li Yang](https://tech.aufomm.com/my-nix-journey-use-nix-with-ubuntu/)

# TODO 

- Modularize (<https://www.youtube.com/watch?v=vYc6IzKvAJQ>)
- Enable secure boot (<https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md>)
- Use <https://github.com/fufexan/nix-gaming>

