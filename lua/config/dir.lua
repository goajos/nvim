local C = {}

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = augroup,
		nested = true,
		callback = function(args)
			if vim.bo[args.buf].filetype == "directory" then
				vim.keymap.set("n", "<esc>", function()
					vim.api.nvim_buf_delete(args.buf, { force = true })
				end, { buffer = args.buf, silent = true })
			end
		end,
	})
end

function C.setup()
	local augroup = vim.api.nvim_create_augroup("DirUserAuGroup", { clear = true })
	-- C.prev_is_dir = false
	setup_autocmds(augroup)
end

C.setup()
return C
