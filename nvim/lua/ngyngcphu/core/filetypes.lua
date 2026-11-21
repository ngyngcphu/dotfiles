vim.filetype.add({
	extension = {
		-- Neovim guesses `tf` (TinyFugue) for *.tf files it can't sniff, e.g. new empty files
		tf = "terraform",
		tfstate = "json",
	},
	filename = {
		[".terraformrc"] = "hcl",
		["terraform.rc"] = "hcl",
	},
	pattern = {
		[".*%.tfstate%.backup"] = "json",
	},
})
