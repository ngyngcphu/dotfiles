-- nvim-treesitter `main` branch (the `master` branch is frozen and does not support Neovim 0.12).
-- It only installs parsers/queries; highlighting and indentation are enabled per filetype below.
-- Parsers are compiled with the `tree-sitter` CLI (brew install tree-sitter-cli).
local parsers = {
	"json",
	"javascript",
	"typescript",
	"tsx",
	"yaml",
	"html",
	"css",
	"prisma",
	"markdown",
	"markdown_inline",
	"svelte",
	"graphql",
	"bash",
	"lua",
	"vim",
	"dockerfile",
	"gitignore",
	"query",
	"vimdoc",
	"c",
	"cpp",
	"rust",
	"go",
	"swift",
	"dart",
	"java",
	"python",
	"proto",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- the main branch does not support lazy-loading
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup()
			ts.install(parsers)

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match)
					if not lang or not vim.treesitter.language.add(lang) then
						return -- no parser installed for this filetype
					end
					vim.treesitter.start(args.buf, lang)
					if vim.treesitter.query.get(lang, "indents") then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- incremental selection: built into Neovim 0.12 as `an` (parent node) / `in` (child node)
			vim.keymap.set("n", "<C-space>", "van", { remap = true, desc = "Start treesitter selection" })
			vim.keymap.set("x", "<C-space>", "an", { remap = true, desc = "Expand selection to parent node" })
			vim.keymap.set("x", "<bs>", "in", { remap = true, desc = "Shrink selection to child node" })
		end,
	},
	{
		-- auto close/rename html, jsx, svelte, vue tags (no longer configured through nvim-treesitter)
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},
}
