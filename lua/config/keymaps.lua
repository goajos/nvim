local function km(modes, lhs, rhs, silent, desc, extra)
	vim.keymap.set(modes, lhs, rhs, vim.tbl_extend("force", { silent = silent, desc = desc }, extra or {}))
end

-- buffer: mapping is only effective in the provided buffer
-- nowait: buffer-local mapping will not wait for more characters
-- silent: mapping will not be echoed to the command line
-- expr: result of function provded will be inserted as rhs
-- cmd: ???
-- km("n", "<space>", "<nop>") -- should never keep a key pressed, so which-keys pops up!

-- ^: goto start of line
-- %: goto end of line
-- <c-w>c: close window
-- <c-w>p: previous window
-- <c-y>: accept popup menu option (find/grep/...)

km("n", "<leader>e", "<cmd>edit .<cr>", true, "Open root dir in current buffer")
km("n", "<leader>E", function()
	-- %: current buffer, :p absolute path, :h head only (drop file + ext)
	vim.cmd.edit(vim.fn.expand("%:p:h"))
end, true, "Open current head dir in current buffer")

-- local buf = require("config.buf")
km("n", "<leader>q", "<cmd>quitall<cr>", true, "Quitall neovim")
km("n", "<leader><s-r>", function()
	vim.cmd("restart")
end, true, "Restart neovim")
km("n", "<leader>w", "<cmd>write<cr>", true, "Write current buffer to file")
km("n", "<leader>/", "<cmd>nohlsearch<cr>", true, "Clear search highlight")
-- not silent so command line is interactable
km("n", "<leader>f", function()
	vim.fn.feedkeys(":", "n")
	-- schedule to ensure the cmdline is rendered before the wildmenu is triggered
	vim.schedule(function()
		vim.fn.feedkeys("find ", "n")
	end)
end, false, "Open command line with find")
km("n", "<leader>F", function()
	return ":find " .. vim.fn.expand("%:h") .. "/"
end, true, "Open command line with find at current head dir", { expr = true })

km({ "n", "x" }, "gy", '"+y', true, "Yank to system clipboard")
km({ "n", "x" }, "gp", '"+p', true, "Paste after from system clipboard")
km({ "n", "x" }, "gP", '"+P', true, "Paste before from system clipboard")

-- do things without updating the register
km("n", "x", '"_x', true, "Delete char without updating the register")
km({ "n", "v" }, "<leader>p", '"0p', true, "Paste after without updating the register")
km({ "n", "v" }, "<leader>P", '"0P', true, "Paste before without updating the register")
km({ "n", "v" }, "<leader>c", '"_c', true, "Modify after without updating the register")
km({ "n", "v" }, "<leader>C", '"_C', true, "Modify to end of line without updating the register")
km({ "n", "v" }, "<leader>x", '"_d', true, "Delete after without updating the register")
km({ "n", "v" }, "<leader>X", '"_D', true, "Delete to end of line without updating the register")
