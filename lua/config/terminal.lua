local C = {}

local ok, render_mod = pcall(require, "config.render")
if not ok then
	vim.notify("C.terminal: couldn't load C.render", vim.log.levels.INFO)
	return
end

local function toggle_terminal()
	if C.state.win and vim.api.nvim_win_is_valid(C.state.win) then
		vim.api.nvim_win_close(C.state.win, true)
		C.state.win = nil
		return
	end
	-- if vim.fn.has("mac") then
	-- 	command = "/opt/homebrew/opt/lldb/bin/lldb-dap"
	-- else
	-- 	command = "/usr/bin/lldb-dap"
	-- end

	if not C.state.buf or not vim.api.nvim_buf_is_valid(C.state.buf) then
		C.state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[C.state.buf].bufhidden = "hide"
		vim.bo[C.state.buf].filetype = "terminal"
		C.state.win = render_mod.float(C.state.buf, nil, nil)
		if vim.uv.os_uname().sysname == "Mac" then
			vim.fn.jobstart("/opt/homebrew/bin/bash", { term = true })
		elseif vim.uv.os_uname().sysname == "Linux" then
			vim.fn.jobstart("bash", { term = true })
		end
	else
		C.state.win = render_mod.float(C.state.buf, nil, nil)
	end

	-- vim.cmd("startinsert")
end

local function setup_autocmds() end

local function setup_keymaps()
	vim.keymap.set("t", "<esc>", "<c-\\><c-n>", { silent = true, desc = "HideTerminalal buffer" })
	vim.keymap.set("t", "<c-\\><c-n>", "<esc>", { silent = true, desc = "Send <esc> to terminal" })
	vim.keymap.set("n", "<leader>tt", toggle_terminal, { silent = true, desc = "Toggle terminal" })
end

function C.setup()
	C.state = { buf = nil, win = nil }
	local _augroup = vim.api.nvim_create_augroup("TerminalUserAuGroup", { clear = true })
	setup_autocmds()
	setup_keymaps()
end

C.setup()

return C
