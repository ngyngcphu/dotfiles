#!/usr/bin/env bash
# One-command setup for these dotfiles (Neovim + tmux) on macOS. Safe to re-run.
#   git clone git@github.com:ngyngcphu/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# link <source in repo> <target>: symlink target -> source, backing up anything already there
link() {
	local src="$1" dst="$2"
	if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
		echo "ok      $dst"
		return
	fi
	if [[ -e "$dst" || -L "$dst" ]]; then
		local backup
		backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
		mv "$dst" "$backup"
		echo "backup  $dst -> $backup"
	fi
	mkdir -p "$(dirname "$dst")"
	ln -s "$src" "$dst"
	echo "link    $dst -> $src"
}

[[ "$(uname -s)" == Darwin ]] || { echo "This script only supports macOS." >&2; exit 1; }

step "Xcode Command Line Tools (git, make, clang, clangd, sourcekit-lsp)"
if ! xcode-select -p >/dev/null 2>&1; then
	xcode-select --install || true
	echo "Finish the Command Line Tools installer that just opened, then run this script again."
	exit 1
fi

step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
else
	eval "$(/usr/local/bin/brew shellenv)"
fi

step "System packages (Brewfile)"
brew bundle --file="$DOTFILES/Brewfile"

step "Config links"
link "$DOTFILES/nvim" "$CONFIG/nvim"
link "$DOTFILES/tmux/tmux.conf" "$CONFIG/tmux/tmux.conf"
# tmux reads ~/.tmux.conf before ~/.config/tmux/tmux.conf, so move an old one out of the way
if [[ -e "$HOME/.tmux.conf" || -L "$HOME/.tmux.conf" ]]; then
	mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$(date +%Y%m%d%H%M%S)"
	echo "backup  ~/.tmux.conf (it would override the linked config)"
fi

step "tmux plugins (tpm)"
TPM="$CONFIG/tmux/plugins/tpm"
[[ -d "$TPM" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM"
"$TPM/bin/install_plugins"
# reload a running tmux server so it picks up the config and plugins
if tmux info >/dev/null 2>&1; then tmux source-file "$CONFIG/tmux/tmux.conf"; fi

step "Neovim: plugins (lazy-lock.json), treesitter parsers, language servers and tools — this takes a while"
# NVIM_BOOTSTRAP=1 makes the config install parsers and Mason packages synchronously.
# The second pass only retries what failed (e.g. a flaky download) and takes seconds otherwise.
for _ in 1 2; do
	NVIM_BOOTSTRAP=1 nvim --headless "+Lazy! restore" +qa
done

step "Terminal"
# iTerm2: never drop mouse reporting when the reported host changes; otherwise the mouse wheel
# can start scrolling iTerm2's own history instead of reaching tmux/Neovim.
defaults write com.googlecode.iterm2 NoSyncTurnOffMouseReportingOnHostChange -bool false
echo "Set your terminal font to \"MesloLGS Nerd Font Mono\" so icons render."

step "Done — open a new terminal, run tmux and nvim"
