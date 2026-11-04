local C = {}

function C.float(buf, h_scale, w_scale)
	return vim.api.nvim_open_win(buf, true, C.config(h_scale or 0.8, w_scale or 0.8))
end

function C.cmdline(win, h_scale, w_scale)
	vim.api.nvim_win_set_config(win, C.config(h_scale or 0.2, w_scale or 0.4))
end

function C.config(h_scale, w_scale)
	local h, w = vim.o.lines * h_scale, vim.o.columns * w_scale
	h, w = math.floor(h), math.floor(w)
	return {
		relative = "editor",
		height = h,
		width = w,
		row = math.floor((vim.o.lines - h) / 2),
		col = math.floor((vim.o.columns - w) / 2),
		border = vim.o.winborder,
	}
end

return C
