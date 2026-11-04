local C = {}

local function setup_autocmds() end
local function setup_keymaps() end

function C.setup()
	local _augroup = vim.api.nvim_create_augroup("LspUserAuGroup", { clear = true })
	setup_autocmds()
	setup_keymaps()

	-- TODO: do we want fuzzy here?
	-- vim.opt.completeopt = { "menu", "menuone", "popup", "noselect", "fuzzy" }
	vim.opt.completeopt = { "menu", "menuone", "popup", "noselect" }

	-- TODO: enable lsp only for files in the working directory?

	vim.lsp.enable({ "lua_ls", "clangd", "ty" })
end

C.setup()

return C
