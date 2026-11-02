local C = {}

local function is_qf_open()
	for _i, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			return true
		end
	end
	return false
end

local function toggle_quickfix()
	if is_qf_open() then
		vim.cmd("cclose")
	else
		vim.cmd("copen")
	end
end

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd("QuickFixCmdPost", {
		group = augroup,
		callback = function()
			local qf = vim.fn.getqflist({ size = 0 })
			if qf.size > 0 then
				vim.cmd("copen")
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
	-- not silent so command line is interactable
	vim.keymap.set("n", "<leader>g", ":silent grep! ", { desc = "Open command line with silent grep" })
	vim.keymap.set("n", "<leader>tq", toggle_quickfix, { silent = true, desc = "Toggle the quickfix list" })
	vim.keymap.set("n", "<leader>dq", function()
		if is_qf_open() then
			vim.fn.setqflist({})
			vim.cmd("cclose")
		else
			vim.notify("C.grep: no open quickfix list", vim.log.levels.INFO)
		end
	end, { silent = true, desc = "Clear and close the quickfix list" })
end

function C.setup()
	-- -u: disable .gitignore handling
	-- -uu: search hidden files and dirs
	-- -uuu: search binary files
	-- vim.opt.grepprg = "rg --vimgrep -uu" -- default
	vim.opt.grepprg = "rg --vimgrep -u"
	-- vim.opt.grepformat = "%f:%l:%c:%m" -- default
	local augroup = vim.api.nvim_create_augroup("QuickFixUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
