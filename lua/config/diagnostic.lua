local C = {}

-- ]d: next diagnostic
-- [d: previous diagnostic
-- ]D: last diagnostic
-- [D: first diagnostic
-- <c-w>d: open diagnostic

local function on_jump()
	vim.schedule(function()
		vim.diagnostic.open_float({ scope = "cursor", close_events = { "CursorMoved", "InsertEnter" } })
	end)
end

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
		group = augroup,
		callback = function()
			C.is_enabled = not C.is_enabled
			vim.diagnostic.enable(C.is_enabled)
		end,
	})
end

local function setup_keymaps()
	vim.keymap.set("n", "<leader>qd", function()
		-- 0 for current buffer
		local diagnostics = vim.diagnostic.get(0)
		if #diagnostics ~= 0 then
			vim.fn.setqflist(vim.diagnostic.toqflist(diagnostics))
			vim.cmd("copen")
		else
			vim.notify("C.diagnostic: no diagnostics for current buffer", vim.log.levels.INFO)
		end
	end, { silent = true, desc = "Current buffer diagnostics to quickfix list" })
	vim.keymap.set("n", "<leader>qD", function()
		-- nil for all buffers
		local diagnostics = vim.diagnostic.get(nil)
		if #diagnostics ~= 0 then
			vim.fn.setqflist(vim.diagnostic.toqflist(diagnostics))
			vim.cmd("copen")
		else
			vim.notify("C.diagnostic: no diagnostics for all buffers", vim.log.levels.INFO)
		end
	end, { silent = true, desc = "All buffer diagnostics to quickfix list" })
end

local hl_map = {
	[vim.diagnostic.severity.ERROR] = "DiagnosticError",
	[vim.diagnostic.severity.WARN] = "DiagnosticWarn",
	[vim.diagnostic.severity.INFO] = "DiagnosticInfo",
	[vim.diagnostic.severity.HINT] = "DiagnosticHint",
}

function C.setup()
	vim.diagnostic.config({
		status = {
			function(scnt)
				local items = {}
				for severity in ipairs(vim.diagnostic.severity) do
					local dcnt = scnt[severity] or 0
					table.insert(items, ("%%#%s#%s %s"):format(hl_map[severity], nil, dcnt))
				end
				return table.concat(items, " ")
			end,
		},
		jump = { on_jump = on_jump },
	})
	C.is_enabled = true
	local augroup = vim.api.nvim_create_augroup("DiagnosticsUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
