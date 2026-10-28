local C = {}

local ok, icon_mod = pcall(require, "config.icon")
if not ok then
	vim.notify("C.winbar: couldn't load C.icon", vim.log.levels.INFO)
	return
end

local ok, color_mod = pcall(require, "config.color")
if not ok then
	vim.notify("C.winbar: couldn't load C.color", vim.log.levels.INFO)
	return
end

local function get_diagnostics(buf)
	if not vim.diagnostic then
		return ""
	end
	local diagnostics = vim.diagnostic.get(buf)
	local error, warning, info, hint = 0, 0, 0, 0
	for _, val in ipairs(diagnostics) do
		if val.severity == vim.diagnostic.severity.ERROR then
			error = error + 1
		elseif val.severity == vim.diagnostic.severity.WARN then
			warning = warning + 1
		elseif val.severity == vim.diagnostic.severity.INFO then
			info = info + 1
		elseif val.severity == vim.diagnostic.severity.HINT then
			hint = hint + 1
		end
	end
	local diagnostics_string = ""
	if error > 0 then
		diagnostics_string = diagnostics_string .. "ERROR:" .. "%#Error#" .. error .. "%*" .. " "
	end
	if warning > 0 then
		diagnostics_string = diagnostics_string .. "WARN:" .. "%#Warning#" .. warning .. "%*" .. " "
	end
	if info > 0 then
		diagnostics_string = diagnostics_string .. "INFO:" .. info .. " "
	end
	if hint > 0 then
		diagnostics_string = diagnostics_string .. "HINT:" .. hint .. " "
	end
	return diagnostics_string
end

local branch_timeout = 10000 -- check every x seconds
local cached_branch = ""
local last_branch_get = 0
local function get_git_branch()
	local now = vim.loop.now()
	if now - last_branch_get > branch_timeout then
		cached_branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
		last_branch_get = now
	end
	if cached_branch ~= "" then
		return cached_branch
	end
	return ""
end

local diff_cache = {}
local function get_git_diff(name)
	if name == "" then
		return ""
	end
	if diff_cache[name] == nil then
		local raw = vim.fn.system(
			"git diff --numstat "
				.. vim.fn.shellescape(name)
				.. ' 2>/dev/null | awk \'{print $1"+" " " $2"-"}\' | tr -d \'\n\''
		)
		if raw ~= "" then
			diff_cache[name] = raw:gsub("(%d+)%+", "%1%%#Success#+%%*"):gsub("(%d+)%-", "%1%%#Error#-%%*")
		else
			diff_cache[name] = ""
		end
	end
	return diff_cache[name]
end

function _G.statusline_content()
	local win = vim.g.statusline_winid
	local is_active = win == vim.api.nvim_get_current_win()

	local statusline = "    " -- tab to start
	if is_active then -- only show git branch for active window
		local branch = get_git_branch()
		if branch ~= "" then
			statusline = statusline .. "(" .. branch .. ")" .. " "
		else
			statusline = statusline .. "(nil)" .. " "
		end
	end

	-- file name
	local buf = vim.api.nvim_win_get_buf(win)
	local name = vim.api.nvim_buf_get_name(buf)
	local fname = (name ~= "") and vim.fn.fnamemodify(name, ":.") or ""
	if fname ~= "" then
		statusline = statusline .. fname .. " "
	end

	if is_active then -- only show git diff for active window
		local diff = get_git_diff(name)
		if diff ~= "" then
			statusline = statusline .. diff .. " "
		end
	end

	statusline = statusline .. "%=" -- right indent

	if is_active then -- only show diagnostics for active window
		local diagnostics = get_diagnostics(buf)
		if diagnostics ~= "" then
			statusline = statusline .. diagnostics .. " "
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

local function setup_autocmds(augroup) end

local function setup_keymaps() end

function C.setup()
	vim.api.nvim_set_hl(0, "StatusLine", color_mod.colors.active)
	vim.api.nvim_set_hl(0, "Error", color_mod.colors.error)
	vim.api.nvim_set_hl(0, "Success", color_mod.colors.success)
	vim.api.nvim_set_hl(0, "Warning", color_mod.colors.success)
	local augroup = vim.api.nvim_create_augroup("StatusLineUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
	vim.o.statusline = "%!v:lua.statusline_content()"
end

C.setup()
return C
