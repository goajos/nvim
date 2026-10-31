local C = {}

local ok, grep_mod = pcall(require, "config.grep")
if not ok then
	vim.notify("C.lsp: couldn't load C.grep", vim.log.levels.INFO)
	return
end

local function setup_autocmds(augroup) end
local function setup_keymaps() end

function C.setup()
	local augroup = vim.api.nvim_create_augroup("LspUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
	vim.lsp.enable("lua_ls")
	vim.lsp.enable("clangd")
	vim.lsp.enable("ty")
end

C.setup()

return C
