local C = {}

local ok, render_mod = pcall(require, "config.render")
if not ok then
	vim.notify("C.help: couldn't load C.render", vim.log.levels.INFO)
	return
end

local function toggle_help()
	if C.state.is_open and C.state.win then
		vim.api.nvim_win_close(C.state.win, true)
		C.state.is_open = false
		return
	end

	if C.state.buf then
		C.state.win = render_mod.render_floating_win(C.state.buf, nil, 100)
		vim.opt_local.relativenumber = false
		vim.opt_local.number = false
	else
		vim.notify("C.help: no open help buffer", vim.log.levels.INFO)
	end

	C.state.is_open = true
end

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = { "help", "checkhealth" },
		callback = function(args)
			vim.api.nvim_win_close(args.win, true)
			if C.state.buf ~= args.buf then
				C.state.buf = args.buf
				toggle_help()
			end
		end,
	})
end

local function setup_keymaps()
	-- not silent so command line is interactable
	vim.keymap.set("n", "<leader>h", function()
		vim.fn.feedkeys(":", "n")
		-- schedule to ensure the cmdline is rendered before the wildmenu is triggered
		vim.schedule(function()
			vim.fn.feedkeys("help ", "n")
		end)
	end, { desc = "Open the cmdline with help" })
	vim.keymap.set("n", "<leader>H", function()
		local cword = vim.fn.expand("<cword>")
		if cword ~= "" then
			vim.cmd.help(cword)
		end
	end, { silent = true, desc = "Open the cmdline with help and insert wordt under cursor" })
	vim.keymap.set("n", "<leader>th", toggle_help, { silent = true, desc = "Toggle help" })
end

function C.setup()
	C.state = { buf = nil, win = nil, is_open = false }
	local augroup = vim.api.nvim_create_augroup("HelpUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
