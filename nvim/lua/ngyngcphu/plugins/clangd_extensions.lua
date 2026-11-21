-- clangd itself is configured in lsp/lspconfig.lua (inlay hints are native since Neovim 0.10);
-- this plugin only adds the :ClangdAST / :ClangdMemoryUsage / :ClangdSymbolInfo views.
return {
	"p00f/clangd_extensions.nvim",
	ft = { "c", "cpp", "objc", "objcpp" },
	opts = {
		ast = {
			role_icons = {
				type = "🄣",
				declaration = "🄓",
				expression = "🄔",
				statement = ";",
				specifier = "🄢",
				["template argument"] = "🆃",
			},
		},
		memory_usage = {
			border = "rounded",
		},
		symbol_info = {
			border = "rounded",
		},
	},
}
