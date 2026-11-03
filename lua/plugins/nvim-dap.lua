vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })
--TODO: implement this
local P = {}

local function setup_autocmds() end

local function setup_keymaps() end

function P.setup()
	setup_autocmds()
	setup_keymaps()
end

P.setup()
return P
