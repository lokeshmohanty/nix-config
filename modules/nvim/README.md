# Neovim Configuration

## Directory Structure

This configuration primarily uses the following directory structure:

- The `lua/` directory for core configurations.
- The `after/plugin/` directory to demonstrate compatibility.

While this structure works well, you are encouraged to further modularize your setup by utilizing any of the runtime directories checked by Neovim:

- `ftplugin/` for file-type-specific configurations.
- `plugin/` for global plugin configurations.
- Even `pack/*/{start,opt}/` work if you want to make a plugin inside your configuration.
- And so on...

If you are unfamiliar with the above, refer to the [Neovim runtime path documentation](https://neovim.io/doc/user/options.html#'rtp').

---

> "Idiomatic" here means:
>
> - This configuration does **not** use `lazy.nvim`, and does not use `mason.nvim` when nix is involved.
> - `nixCats` is responsible for downloading all plugins.
> - Plugins are only loaded if their respective category is enabled.
> - The [Lua utilities template](https://github.com/BirdeeHub/nixCats-nvim/tree/main/templates/luaUtils/lua/nixCatsUtils) is used (see [`:h nixCats.luaUtils`](https://nixcats.org/nixCats_luaUtils.html)).
> - [`lze`](https://github.com/BirdeeHub/lze) or [`lz.n`](https://github.com/nvim-neorocks/lz.n) is used for lazy loading.

---

## Usage

```sh
    nix run github:lokeshmohanty/nix-config?dir=modules/nixCats#nixCats
```

- Make a symlink of `snippets` at `~/.config/nvim/snippets`
