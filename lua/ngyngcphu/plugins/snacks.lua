-- snacks.nvim replaces the archived dressing.nvim for nicer vim.ui.input / vim.ui.select prompts
-- (LSP rename, code actions, venv picker, ...). It is also used by pdfreader.nvim for images.
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false, -- snacks must not be lazy-loaded
	opts = {
		input = { enabled = true }, -- vim.ui.input
		picker = {
			enabled = true,
			ui_select = true, -- vim.ui.select (Telescope stays the main fuzzy finder)
		},
		-- `image` is left disabled so it does not render Markdown images on top of image.nvim;
		-- pdfreader.nvim calls the snacks.image API directly and does not need it enabled.
	},
}
