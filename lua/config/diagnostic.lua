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
		callback = function(args)
			local buf = args.buf
			if args.event == "InsertEnter" then
				if vim.diagnostic.is_enabled({ bufnr = buf }) then
					vim.b[buf].diagnostic_toggle = true
					vim.diagnostic.enable(false, { bufnr = args.buf })
				end
			-- do not turn on diagnostics on insertleave if it's already toggled off
			elseif vim.b[buf].diagnostic_toggle then
				vim.b[buf].diagnostic_toggle = nil
				vim.diagnostic.enable(true, { bufnr = args.buf })
			end
		end,
	})
end

local function setup_keymaps()
	vim.keymap.set("n", "<leader>td", function()
		local buf = vim.api.nvim_get_current_buf()
		local toggle = not vim.diagnostic.is_enabled({ bufnr = buf })
		vim.diagnostic.enable(toggle, { bufnr = buf })
		if toggle then
			vim.notify("C.diagnostic: enabled diagnostics for current buffer " .. buf, vim.log.levels.INFO)
		else
			vim.notify("C.diagnostic: disabled diagnostics for current buffer " .. buf, vim.log.levels.INFO)
		end
	end, { silent = true, desc = "Toggle buffer diagnostics" })
	vim.keymap.set("n", "<leader>dq", function()
		-- 0 for current buffer
		local diagnostics = vim.diagnostic.get(0)
		if #diagnostics ~= 0 then
			vim.fn.setqflist(vim.diagnostic.toqflist(diagnostics))
			vim.cmd("copen")
		else
			vim.notify("C.diagnostic: no diagnostics for current buffer", vim.log.levels.INFO)
		end
	end, { silent = true, desc = "Current buffer diagnostics to quickfix list" })
end

local hl_map = {
	[vim.diagnostic.severity.ERROR] = "DiagnosticError",
	[vim.diagnostic.severity.WARN] = "DiagnosticWarn",
	[vim.diagnostic.severity.INFO] = "DiagnosticInfo",
	[vim.diagnostic.severity.HINT] = "DiagnosticHint",
}

function C.setup()
	vim.diagnostic.config({
		severity_sort = true,
		status = {
			function(scnt)
				local items = {}
				for severity in ipairs(vim.diagnostic.severity) do
					local dcnt = scnt[severity] or 0
					table.insert(items, ("%%#%s# %s"):format(hl_map[severity], dcnt))
				end
				return table.concat(items, " ")
			end,
		},
		jump = { on_jump = on_jump },
	})
	local augroup = vim.api.nvim_create_augroup("DiagnosticsUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()

return C
