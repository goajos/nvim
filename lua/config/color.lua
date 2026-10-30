local C = {}

C.colors = {
	active = { bold = true, bg = "#285577", fg = "#ffffff" },
	error = { fg = "#ff0000" },
	success = { fg = "#00ff00" },
	warning = { fg = "#ffff00" },
	numberlinenr = { fg = "NvimLightGrey4" },
	cursorlinenr = { bold = true, fg = "#ffffff" },

	-- inactive = { bg = "NvimDarkGrey3", fg = "NvimLightGrey3" },
	-- sep = { bg = "NvimDarkGrey3" },
}

function C.setup()
	vim.api.nvim_set_hl(0, "LineNr", C.colors.numberlinenr)
	vim.api.nvim_set_hl(0, "CursorLineNr", C.colors.cursorlinenr)
end

C.setup()
return C
