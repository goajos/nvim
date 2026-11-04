local C = {}

local cursor_hl = vim.api.nvim_get_hl(0, { name = "Cursor" })
C.colors = {
	active = { bold = true, bg = "#285577", fg = "#ffffff" },
	numberlinenr = { fg = "NvimLightGrey4" },
	cursorlinenr = { bold = true, fg = "#ffffff" },
	matchparen = { bold = cursor_hl.bold, bg = cursor_hl.bg },

	-- inactive = { bg = "NvimDarkGrey3", fg = "NvimLightGrey3" },
	-- sep = { bg = "NvimDarkGrey3" },
}

function C.setup()
	vim.api.nvim_set_hl(0, "LineNr", C.colors.numberlinenr)
	vim.api.nvim_set_hl(0, "CursorLineNr", C.colors.cursorlinenr)
	vim.api.nvim_set_hl(0, "MatchParen", C.colors.matchparen)
end

C.setup()
return C
