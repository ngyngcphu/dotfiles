return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		-- server configs (lsp/*.lua) must be on the runtimepath before mason-lspconfig enables servers
		"neovim/nvim-lspconfig",
	},
	config = function()
		local mason = require("mason")

		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- mason-lspconfig v2: installed servers are enabled automatically with vim.lsp.enable(),
		-- using the configs from nvim-lspconfig plus the overrides in lspconfig.lua
		mason_lspconfig.setup({
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"graphql",
				"emmet_ls",
				"prismals",
				"pyright",
				"gopls",
				"rust_analyzer",
			},
			automatic_enable = {
				-- stylua is installed for conform.nvim (formatting.lua), not as a language server;
				-- jdtls is started by nvim-jdtls (ftplugin/java/jdtls.lua)
				exclude = { "stylua", "jdtls" },
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier",
				"stylua",
				"pyright", -- Python language server
				"black", -- Python formatter
				"isort", -- Python import sorter
				"pylint", -- Python linter
				"eslint_d",
				"gopls",
				"delve",
				"gofumpt",
				"goimports",
				"golines",
				"golangci-lint",
				"gotests",
				"impl",
				"gomodifytags",
				"protols",
				"swiftlint",
			},
		})
	end,
}
