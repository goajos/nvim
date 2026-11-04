vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" })
local P = {}

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		callback = function(args)
			local buf = args.buf
			local ok = pcall(vim.treesitter.start, buf)
			if ok then
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(buf) then
						vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
						vim.opt_local.foldmethod = "expr"
						vim.opt_local.fillchars = [[foldopen:▼,foldclose:▶]]
						vim.opt_local.foldcolumn = "auto"
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end)
			end
		end,
	})
end

local function setup_keymaps()
	-- select
	vim.keymap.set({ "x", "o" }, "am", function()
		require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
	end, { desc = "Select the outer function textobject" })
	vim.keymap.set({ "x", "o" }, "im", function()
		require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
	end, { desc = "Select the inner function textobject" })
	vim.keymap.set({ "x", "o" }, "ac", function()
		require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
	end, { desc = "Select the outer class textobject" })
	vim.keymap.set({ "x", "o" }, "ic", function()
		require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
	end, { desc = "Select the inner class textobject" })

	-- move
	vim.keymap.set({ "n", "x", "o" }, "]m", function()
		require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
	end, { desc = "Move to next function start" })
	vim.keymap.set({ "n", "x", "o" }, "]M", function()
		require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
	end, { desc = "Move to next function end" })
	vim.keymap.set({ "n", "x", "o" }, "[m", function()
		require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
	end, { desc = "Move to previous function start" })
	vim.keymap.set({ "n", "x", "o" }, "[M", function()
		require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
	end, { desc = "Move to previous function end" })

	local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
	vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
	vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
end

-- in v:
--   - an/in: select outside/inside cword
--   - ]n/[n: select next or previous node
--   - ]N/[n: select next or previous node
function P.setup()
	require("nvim-treesitter").install({
		"bash",
		"c",
		"cmake",
		"cpp",
		"css",
		"csv",
		"cuda",
		"diff",
		"dockerfile",
		"gitcommit",
		"gitignore",
		"html",
		"ini",
		"javascript",
		"json",
		"kdl",
		"lua",
		"luadoc",
		"make",
		"markdown",
		"markdown_inline",
		"python",
		"query",
		"sql",
		"toml",
		"typescript",
		"vim",
		"vimdoc",
		"xml",
		"yaml",
	})

	local augroup = vim.api.nvim_create_augroup("TreesitterUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

P.setup()
return P
