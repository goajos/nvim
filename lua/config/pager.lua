local C = {}

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = "pager",
		callback = function(args)
			local buf = args.buf
			vim.opt_local.relativenumber = true
			vim.opt_local.number = true
			-- close the pager with <esc>
			vim.keymap.set("n", "<esc>", ":bd<cr>", { buffer = buf, silent = true })
		end,
	})
end

local function setup_keymaps()
	vim.keymap.set("n", "<leader>tm", "g<", { silent = true, desc = "Toggle all messages" })
end

function C.setup()
	C.state = { config = nil }
	local augroup = vim.api.nvim_create_augroup("PagerUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()

	-- vim.opt :append helper
	-- vim.opt.messagesopt = "hit-enter,history:500,progress:c" -- default mopt
	vim.opt.messagesopt = "hit-enter,history:10000,progress:c"
	vim.opt.messagesopt:append("pager:m") -- p opens the pager for [+x] messages
	vim.opt.messagesopt:append("maxheight:50") -- [+x] messages after 50 lines (default 50)
end

C.setup()

return C
