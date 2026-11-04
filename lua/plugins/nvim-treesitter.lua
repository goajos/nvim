vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })
-- TODO: nvim-treesitter-textobjects?
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
						vim.opt_local.fillchars = [[fold: ,foldopen:▼,foldclose:▶,foldsep: ,foldinner: ]]
						vim.opt_local.foldcolumn = "auto"
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end)
			end
		end,
	})
end

local function setup_keymaps() end

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
