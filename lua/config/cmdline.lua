local C = {}

local ok, ui2_mod = pcall(require, "vim._core.ui2")
if not ok then
	vim.notify("C.cmdline: couldn't load vim._core.ui2", vim.log.levels.INFO)
	return
end

local render_mod
ok, render_mod = pcall(require, "config.render")
if not ok then
	vim.notify("C.cmdline: couldn't load C.render", vim.log.levels.INFO)
	return
end

-- only find uses this, not help
function _G.RgFindFiles(args, _complete)
	-- ensure rg is only called once per cmdline enter/leave combo
	if not C.state.fnames then
		C.state.fnames = vim.fn.systemlist('rg --files --hidden --glob="!.git"')
	end

	if #args == 0 then
		return C.state.fnames
	else
		return vim.fn.matchfuzzy(C.state.fnames, args)
	end
end

local function should_enable_autocomplete()
	local cmdline_cmd = vim.fn.split(vim.fn.getcmdline(), " ")[1]
	local cmdline_type = vim.fn.getcmdtype()
	local cmdline_compltype = vim.fn.getcmdcompltype()

	return cmdline_type == ":" and (cmdline_cmd == "find" or cmdline_compltype == "help")
end

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd("CmdlineEnter", {
		group = augroup,
		callback = function()
			local cmdline_win = ui2_mod.wins.cmd
			-- save the initial config state
			C.state.config = vim.api.nvim_win_get_config(cmdline_win)
			local cmdtype = vim.fn.getcmdtype()
			-- /: forward search
			-- ?: backward search
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
			C.state.fnames = nil
		end,
	})
	vim.api.nvim_create_autocmd("CmdlineChanged", {
		group = augroup,
		callback = function()
			if should_enable_autocomplete() then
				vim.fn.wildtrigger()
			end
		end,
	})
end

local function setup_keymaps() end

function C.setup()
	C.state = { config = nil, fnames = nil }
	ui2_mod.enable({})
	vim.opt.findfunc = "v:lua.RgFindFiles"
	local augroup = vim.api.nvim_create_augroup("CmdLineUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
