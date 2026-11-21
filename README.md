# dotfiles

My macOS setup as code: every CLI tool I use, zsh (oh-my-zsh + powerlevel10k), git, Neovim (lazy.nvim, native LSP,
treesitter, Mason), tmux and iTerm2.

## Install on a new Mac

```sh
git clone git@github.com:ngyngcphu/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

> Fresh machine without SSH keys yet? Clone over HTTPS instead:
> `git clone https://github.com/ngyngcphu/dotfiles.git ~/dotfiles`

`install.sh` provisions everything and is safe to re-run:

1. Xcode Command Line Tools (if missing, it opens the installer: finish it and run the script again)
2. Homebrew, then everything in the [`Brewfile`](Brewfile): git/gh, Neovim, tmux, Go, Node.js, pnpm, yarn, Python,
   Java + Maven, Colima + Docker CLI (buildx, compose), kubectl, kubectx, Helm, Argo CD, Terraform, buf, protoc,
   grpcurl, k6, atlas, dbmate, psql, mysql, redis, iTerm2, the Meslo Nerd Font, and Go tools
   (`mc`, `protoc-gen-go`, `protoc-gen-go-grpc`, `staticcheck`)
3. Tools with their own installers: Rust (rustup), uv, bun and Claude Code
4. oh-my-zsh, powerlevel10k, zsh-autosuggestions and zsh-syntax-highlighting
5. Symlinks into this repo (anything already there is backed up as `*.bak.<timestamp>`); asks for your git name and email
6. Docker: points the CLI at Homebrew's buildx and compose plugins
7. tmux plugins via tpm
8. Neovim plugins at the exact versions in `nvim/lazy-lock.json`, plus all treesitter parsers,
   language servers, formatters and linters (Mason)
9. iTerm2: the `dotfiles` profile (font, coolnight colors, window and mouse settings) and app settings

The first run takes about 25 minutes, mostly cloning plugins, compiling treesitter parsers and building Go tools.

After it finishes, restart iTerm2 so it opens with the `dotfiles` profile and the new shell config.
Then copy over the private files the repo doesn't hold (see below).

## Layout

| Repo path | Linked to |
| --- | --- |
| `zsh/zshrc`, `zsh/zprofile`, `zsh/zshenv` | `~/.zshrc`, `~/.zprofile`, `~/.zshenv` |
| `zsh/p10k.zsh` | `~/.p10k.zsh` (prompt; regenerate with `p10k configure`) |
| `git/gitconfig` | `~/.gitconfig` |
| `nvim/` | `~/.config/nvim` |
| `tmux/tmux.conf` | `~/.config/tmux/tmux.conf` |
| `iterm2/profile.json` | `~/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json` |
| `iterm2/settings.sh` | app-wide iTerm2 settings, applied with `defaults write` by `install.sh` |

Edit files in `~/dotfiles` (or through the links, same thing), then commit and push.
This repo is public, so private settings stay out of it, in files `install.sh` never touches:

| File | Holds |
| --- | --- |
| `~/.zshrc.local` | work settings (`GOPRIVATE`, Teleport kubectl wrappers), sourced at the end of `~/.zshrc` |
| `~/.gitconfig.local` | git name and email (`install.sh` asks for them) |
| `~/.ssh`, `~/.kube`, `~/.npmrc`, `~/.docker/config.json` | keys, kubeconfigs, registry tokens |

Teleport (`tsh`) is installed separately, at the version your cluster runs.

tmux plugins live in `~/.config/tmux/plugins` and Neovim plugins in `~/.local/share/nvim`, outside the repo.

## Shell aliases and completion

Tab completion works for every tool in the Brewfile and for rustup, cargo, uv and bun. Completion and aliases come
from oh-my-zsh plugins listed in `zsh/zshrc`. Some of the aliases:

| Tool | Aliases |
| --- | --- |
| kubectl | `k` (uses `~/.kube/config`), `kgp` get pods, `kaf` apply -f, `kl` logs, `keti` exec -it |
| docker / compose | `dps`, `dpsa`, `dils` images, `dxcit` exec -it, `dco`, `dcup`, `dcdn` |
| terraform | `tf`, `tfi` init, `tfp` plan, `tfa` apply, `tfv` validate |
| git | `gst` status, `gco` checkout, `gp` push, `gl` pull, `glog` |
| go / uv / mvn | `gob` build, `got` test, `gor` run · `uvr` run, `uva` add, `uvs` sync · `mvnci` clean install |
| brew | `bubo` outdated, `bubu` update + upgrade |

Run `als` to list every alias, or `als -g <plugin>` for one plugin. Put your own aliases at the end of `zsh/zshrc`
(or in `~/.zshrc.local` if they're private). To add completion for a new tool, add its oh-my-zsh plugin to
`plugins=(...)`, or add it to the `for _cmd in ...` loop if it has a `<tool> completion zsh` command.

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
| Homebrew packages and Go tools | `brew bundle --file=~/dotfiles/Brewfile` (also upgrades) |
| A new tool | add it to the `Brewfile`, then run the line above; `brew bundle cleanup --file=~/dotfiles/Brewfile` lists anything installed that isn't in it |
| Rust, uv, bun | `rustup update`, `uv self update`, `bun upgrade` |
| Claude Code | updates itself |
| oh-my-zsh | `omz update` |

The tmux prefix is `Ctrl-a`.

To add a language to Neovim: put its parser in `nvim/lua/ngyngcphu/plugins/treesitter.lua`, its Mason packages in
`nvim/lua/ngyngcphu/plugins/lsp/mason.lua` and its formatter in `nvim/lua/ngyngcphu/plugins/formatting.lua`.

## Notes

- Requires Neovim 0.12+ (installed by the Brewfile).
