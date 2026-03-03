# My Dotfiles in Nix

## NixOS

- Apply system configuration (`nixos-install --flake .#hostname` on live installation media)

```sh
sudo nixos-rebuild switch --flake .#sudarshan
# nh variant (path isn't required if programs.nh.flake is defined)
nh os switch . -c sudarshan
````

- Apply home configuration

```sh
nix shell nixpkgs#home-manager
home-manager switch --flake .#lokesh@sudarshan
```

- Update flake
```sh
nix flake update
```


## Nix

- Install `nix` 
  - [DeterminateSystems](https://github.com/DeterminateSystems/nix-installer)
  - [Official](https://nixos.org/download.html)
  - [Nix Portable (no root)](https://github.com/DavHau/nix-portable)

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
nix run github:lokeshmohanty/nix#nvim
```

## Dotfiles Setup

- Make git ignore machine specific configuration while keeping the default config in repository

```sh
git update-index --skip-worktree ./config/hypr/monitors.conf
git update-index --skip-worktree ./config/hypr/workspaces.conf
```

- You can get list of files that are marked to be skipped with

```sh
git ls-files -v . | grep ^S
```


# References

- **Template** : [nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- **Official** : [nixos](https://nixos.org/learn.html), [home-manager](https://nix-community.github.io/home-manager/index.html), [flakes](https://nixos.wiki/wiki/Flakes)
- **Examples** : [misterio77](https://github.com/misterio77/nix-config)
- **Blogs**    : [flakes: tweag](https://www.tweag.io/blog/2020-05-25-flakes/), [flakes: Li Yang](https://tech.aufomm.com/my-nixos-journey-flakes/), [nix: Li Yang](https://tech.aufomm.com/my-nix-journey-use-nix-with-ubuntu/)

# TODO 

- Using [secrets](https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/#sops-nix)
- Modularize (<https://www.youtube.com/watch?v=-TRbzkw6Hjs>)
- Enable secure boot (<https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md>)
- Use <https://github.com/fufexan/nix-gaming>

