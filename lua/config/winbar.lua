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

local function get_content(buf, name, icon, btype)
	local trim = vim.trim(name)
	if trim == "" then
		return ""
	end
	local parts = vim.split(name, "/", { plain = true })
	return buf .. ": " .. icon .. " " .. parts[#parts]
end

local function update_windows(active_win, active_buf)
	if vim.bo[active_buf].filetype == "directory" then
		return
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if win == active_win then
			if not C.windows[win].buffer_content[active_buf] then
				local name = vim.api.nvim_buf_get_name(active_buf)
				local icon = icon_mod.get_icon(active_buf, name)
				local btype = vim.bo[active_buf].buftype
				local content = get_content(active_buf, name, icon, btype)
				-- empty buffers is invalid?
				if content == "" then
					goto continue
				end

				C.windows[win].buffer_content[active_buf] = table.concat({ " ", content, " " })
				table.insert(C.windows[win].buffer_list, active_buf)

				vim.wo[win].winbar = "%!v:lua.winbar_content()"
				vim.notify("C.winbar: added buffer " .. active_buf .. " to window " .. active_win, vim.log.levels.INFO)
			end
		end
		::continue::
	end
end

local function remove_buffer(win, active_buf)
	local buffer_list = C.windows[win].buffer_list
	local cnt = #buffer_list
	local prev_idx = -1
	if cnt > 1 then
		for i, buf in ipairs(buffer_list) do
			if buf == active_buf then
				break
			else
				prev_idx = i
			end
		end

		if prev_idx > 0 then
			C.windows[win].buffer_content[active_buf] = nil
			table.remove(buffer_list, buffer_list[active_buf])
			vim.notify("C.winbar: removed buffer " .. active_buf .. " from window " .. win, vim.log.levels.INFO)
			vim.api.nvim_win_set_buf(win, buffer_list[prev_idx])
		elseif vim.fn.winnr("$") ~= 1 then
			vim.api.nvim_win_close(win, false)
			vim.notify("C.winbar: closed window " .. win, vim.log.levels.INFO)
		end
	elseif vim.fn.winnr("$") ~= 1 then
		C.windows[win].buffer_content[active_buf] = nil
		table.remove(buffer_list, buffer_list[active_buf])
		vim.notify("C.winbar: removed buffer " .. active_buf .. " from window " .. win, vim.log.levels.INFO)
		vim.api.nvim_win_close(win, false)
		vim.notify("C.winbar: closed window " .. win, vim.log.levels.INFO)
	else
		vim.notify("C.winbar: can't close last buffer " .. active_buf .. " in main window " .. win, vim.log.levels.INFO)
	end
end

function _G.winbar_content()
	local win = vim.g.statusline_winid
	if not C.windows[win] or not C.windows[win].buffer_content then
		return ""
	end
	local is_active = win == vim.api.nvim_get_current_win()

	local result = {}
	table.insert(result, table.concat({ win, ":" }))
	for _i, buf in ipairs(C.windows[win].buffer_list) do
		local content = C.windows[win].buffer_content[buf]
		if is_active and vim.api.nvim_get_current_buf() == buf then
			table.insert(result, table.concat({ "%#ActiveBuf#", content, "%*" }))
		else
			table.insert(result, content)
		end
	end

	if #result == 0 then
		return ""
	end

	return table.concat(result, " ")
end

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew" }, {
		group = augroup,
		callback = function(args)
			local win = args.win
			local buf = args.buf
			if not C.windows[win] then
				C.windows[win] = { buffer_content = {}, buffer_list = {} }
				vim.notify("C.winbar: created new window entry " .. win, vim.log.levels.INFO)
			end
			update_windows(win, buf)
		end,
	})
end

local function setup_keymaps()
	-- if the target buffer is valid for the current window:
	--   - switch to previous buffer with <leader>b
	--   - switch to vim.v.count buffer with #<leader>b
	vim.keymap.set("n", "<leader>b", function()
		local active_win = vim.api.nvim_get_current_win()
		local target_buf = vim.v.count > 0 and vim.v.count or vim.fn.bufnr("#")
		if vim.api.nvim_buf_is_valid(target_buf) and C.windows[active_win].buffer_content[target_buf] then
			return "<cmd>" .. target_buf .. "b<cr>"
		end
		vim.notify("C.winbar: invalid buffer " .. target_buf .. " for window " .. active_win, vim.log.levels.INFO)
		return
	end, { expr = true, silent = true, desc = "Switch to target buffer if buffer is valid for the current window" })

	-- remove buffer with <leader>db, if it's the last buffer it will also close the winndow
	vim.keymap.set("n", "<leader>db", function()
		local win = vim.api.nvim_get_current_win()
		local buf = vim.api.nvim_get_current_buf()
		remove_buffer(win, buf)
	end, { silent = true, desc = "Remove the current buffer, if it's the last buffer it will also close the window" })
	vim.keymap.set("n", "<leader>dB", function()
		for _i, win in ipairs(vim.api.nvim_list_wins()) do
			C.windows[win] = nil
		end
		vim.cmd("%bd")
	end, { silent = true, desc = "Remove all buffers and clear all winbars" })
end

-- TODO: bug where on reload not all buffers are loaded in
function C.setup()
	C.windows = {}
	vim.opt.showtabline = 0
	vim.api.nvim_set_hl(0, "ActiveBuf", color_mod.colors.active)
	local augroup = vim.api.nvim_create_augroup("WinBarUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()
return C
