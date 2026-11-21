# System dependencies for this Neovim config — installed by install.sh (`brew bundle`).
tap "hashicorp/tap"
tap "bufbuild/buf"

# Editor and core tools
brew "neovim"
brew "git"
brew "tree-sitter-cli" # compiles treesitter parsers
brew "ripgrep"         # telescope live_grep, spectre
brew "fd"              # telescope, venv-selector
brew "lazygit"         # <leader>lg

# Runtimes Mason uses to install language servers, formatters and linters
brew "node"   # npm packages: ts_ls, pyright, prettier, eslint_d, ...
brew "go"     # gopls, delve, gofumpt, goimports, hclfmt, ...
brew "python" # pip packages: black, isort, pylint

# Language tools not installed through Mason
brew "hashicorp/tap/terraform" # terraform fmt
brew "bufbuild/buf/buf"        # buf_ls (protobuf)
brew "jdtls"                   # Java language server (nvim-jdtls)
brew "openjdk"                 # Java runtime for jdtls
# clangd and sourcekit-lsp (C/C++/Swift) come with the Xcode Command Line Tools

# Images and PDFs inside Neovim
brew "imagemagick" # image.nvim
brew "ghostscript" # pdfreader.nvim
brew "poppler"     # pdfreader.nvim

# Font with the icons used by nvim-tree, lualine, bufferline, ...
cask "font-meslo-lg-nerd-font"
