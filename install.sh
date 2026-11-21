#!/usr/bin/env bash
# One-command setup for this Mac: tools (Brewfile + official installers), zsh, git, Neovim, tmux, iTerm2.
# Safe to re-run.
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

# clone <repo url> <dir>: shallow clone unless already there
clone() {
	if [[ -d "$2" ]]; then echo "ok      $2"; else git clone --depth 1 "$1" "$2"; fi
}

[[ "$(uname -s)" == Darwin ]] || { echo "This script only supports macOS." >&2; exit 1; }

step "Xcode Command Line Tools (git, make, clang, clangd, swift, sourcekit-lsp)"
if ! xcode-select -p >/dev/null 2>&1; then
	xcode-select --install || true
	echo "Finish the Command Line Tools installer that just opened, then run this script again."
	exit 1
fi

step "Homebrew"
# check the binary, not PATH: a fresh shell may not have Homebrew on PATH yet
if [[ ! -x /opt/homebrew/bin/brew && ! -x /usr/local/bin/brew ]]; then
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
else
	eval "$(/usr/local/bin/brew shellenv)"
fi

step "Homebrew packages, apps and Go tools (Brewfile)"
brew bundle --file="$DOTFILES/Brewfile"

step "Tools with their own installers (skipped when present)"
# --no-modify-path / UV_NO_MODIFY_PATH / SHELL=sh: the linked zsh files already set PATH
if [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
else echo "ok      rustup"; fi
if [[ ! -x "$HOME/.local/bin/uv" ]]; then
	curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
else echo "ok      uv"; fi
if [[ ! -x "$HOME/.bun/bin/bun" ]]; then
	curl -fsSL https://bun.sh/install | SHELL=/bin/sh bash
	IS_BUN_AUTO_UPDATE=true SHELL=zsh "$HOME/.bun/bin/bun" completions >/dev/null 2>&1 || true
else echo "ok      bun"; fi
if [[ ! -x "$HOME/.local/bin/claude" ]]; then
	curl -fsSL https://claude.ai/install.sh | bash
else echo "ok      claude (updates itself)"; fi

step "zsh: oh-my-zsh, powerlevel10k, plugins"
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

step "Config links"
link "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
link "$DOTFILES/zsh/zprofile" "$HOME/.zprofile"
link "$DOTFILES/zsh/zshenv" "$HOME/.zshenv"
link "$DOTFILES/zsh/p10k.zsh" "$HOME/.p10k.zsh"
# an existing ~/.gitconfig holds your identity: keep it as ~/.gitconfig.local instead of a backup
if [[ -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" && ! -e "$HOME/.gitconfig.local" ]]; then
	mv "$HOME/.gitconfig" "$HOME/.gitconfig.local"
	echo "move    ~/.gitconfig -> ~/.gitconfig.local"
fi
link "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
link "$DOTFILES/nvim" "$CONFIG/nvim"
link "$DOTFILES/tmux/tmux.conf" "$CONFIG/tmux/tmux.conf"
# tmux reads ~/.tmux.conf before ~/.config/tmux/tmux.conf, so move an old one out of the way
if [[ -e "$HOME/.tmux.conf" || -L "$HOME/.tmux.conf" ]]; then
	mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$(date +%Y%m%d%H%M%S)"
	echo "backup  ~/.tmux.conf (it would override the linked config)"
fi

step "git identity (~/.gitconfig.local, not in the repo)"
if git config --file "$HOME/.gitconfig.local" user.email >/dev/null 2>&1; then
	echo "ok      $(git config --file "$HOME/.gitconfig.local" user.name)"
elif [[ -t 0 ]]; then
	read -rp "Git name: " git_name
	read -rp "Git email: " git_email
	git config --file "$HOME/.gitconfig.local" user.name "$git_name"
	git config --file "$HOME/.gitconfig.local" user.email "$git_email"
else
	echo "skip    run: git config --file ~/.gitconfig.local user.name/user.email ..."
fi

step "Docker CLI plugins (buildx, compose from Homebrew)"
DOCKER_CONFIG_FILE="$HOME/.docker/config.json"
PLUGINS_DIR="$HOMEBREW_PREFIX/lib/docker/cli-plugins"
mkdir -p "$HOME/.docker"
[[ -s "$DOCKER_CONFIG_FILE" ]] || echo '{}' >"$DOCKER_CONFIG_FILE"
if jq -e --arg d "$PLUGINS_DIR" '(.cliPluginsExtraDirs // []) | index($d)' "$DOCKER_CONFIG_FILE" >/dev/null; then
	echo "ok      $PLUGINS_DIR"
else
	# overwrite the existing file (not a new one) so it keeps its owner-only permissions
	updated="$(jq --arg d "$PLUGINS_DIR" '.cliPluginsExtraDirs = ((.cliPluginsExtraDirs // []) + [$d])' "$DOCKER_CONFIG_FILE")"
	printf '%s\n' "$updated" >"$DOCKER_CONFIG_FILE"
	echo "added   $PLUGINS_DIR"
fi

step "tmux plugins (tpm)"
TPM="$CONFIG/tmux/plugins/tpm"
clone https://github.com/tmux-plugins/tpm "$TPM"
"$TPM/bin/install_plugins"
# reload a running tmux server so it picks up the config and plugins
if tmux info >/dev/null 2>&1; then tmux source-file "$CONFIG/tmux/tmux.conf"; fi

step "Neovim: plugins (lazy-lock.json), treesitter parsers, language servers and tools — this takes a while"
# NVIM_BOOTSTRAP=1 makes the config install parsers and Mason packages synchronously.
# The second pass only retries what failed (e.g. a flaky download) and takes seconds otherwise.
for _ in 1 2; do
	NVIM_BOOTSTRAP=1 nvim --headless "+Lazy! restore" +qa
done

step "iTerm2: profile (Dynamic Profile) and app settings"
link "$DOTFILES/iterm2/profile.json" "$HOME/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json"
bash "$DOTFILES/iterm2/settings.sh"

step "Done — open iTerm2 (new shells pick up the zsh config), then run tmux and nvim"
