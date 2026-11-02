local C = {}

local function setup_autocmds(augroup) end
local function setup_keymaps() end

function C.setup()
	local augroup = vim.api.nvim_create_augroup("LspUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()

	-- TODO: do we want fuzzy here?
	-- vim.opt.completeopt = { "menu", "menuone", "popup", "noselect", "fuzzy" }
	vim.opt.completeopt = { "menu", "menuone", "popup", "noselect" }

	vim.lsp.enable({ "lua_ls", "clangd", "ty" })
end

C.setup()

return C
