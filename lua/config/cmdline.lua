local C = {}

local ok, ui2_mod = pcall(require, "vim._core.ui2")
if not ok then
	vim.notify("C.cmdline: couldn't load vim._core.ui2", vim.log.levels.INFO)
	return
end

local function render_cmdline_win(win)
	local width = math.floor(vim.o.columns * 0.4)
	local height = math.floor(vim.o.lines * 0.2)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	vim.api.nvim_win_set_config(win, {
		relative = "editor",
		height = height,
		width = width,
		row = row,
		col = col,
		border = vim.o.winborder,
	})
end

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd("CmdlineEnter", {
		group = augroup,
		callback = function()
			local cmdline_win = ui2_mod.wins.cmd
			-- save the initial config state
			C.state.config = vim.api.nvim_win_get_config(cmdline_win)
			local cmdtype = vim.fn.getcmdtype()
			if cmdtype == ":" or cmdtype == "/" or cmdtype == "?" then
				render_cmdline_win(cmdline_win)
			end
		end,
	})
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		group = augroup,
		callback = function()
			local cmdline_win = ui2_mod.wins.cmd
			-- load the initial config state
			vim.api.nvim_win_set_config(cmdline_win, C.state.config)
		end,
	})
end

local function setup_keymaps() end

function C.setup()
	C.state = { config = nil }
	ui2_mod.enable({})
	local augroup = vim.api.nvim_create_augroup("CmdLineUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
