local C = {}

local ok, render_mod = pcall(require, "config.render")
if not ok then
	vim.notify("C.terminal: couldn't load C.render", vim.log.levels.INFO)
	return
end

local function toggle_terminal()
	if C.state.is_open and C.state.win then
		vim.api.nvim_win_close(C.state.win, true)
		C.state.is_open = false
		return
	end

	if not C.state.buf then
		C.state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[C.state.buf].bufhidden = "hide"
		C.state.win = render_mod.render_floating_win(C.state.win, C.state.buf, nil, nil)
		vim.fn.jobstart("bash", { term = true })
	else
		C.state.win = render_mod.render_floating_win(C.state.win, C.state.buf, nil, nil)
	end

	C.state.is_open = true
	-- vim.cmd("startinsert")
end

local function setup_autocmds(augroup) end

local function setup_keymaps()
	vim.keymap.set("t", "<esc>", "<c-\\><c-n>", { silent = true, desc = "HideTerminalal buffer" })
	vim.keymap.set("t", "<c-\\><c-n>", "<esc>", { silent = true, desc = "Send <esc> to terminal" })
	vim.keymap.set("n", "<leader>tt", toggle_terminal, { silent = true, desc = "Toggle terminal" })
end

function C.setup()
	C.state = { buf = nil, win = nil, is_open = false }
	local augroup = vim.api.nvim_create_augroup("TerminalUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
