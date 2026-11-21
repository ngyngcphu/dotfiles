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
			automatic_enable = {
				-- stylua is installed for conform.nvim (formatting.lua), not as a language server;
				-- jdtls is started by nvim-jdtls (ftplugin/java/jdtls.lua)
				exclude = { "stylua", "jdtls" },
			},
		})

		-- Everything Mason installs, in one list (language servers may use their lspconfig names).
		-- Normally installed in the background on startup; install.sh sets NVIM_BOOTSTRAP=1 to
		-- install synchronously instead, so a headless `nvim ... +qa` doesn't quit mid-install.
		local bootstrap = vim.env.NVIM_BOOTSTRAP ~= nil
		mason_tool_installer.setup({
			run_on_start = not bootstrap,
			ensure_installed = {
				-- language servers
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
				"protols",
				"terraformls", -- Terraform: completion, hover, go to definition, validation
				"tflint", -- Terraform: lint rules (configure with .tflint.hcl)
				-- formatters
				"prettier",
				"stylua",
				"black", -- Python formatter
				"isort", -- Python import sorter
				"gofumpt",
				"goimports",
				"golines",
				"hclfmt", -- formatter for plain *.hcl files
				-- linters
				"pylint", -- Python linter
				"eslint_d",
				"golangci-lint",
				"swiftlint",
				"protolint", -- protobuf linter (linting.lua)
				-- Go tooling (go.nvim)
				"delve",
				"gotests",
				"impl",
				"gomodifytags",
			},
		})
		if bootstrap then
			mason_tool_installer.check_install(false, true) -- same as :MasonToolsInstallSync
		end
	end,
}
