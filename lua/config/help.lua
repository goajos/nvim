local C = {}

local ok, render_mod = pcall(require, "config.render")
if not ok then
	vim.notify("C.help: couldn't load C.render", vim.log.levels.INFO)
	return
end

local function toggle_help(topic)
	if C.state.win and vim.api.nvim_win_is_valid(C.state.win) then
		vim.api.nvim_win_close(C.state.win, true)
		C.state.win = nil
		return
	end

	if topic and topic ~= "" then
		ok = pcall(function()
			vim.cmd("help " .. topic)
		end)
		if not ok then
			vim.notify("C.help: not a valid help topic " .. topic, vim.log.levels.INFO)
			return
		end

		C.state.buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_win_close(0, true)
		C.state.win = render_mod.float(C.state.buf, nil, nil)
	elseif C.state.buf and vim.api.nvim_buf_is_valid(C.state.buf) then
		C.state.win = render_mod.float(C.state.buf, nil, nil)
	else
		vim.notify("C.help: no open help buffer", vim.log.levels.INFO)
	end
end

local function setup_autocmds()
	vim.api.nvim_create_user_command("Help", function(opts)
		toggle_help(opts.args)
	end, {
		nargs = "?",
		complete = "help",
	})
end

local function setup_keymaps()
	-- not silent so command line is interactable
	vim.keymap.set("n", "<leader>h", function()
		vim.fn.feedkeys(":", "n")
		-- schedule to ensure the cmdline is rendered before the wildmenu is triggered
		vim.schedule(function()
			vim.fn.feedkeys("Help ", "n")
		end)
	end, { desc = "Open the cmdline with help" })
	vim.keymap.set("n", "<leader>H", function()
		local cword = vim.fn.expand("<cword>")
		if cword ~= "" then
			toggle_help(cword)
		end
	end, { silent = true, desc = "Open the cmdline with help and insert cword" })
	vim.keymap.set("n", "<leader>th", toggle_help, { silent = true, desc = "Toggle help" })
end

function C.setup()
	C.state = { buf = nil, win = nil }
	local _augroup = vim.api.nvim_create_augroup("HelpUserAuGroup", { clear = true })
	setup_autocmds()
	setup_keymaps()
end

C.setup()

return C
