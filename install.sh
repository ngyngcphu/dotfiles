#!/usr/bin/env bash
# One-command setup for this Neovim config on macOS. Safe to re-run.
#   git clone git@github.com:ngyngcphu/nvim-config.git ~/.config/nvim && ~/.config/nvim/install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

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
brew bundle --file="$REPO_DIR/Brewfile"

if [[ "$REPO_DIR" != "$TARGET" ]]; then
	step "Linking $TARGET -> $REPO_DIR"
	if [[ -e "$TARGET" || -L "$TARGET" ]]; then
		backup="$TARGET.bak.$(date +%Y%m%d%H%M%S)"
		mv "$TARGET" "$backup"
		echo "Existing config moved to $backup"
	fi
	mkdir -p "$(dirname "$TARGET")"
	ln -s "$REPO_DIR" "$TARGET"
fi

step "Plugins (lazy-lock.json), treesitter parsers, language servers and tools — this takes a while"
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

step "Done — run nvim"
