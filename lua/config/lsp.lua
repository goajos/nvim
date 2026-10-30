local C = {}

local function setup_autocmds(augroup) end
local function setup_keymaps() end

function C.setup()
	local augroup = vim.api.nvim_create_augroup("LspUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
