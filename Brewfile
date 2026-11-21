# Everything this Mac needs, installed by install.sh (`brew bundle`).
# Homebrew only loads formulae from third-party taps that are marked `trusted: true`.
tap "hashicorp/tap"
tap "bufbuild/buf"
tap "ariga/tap"

# Shell and core tools
brew "git"
brew "gh"
brew "coreutils"
brew "rsync"
brew "jq"
brew "ripgrep"  # also telescope live_grep, spectre
brew "fd"       # also telescope, venv-selector
brew "lazygit"  # <leader>lg in Neovim
brew "cmake"
brew "ffmpeg"
brew "telnet"

# Editor and terminal multiplexer
brew "neovim"
brew "tree-sitter-cli" # compiles treesitter parsers
brew "tmux"

# Languages (Rust, bun, uv and Claude Code use their own installers, see install.sh)
brew "go"
brew "golangci-lint"
brew "node"    # also runs Mason's npm-based language servers
brew "pnpm"
brew "yarn"
brew "python"  # also Mason's pip-based tools (black, isort, pylint)
brew "openjdk" # Java (also runs jdtls)
brew "maven"
brew "jdtls"   # Java language server (nvim-jdtls)
# clangd, sourcekit-lsp and swift come with the Xcode Command Line Tools

# Containers and Kubernetes
brew "colima", restart_service: :changed # Docker VM, started at login
brew "docker"
brew "docker-buildx"
brew "docker-compose"
brew "kubernetes-cli"
brew "kubectx"
brew "helm"
brew "argocd"

# Infrastructure, APIs and databases
brew "hashicorp/tap/terraform", trusted: true
brew "bufbuild/buf/buf", trusted: true
brew "protobuf" # protoc
brew "grpcurl"
brew "k6"
brew "ariga/tap/atlas", trusted: true
brew "dbmate"
brew "libpq"        # psql
brew "mysql-client"
brew "redis"

# Go tools (go install, into ~/go/bin)
go "github.com/minio/mc"
go "google.golang.org/protobuf/cmd/protoc-gen-go"
go "google.golang.org/grpc/cmd/protoc-gen-go-grpc"
go "honnef.co/go/tools/cmd/staticcheck"

# Images and PDFs inside Neovim
brew "imagemagick" # image.nvim
brew "ghostscript" # pdfreader.nvim
brew "poppler"     # pdfreader.nvim

# Terminal (skipped if iTerm2 was installed by hand) and the font its profile uses,
# which also provides the icons in nvim-tree, lualine, bufferline, ...
cask "iterm2" unless File.exist?("/Applications/iTerm.app")
cask "font-meslo-lg-nerd-font"
