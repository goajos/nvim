local C = {}

local ok, icon_mod = pcall(require, "config.icon")
if not ok then
	vim.notify("C.tabline: couldn't load C.icon", vim.log.levels.INFO)
	return
end

local color_mod
ok, color_mod = pcall(require, "config.color")
if not ok then
	vim.notify("C.tabline: couldn't load C.color", vim.log.levels.INFO)
	return
end

local excluded_ftypes = {
	directory = true,
	cmd = true,
	dialog = true,
	msg = true,
	pager = true,
}

local function get_tabline_content()
	local cur_buf = vim.api.nvim_get_current_buf()
	local res = { "   " }

	local seen = {}
	local ord_bufs = {}
	for _i, buf in ipairs(C.mru_bufs) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
			table.insert(ord_bufs, buf)
			seen[buf] = true
		end
	end
	-- catch all listed buffers after restart, not just active ones
	for _i, buf in ipairs(vim.api.nvim_list_bufs()) do
		if not seen[buf] and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
			table.insert(ord_bufs, buf)
		end
	end

	for _i, buf in ipairs(ord_bufs) do
		local ftype = vim.bo[buf].filetype
		if not excluded_ftypes[ftype] then
			local name = vim.api.nvim_buf_get_name(buf)
			local trim = vim.trim(name)
			if trim ~= "" and vim.fn.isdirectory(name) == 0 then
				local icon = icon_mod.get_icon(buf, name)
				local parts = vim.split(name, "/", { plain = true })
				local fname = parts[#parts]
				local content = string.format(" %s: %s %s ", buf, icon, fname)

				if buf == cur_buf then
					table.insert(res, string.format("%%#ActiveBuf#%s%%*", content))
				else
					table.insert(res, content)
				end
			end
		end
	end

	if #res == 1 then
		return "   "
	end

	return table.concat(res, " ") .. "%<"
end

function _G.tabline_content()
	local res
	ok, res = pcall(get_tabline_content)
	if not ok then
		return "   "
	end
	return res
end

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		callback = function(args)
			for i, buf in ipairs(C.mru_bufs) do
				if buf == args.buf then
					table.remove(C.mru_bufs, i)
					break
				end
			end
			table.insert(C.mru_bufs, 1, args.buf)
		end,
	})
end

local function setup_keymaps()
	vim.keymap.set("n", "<leader>rb", function()
		vim.cmd("bd")
	end, { silent = true, desc = "Remove the current buffer and update the tabline" })
	vim.keymap.set("n", "<leader>rB", function()
		vim.cmd("%bd")
	end, { silent = true, desc = "Remove all buffers and update the tabline" })
	vim.keymap.set("n", "<leader>b", function()
		local cnt = vim.v.count > 0 and vim.v.count or vim.fn.bufnr("#")
		if vim.api.nvim_buf_is_valid(cnt) and vim.bo[cnt].buflisted then
			return "<cmd>" .. cnt .. "b<cr>"
		end
		vim.notify("C.statusline: invalid buffer " .. cnt .. " for switching", vim.log.levels.INFO)
	end, { expr = true, silent = true, desc = "Switch to # or previous buffer if valid" })
	vim.keymap.set("n", "<leader>B", function()
		vim.cmd("ls")
	end, { silent = true, desc = "Remove all buffers and update the tabline" })
end

function C.setup()
	C.mru_bufs = {}
	vim.opt.showtabline = 2
	vim.opt.tabline = "%!v:lua.tabline_content()"
	vim.api.nvim_set_hl(0, "ActiveBuf", color_mod.colors.active)
	local augroup = vim.api.nvim_create_augroup("TablineUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()
return C
