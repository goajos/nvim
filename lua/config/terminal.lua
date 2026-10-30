local C = {}

local function render_terminal_win()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	C.state.win = vim.api.nvim_open_win(C.state.buf, true, {
		relative = "editor",
		height = height,
		width = width,
		row = row,
		col = col,
		border = vim.o.winborder,
	})
end

local function toggle_terminal()
	if C.state.is_open and C.state.win then
		-- TODO: force or not?
		-- vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
		vim.api.nvim_win_close(C.state.win, false)
		C.state.is_open = false
		return
	end

	if not C.state.buf then
		C.state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[C.state.buf].bufhidden = "hide"
		render_terminal_win()
		vim.fn.jobstart("bash", { term = true })
	else
		render_terminal_win()
	end

	C.state.is_open = true
	-- vim.cmd("startinsert")
end

local function setup_autocmds(augroup) end

local function setup_keymaps()
	-- TODO: move these to terminal module?
	vim.keymap.set("t", "<esc>", "<c-\\><c-n>", { silent = true, desc = "Hide terminal buffer" })
	vim.keymap.set("t", "<c-\\><c-n>", "<esc>", { silent = true, desc = "Send <esc> to terminal" })
	vim.keymap.set("n", "<leader>tt", toggle_terminal, { silent = true, desc = "Toggle terminal" })
end

function C.setup()
	C.state = { buf = nil, win, is_open = false }
	local augroup = vim.api.nvim_create_augroup("CmdLineUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
