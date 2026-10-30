local km = vim.keymap.set

-- buffer: mapping is only effective in the provided buffer
-- nowait: buffer-local mapping will not wait for more characters
-- silent: mapping will not be echoed to the command line
-- expr: result of function provded will be inserted as rhs
-- cmd: ???
local opts = { silent = true }
-- km("n", "<space>", "<nop>") -- should never keep a key pressed, so which-keys pops up!

-- ^: goto start of line
-- %: goto end of line
-- <c-w>c: close window
-- <c-w>p: previous window
-- <c-y>: accept popup menu option (find/grep/...)

km("n", "<leader>e", "<cmd>edit .<cr>", vim.tbl_extend("force", opts, { desc = "Open root dir in current buffer" }))
km("n", "<leader>E", function()
	-- %: current buffer, :p absolute path, :h head only (drop file + ext)
	vim.cmd.edit(vim.fn.expand("%:p:h"))
end, vim.tbl_extend("force", opts, { desc = "Open current head dir in current buffer" }))

-- local buf = require("config.buf")
km("n", "<leader>r", "<cmd>restart<cr>", vim.tbl_extend("force", opts, { desc = "Restart neovim" }))
km("n", "<leader>w", "<cmd>write<cr>", vim.tbl_extend("force", opts, { desc = "Write current buffer to file" }))
km("n", "<leader>/", "<cmd>nohlsearch<cr>", vim.tbl_extend("force", opts, { desc = "Clear search highlight" }))
-- not silent so command line is interactable
km("n", "<leader>f", ":find ", { desc = "Open command line with find" })
km("n", "<leader>F", function()
	return ":find " .. vim.fn.expand("%:h") .. "/"
end, { expr = true, desc = "Open command line with find at current head dir" })

km({ "n", "x" }, "gy", '"+y', vim.tbl_extend("force", opts, { desc = "Yank to system clipboard" }))
km({ "n", "x" }, "gp", '"+p', vim.tbl_extend("force", opts, { desc = "Paste after from system clipboard" }))
km({ "n", "x" }, "gP", '"+P', vim.tbl_extend("force", opts, { desc = "Paste before from system clipboard" }))
km({ "x" }, "p", '"_dP', vim.tbl_extend("force", opts, { desc = "Paste without yanking selection" }))
