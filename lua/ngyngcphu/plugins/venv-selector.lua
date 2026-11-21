return {
	"linux-cultist/venv-selector.nvim",
	dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
	opts = {
		-- Your options go here
		-- name = "venv",
		-- auto_refresh = false
	},
	keys = {
		-- Keymap to open VenvSelector to pick a venv.
		{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select Python venv" },
		-- the venv previously used for a project directory is now re-activated automatically
	},
}
