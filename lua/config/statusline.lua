local C = {}

local ok, icon_mod = pcall(require, "config.icon")
if not ok then
	vim.notify("C.statusline: couldn't load C.icon", vim.log.levels.INFO)
	return
end

local color_mod
ok, color_mod = pcall(require, "config.color")
if not ok then
	vim.notify("C.statusline: couldn't load C.color", vim.log.levels.INFO)
	return
end

local function get_git_diff(name)
	if name == "" then
		return ""
	end

	local raw = vim.fn.system(
		"git diff --numstat "
			.. vim.fn.shellescape(name)
			.. ' 2>/dev/null | awk \'{print $1"+" " " $2"-"}\' | tr -d \'\n\''
	)
	if raw == "" then
		return ""
	end

	return raw:gsub("(%d+)%+", "%1%%#String#+%%*"):gsub("(%d+)%-", "%1%%#DiagnosticError#-%%*")
end

function _G.statusline_content()
	local win = vim.g.statusline_winid
	local is_active = win == vim.api.nvim_get_current_win()

	local buf = vim.api.nvim_win_get_buf(win)
	local readonly = vim.bo[buf].readonly and "[" .. "%#DiagnosticWarn#" .. "READONLY" .. "%*" .. "]" or ""
	local modified = vim.bo[buf].modified and "[" .. "%#DiagnosticWarn#" .. "+" .. "%*" .. "]" or ""
	local name = vim.api.nvim_buf_get_name(buf)

	local statusline = "    " -- tab to start
	if is_active and readonly == "" then -- only show git branch for active window and not readonly buffers
		local icon = icon_mod.get_icon_by_filetype("git")
		if C.git_branch ~= "" then
			statusline = statusline .. "(" .. icon .. " " .. C.git_branch .. ")" .. " "
		else
			statusline = statusline .. "(" .. icon .. ")" .. " "
		end
	end

	-- file name with readonly and modified flags
	local fname = (name ~= "") and vim.fn.fnamemodify(name, ":.") or ""
	if fname ~= "" then
		statusline = statusline .. readonly .. " " .. fname .. " " .. modified .. " "
	end

	-- only show git diff for active window that is not a directory
	if is_active and vim.bo[buf].filetype ~= "directory" then
		if not C.git_diff[buf] then
			C.git_diff[buf] = get_git_diff(name)
		end

		if C.git_diff[buf] ~= "" then
			statusline = statusline .. C.git_diff[buf] .. " "
		end
	end

	statusline = statusline .. "%=" -- right indent

	if is_active then -- only show diagnostics for active window
		local diagnostic_status = vim.diagnostic.status()
		if diagnostic_status ~= "" then
			statusline = statusline .. diagnostic_status .. " "
		end
	end

	-- line and column number
	statusline = statusline .. "%l:%c" .. " "

	-- icon and filetype
	local ftype = vim.bo[buf].filetype
	if ftype ~= "" then
		statusline = statusline .. icon_mod.get_icon(buf, name) .. " " .. ftype .. " "
	end

	return statusline
end

local function get_git_branch()
	local git_branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
	if git_branch == "" then
		return ""
	end

	return git_branch
end

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
		group = augroup,
		callback = function()
			C.git_branch = get_git_branch()
		end,
	})
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = augroup,
		callback = function(args)
			local buf = args.buf
			local name = vim.api.nvim_buf_get_name(buf)
			C.git_diff[buf] = get_git_diff(name)
		end,
	})
	vim.api.nvim_create_autocmd({ "BufDelete" }, {
		group = augroup,
		callback = function(args)
			local buf = args.buf
			C.git_diff[buf] = nil
		end,
	})
end

local function setup_keymaps() end

function C.setup()
	vim.api.nvim_set_hl(0, "StatusLine", color_mod.colors.active)
	local augroup = vim.api.nvim_create_augroup("StatusLineUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
	C.git_diff = {}
	vim.o.statusline = "%!v:lua.statusline_content()"
end

C.setup()

return C
