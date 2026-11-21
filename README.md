# nvim-config

My Neovim setup (lazy.nvim, native LSP, treesitter, Mason) for macOS.

## Install on a new Mac

```sh
git clone git@github.com:ngyngcphu/nvim-config.git ~/.config/nvim
~/.config/nvim/install.sh
```

> Fresh machine without SSH keys yet? Clone over HTTPS instead:
> `git clone https://github.com/ngyngcphu/nvim-config.git ~/.config/nvim`

`install.sh` provisions everything and is safe to re-run:

1. Xcode Command Line Tools (if missing, it opens the installer: finish it and run the script again)
2. Homebrew, then every package in the [`Brewfile`](Brewfile): Neovim, ripgrep, fd, lazygit, tree-sitter CLI,
   Node/Go/Python, terraform, buf, jdtls, ImageMagick, and the Meslo Nerd Font
3. All plugins at the exact versions in `lazy-lock.json`
4. All treesitter parsers, language servers, formatters and linters (Mason)

The first run takes about 25 minutes, mostly cloning plugins, compiling treesitter parsers and building Go tools.

After it finishes, set your terminal font to **MesloLGS Nerd Font Mono** so icons render, then run `nvim`.

## Updating

| What | How |
| --- | --- |
| Plugins | `:Lazy update`, then commit `lazy-lock.json` |
| Language servers and tools | `:MasonToolsUpdate` |
| Treesitter parsers | `:TSUpdate` |
| System packages | `brew bundle --file=~/.config/nvim/Brewfile` |

To add a language: put its parser in `lua/ngyngcphu/plugins/treesitter.lua`, its Mason packages in
`lua/ngyngcphu/plugins/lsp/mason.lua` and its formatter in `lua/ngyngcphu/plugins/formatting.lua`.

## Notes

- Requires Neovim 0.12+ (installed by the Brewfile).
- Flutter support (flutter-tools.nvim) only loads when `flutter` is on your `PATH`; install the Flutter SDK
  separately if you need it.
- tmux config is not part of this repo; the vim-tmux-navigator plugin expects the matching tmux plugin.
