local C = {}

local ok, ui2_mod = pcall(require, "vim._core.ui2")
if not ok then
	vim.notify("C.cmdline: couldn't load vim._core.ui2", vim.log.levels.INFO)
	return
end

local ok, render_mod = pcall(require, "config.render")
if not ok then
	vim.notify("C.cmdline: couldn't load C.render", vim.log.levels.INFO)
	return
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
				render_mod.render_cmdline_win(cmdline_win)
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
