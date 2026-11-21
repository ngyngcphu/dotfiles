# dotfiles

My macOS setup as code: Neovim (lazy.nvim, native LSP, treesitter, Mason), tmux and iTerm2.

## Install on a new Mac

```sh
git clone git@github.com:ngyngcphu/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

> Fresh machine without SSH keys yet? Clone over HTTPS instead:
> `git clone https://github.com/ngyngcphu/dotfiles.git ~/dotfiles`

`install.sh` provisions everything and is safe to re-run:

1. Xcode Command Line Tools (if missing, it opens the installer: finish it and run the script again)
2. Homebrew, then every package in the [`Brewfile`](Brewfile): Neovim, tmux, iTerm2, ripgrep, fd, lazygit,
   tree-sitter CLI, Node/Go/Python, terraform, buf, jdtls, ImageMagick, and the Meslo Nerd Font
3. Symlinks into this repo (anything already there is backed up as `*.bak.<timestamp>`)
4. tmux plugins via tpm
5. Neovim plugins at the exact versions in `nvim/lazy-lock.json`, plus all treesitter parsers,
   language servers, formatters and linters (Mason)
6. iTerm2: the `dotfiles` profile (font, coolnight colors, window and mouse settings) and app settings

The first run takes about 25 minutes, mostly cloning plugins, compiling treesitter parsers and building Go tools.

After it finishes, restart iTerm2 so it opens with the `dotfiles` profile.

## Layout

| Repo path | Linked to |
| --- | --- |
| `nvim/` | `~/.config/nvim` |
| `tmux/tmux.conf` | `~/.config/tmux/tmux.conf` |
| `iterm2/profile.json` | `~/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json` |
| `iterm2/settings.sh` | app-wide iTerm2 settings, applied with `defaults write` by `install.sh` |

Edit files in `~/dotfiles` (or through the links, same thing), then commit and push.
tmux plugins live in `~/.config/tmux/plugins` and Neovim plugins in `~/.local/share/nvim`, outside the repo.

## Updating

| What | How |
| --- | --- |
| Neovim plugins | `:Lazy update`, then commit `nvim/lazy-lock.json` |
| Language servers and tools | `:MasonToolsUpdate` |
| Treesitter parsers | `:TSUpdate` |
| tmux plugins | `prefix + U` (tpm) |
| tmux config | edit `tmux/tmux.conf`, then `prefix + r` to reload |
| iTerm2 profile | edit `iterm2/profile.json`; iTerm2 reloads it live (changes made in iTerm2's Settings UI are **not** saved back to the file) |
| iTerm2 app settings | edit `iterm2/settings.sh`, run `bash ~/dotfiles/iterm2/settings.sh`, restart iTerm2 |
| System packages | `brew bundle --file=~/dotfiles/Brewfile` |

The tmux prefix is `Ctrl-a`.

To add a language to Neovim: put its parser in `nvim/lua/ngyngcphu/plugins/treesitter.lua`, its Mason packages in
`nvim/lua/ngyngcphu/plugins/lsp/mason.lua` and its formatter in `nvim/lua/ngyngcphu/plugins/formatting.lua`.

## Notes

- Requires Neovim 0.12+ (installed by the Brewfile).
