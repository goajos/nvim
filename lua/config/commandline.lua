local C = {}

local ok, icon_mod = pcall(require, "vim._core.ui2")
if not ok then
	vim.notify("C.commandline: couldn't load vim._core.ui2", vim.log.levels.INFO)
	return
end

local function setup_autocmds(augroup) end
local function setup_keymaps() end

function C.setup()
	local augroup = vim.api.nvim_create_augroup("CommandLineUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
