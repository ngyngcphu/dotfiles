-- Huge files (over 100 MB, e.g. a compiled terraform provider in .terraform/providers) are not read
-- into memory: Neovim loads a whole file before any plugin can react, which for a 700 MB binary means
-- ~10 s and several GB of RAM, then laggy scrolling. Instead the buffer shows the file's size and
-- type; press `o` to open it anyway (as a snacks.nvim "bigfile") or `x` for a hex dump of its start.
-- Smaller big files (over 1.5 MB) are handled by snacks.bigfile (see plugins/snacks.lua).
local limit = 100 * 1024 * 1024
local hex_bytes = 64 * 1024

local function show(buf, path, size, lines)
	local bo = vim.bo[buf]
	bo.modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	bo.buftype = "nofile" -- `:w` refuses to write, so the placeholder can never overwrite the file
	bo.modifiable = false
	bo.modified = false
end

local function info(path, size)
	local kind = vim.trim(vim.fn.system({ "file", "-b", path }))
	return {
		("Not loaded: %s"):format(vim.fn.fnamemodify(path, ":~:.")),
		("Size: %.1f MB (over the %d MB limit in core/hugefile.lua)"):format(size / 1024 / 1024, limit / 1024 / 1024),
		("Type: %s"):format(kind),
		"",
		"  o  open it anyway (slow; big-file mode, no treesitter/LSP)",
		("  x  hex dump of the first %d KB"):format(hex_bytes / 1024),
	}
end

local function guard(buf)
	local path = vim.api.nvim_buf_get_name(buf)
	if path == "" or vim.b[buf].hugefile ~= nil or vim.api.nvim_buf_is_loaded(buf) then
		return
	end
	local size = vim.fn.getfsize(path)
	if size <= limit then
		return
	end
	vim.b[buf].hugefile = true

	-- a buffer-local BufReadCmd replaces Neovim's own read for this buffer only
	local read
	read = vim.api.nvim_create_autocmd("BufReadCmd", {
		buffer = buf,
		callback = function(args)
			show(args.buf, path, size, info(path, size))
			local map = function(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { buffer = args.buf, nowait = true, desc = desc })
			end
			map("o", function()
				vim.b[args.buf].hugefile = false
				pcall(vim.api.nvim_del_autocmd, read)
				pcall(vim.keymap.del, "n", "o", { buffer = args.buf })
				pcall(vim.keymap.del, "n", "x", { buffer = args.buf })
				vim.bo[args.buf].buftype = ""
				vim.bo[args.buf].modifiable = true
				vim.cmd("edit!")
			end, "Open huge file anyway")
			map("x", function()
				local dump = vim.fn.systemlist({ "xxd", "-l", tostring(hex_bytes), path })
				local lines = info(path, size)
				lines[#lines + 1] = ""
				vim.list_extend(lines, dump)
				show(args.buf, path, size, lines)
			end, "Hex dump of huge file")
		end,
	})
end

vim.api.nvim_create_autocmd("BufAdd", {
	group = vim.api.nvim_create_augroup("UserHugefile", { clear = true }),
	callback = function(args)
		guard(args.buf)
	end,
})
-- files passed on the command line already have buffers when this runs
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
	guard(buf)
end
