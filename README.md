# My Dotfiles in Nix

## Ubuntu installation

Clone the repository as the login user whose home should be configured:

```sh
git clone https://github.com/lokeshmohanty/nix.git ~/.nix
cd ~/.nix
./scripts/install.sh
```

The installer asks `Is Nix required on this system? [y/N]`:

- **Yes:** install/reuse Nix and apply `hosts/server.nix` with Home Manager.
- **No/default:** install the Ubuntu-available package subset with APT and link
  the static configuration files directly.

For noninteractive installation, use either:

```sh
just server-install-nix
just server-install-apt
```

APT mode cannot reproduce Nix-only AI tools, the wrapped Neovim plugin/LSP
closure, or Home Manager-generated shell settings. Existing config paths are
preserved under `~/.local/state/lokesh-config/backups/` before managed links are
created. Full platform requirements and safety behavior are documented in
[the Ubuntu installation guide](docs/how-to/install-ubuntu.md).

## Server Home Manager maintenance

Once Nix is installed, apply the current `lokesh@server` configuration with:

```sh
cd ~/.nix
just server-switch
```

Update only the locked Home Manager input and then apply the server profile:

```sh
cd ~/.nix
just server-update-home-manager
```

The server recipes pass the current login user, home directory, and repository
path to `hosts/server.nix`; do not run them with `sudo`.

## NixOS

- Apply system configuration (`nixos-install --flake .#hostname` on live installation media)

```sh
sudo nixos-rebuild switch --flake .#sudarshan
# nh variant (path isn't required if programs.nh.flake is defined)
nh os switch . -c sudarshan
```

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

# Tips

- Use `nix-prefetch-github` to get the `rev` and `hash` information required for `fetchFromGithub`

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
