local C = {}

function C.render_cmdline_win(win)
	local height = math.floor(vim.o.lines * 0.2)
	local width = math.floor(vim.o.columns * 0.4)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	vim.api.nvim_win_set_config(win, {
		relative = "editor",
		height = height,
		width = width,
		row = row,
		col = col,
		border = vim.o.winborder,
	})
end

function C.render_floating_win(win, buf, max_height, max_width)
	local height = math.floor(vim.o.lines * 0.8)
	if max_height then
		height = math.min(height, max_height)
	end
	local width = math.floor(vim.o.columns * 0.8)
	if max_width then
		width = math.min(width, max_width)
	end
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	return vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		height = height,
		width = width,
		row = row,
		col = col,
		border = vim.o.winborder,
	})
end

return C
