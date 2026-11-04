vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
local P = {}

local function setup_autocmds()
	vim.api.nvim_create_user_command("FormatDisable", function()
		local buf = vim.api.nvim_get_current_buf()
		vim.b[buf].disable_autoformat = true
		vim.notify("P.conform: auto format disabled for buffer " .. buf, vim.log.levels.INFO)
	end)

	vim.api.nvim_create_user_command("FormatEnable", function()
		local buf = vim.api.nvim_get_current_buf()
		vim.b[buf].disable_autoformat = false
		vim.notify("P.conform: auto format enable for buffer " .. buf, vim.log.levels.INFO)
	end)
end

local function setup_keymaps()
	vim.keymap.set("n", "<leader>tf", function()
		local buf = vim.api.nvim_get_current_buf()
		if vim.b[buf].disable_autoformat then
			vim.cmd("FormatEnable")
		else
			vim.cmd("FormatDisable")
		end
	end, { silent = true, desc = "Toggle buffer auto formatting" })
end

function P.setup()
	require("conform").setup({
		formatters_by_ft = {
			bash = { "shfmt" },
			c = { "clang-format" },
			lua = { "stylua" },
			python = { "ruff" },
			sh = { "shfmt" },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
		format_on_save = function(buf)
			if vim.b[buf].disable_autoformat then
				return
			end
			return { timeout_ms = 500, lsp_format = "fallback" }
		end,
	})
	local _augroup = vim.api.nvim_create_augroup("ConformUserAuGroup", { clear = true })
	setup_autocmds()
	setup_keymaps()
end

P.setup()
return P
