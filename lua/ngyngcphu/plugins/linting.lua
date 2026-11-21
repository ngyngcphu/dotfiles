return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		if vim.env.VIRTUAL_ENV then
			local pylint = lint.linters.pylint
			pylint.cmd = vim.env.VIRTUAL_ENV .. "/bin/pylint"
		end

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
			proto = { "protolint" },
		}

		-- eslint_d uses the project's own eslint when installed, otherwise its bundled one (eslint 10,
		-- flat config only). `--no-warn-ignored` silences "file ignored" warnings, but only exists
		-- with flat config: legacy .eslintrc projects reject it, so add it only for flat-config projects.
		local eslint_d = lint.linters.eslint_d
		local flat_configs = {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			"eslint.config.ts",
			"eslint.config.mts",
			"eslint.config.cts",
		}
		lint.linters.eslint_d = function()
			local args = { "--format", "json", "--stdin", "--stdin-filename", vim.api.nvim_buf_get_name(0) }
			if vim.fs.root(0, flat_configs) then
				table.insert(args, 1, "--no-warn-ignored")
			end
			return vim.tbl_extend("force", eslint_d, { args = args })
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
