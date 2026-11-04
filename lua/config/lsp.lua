local C = {}

local function setup_keymaps(buf)
	local opts = { buffer = buf }
	vim.keymap.set(
		"n",
		"gd",
		vim.lsp.buf.definition,
		vim.tbl_extend("force", opts, { desc = "Goto definition of cword" })
	)
end

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd("LspAttach", {
		group = augroup,
		callback = function(args)
			local buf = args.buf
			setup_keymaps(buf)

			-- inlay hints
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client and client:supports_method("textDocument/inlayHint") then
				vim.lsp.inlay_hint.enable(true, { bufnr = buf })
				vim.keymap.set("n", "<leader>ti", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
				end, { buffer = buf, silent = true, desc = "Toggle buffer inlay hints" })
			end
		end,
	})
end

function C.setup()
	local augroup = vim.api.nvim_create_augroup("LspUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	vim.opt.completeopt = { "menu", "menuone", "popup", "noselect" }
	vim.lsp.enable({ "lua_ls", "clangd", "ty" })
end

C.setup()

return C
