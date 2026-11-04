vim.pack.add({
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/igorlfs/nvim-dap-view" },
	{ src = "https://github.com/jbyuki/one-small-step-for-vimkind" },
})
local P = {}

local function setup_autocmds() end

local function setup_keymaps()
	vim.keymap.set("n", "<leader>dt", "<cmd>DapViewToggle<cr>", { desc = "Toggle DapView" })
	vim.keymap.set("n", "<leader>dw", "<cmd>DapViewWatch<cr>", { desc = "Watch DapView" })
	vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<cr>", { desc = "Toggle breakpoint on current line" })
	vim.keymap.set("n", "<leader>dl", function()
		require("osv").launch({ port = 8086 })
	end, { desc = "Start osv server" })

	-- vscode keybindings
	vim.keymap.set("n", "<f5>", "<cmd>DapContinue<cr>", { desc = "Continue the debugger" })
	-- vim.keymap.set("n", "<s-f5>", "<cmd>DapTerminate<cr>", { desc = "Terminate the dap debugger" })
	vim.keymap.set("n", "<f17>", "<cmd>DapTerminate<cr>", { desc = "Terminate the debugger" })
	vim.keymap.set("n", "<f9>", "<cmd>DapToggleBreakpoint<cr>", { desc = "Toggle breakpoint on current line" })
	vim.keymap.set("n", "<f10>", "<cmd>DapStepOver<cr>", { desc = "Step over" })
	vim.keymap.set("n", "<f11>", "<cmd>DapStepInto<cr>", { desc = "Step into" })
	-- vim.keymap.set("n", "<s-f11>", "<cmd>DapStepInto<cr>", { desc = "Step out" })
	vim.keymap.set("n", "<f23>", "<cmd>DapStepOut<cr>", { desc = "Step out" })
end

-- uv tool install debugpy
local function setup_python_adapter()
	P.dap.adapters.debugpy = {
		type = "executable",
		command = "uvx",
		args = { "--from", "debugpy", "python", "-m", "debugpy.adapter" },
	}
end

local function setup_python_config()
	P.dap.configurations.python = {
		{
			type = "debugpy",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			pythonPath = function()
				return vim.fn.getcwd() .. "/.venv/bin/python"
			end,
		},
	}
end

local function setup_c_adapter()
	local command
	if vim.fn.has("mac") then
		command = "/opt/homebrew/opt/lldb/bin/lldb-dap"
	else
		command = "/usr/bin/lldb-dap"
	end

	P.dap.adapters.lldb = {
		type = "executable",
		command = command,
		name = "lldb",
	}
end

local function setup_c_config()
	P.dap.configurations.c = {
		{
			name = "launch",
			type = "lldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			args = function()
				local args = vim.fn.input("Args: ")
				return vim.split(args, " ", { trimempty = true })
			end,
		},
	}
	P.dap.configurations.cpp = P.dap.configurations.c
end

local function setup_lua_adapter()
	P.dap.adapters.nlua = function(callback, config)
		callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
	end
end

local function setup_lua_config()
	P.dap.configurations.lua = {
		{
			type = "nlua",
			request = "attach",
			name = "Attach to nvim server",
		},
	}
end

function P.setup()
	P.dap = require("dap")
	P.dap_view = require("dap-view")
	setup_autocmds()
	setup_keymaps()

	vim.api.nvim_set_hl(0, "DapBreakpointColor", { fg = "#ff0000" })
	vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpointColor", numhl = "" })
	setup_python_adapter()
	setup_python_config()
	setup_c_adapter()
	setup_c_config()
	setup_lua_adapter()
	-- setup_lua_config({ host = "127.0.0.1", port = 8086 })
	setup_lua_config()
end

P.setup()
return P
