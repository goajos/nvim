local C = {}

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd("QuickFixCmdPost", {
		group = augroup,
		callback = function(args)
			local qf = vim.fn.getqflist({ size = 0 })
			if qf.size > 0 then
				vim.cmd("copen")
				C.is_open = true
			else
				-- schedule to not silence the notify
				vim.schedule(function()
					vim.notify("C.grep: empty quickfix list", vim.log.levels.INFO)
				end)
			end
		end,
	})
end
local function setup_keymaps()
	vim.keymap.set("n", "<leader>g", ":silent grep! ", { desc = "Open command line with silent grep" })
	vim.keymap.set("n", "<leader>dc", function()
		if C.is_open then
			vim.fn.setqflist({})
			vim.cmd("cclose")
			C.is_open = false
		else
			vim.notify("C.grep: no open quickfix list", vim.log.levels.INFO)
		end
	end, { silent = true, desc = "Clear and close the quickfix list if it's open" })
end

function C.setup()
	-- -u: disable .gitignore handling
	-- -uu: search hidden files and dirs
	-- -uuu: search binary files
	-- vim.opt.grepprg = "rg --vimgrep -uu" -- default
	vim.opt.grepprg = "rg --vimgrep -u"
	-- vim.opt.grepformat = "%f:%l:%c:%m" -- default
	local augroup = vim.api.nvim_create_augroup("GrepUserAuGroup", { clear = true })
	C.is_open = false
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
