local C = {}

local ok, icon_mod = pcall(require, "config.icon")
if not ok then
	vim.notify("C.tabline: couldn't load C.icon", vim.log.levels.INFO)
	return
end

local ok, color_mod = pcall(require, "config.color")
if not ok then
	vim.notify("C.tabline: couldn't load C.color", vim.log.levels.INFO)
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

local function update_tabline(buf, event)
	if event == "BufAdd" and not C.tabline.buffer_content[buf] then
		local name = vim.api.nvim_buf_get_name(buf)
		local icon = icon_mod.get_icon(buf, name)
		local btype = vim.bo[buf].buftype
		local content = get_content(buf, name, icon, btype)
		-- empty buffer is invalid?
		if content == "" then
			return
		end

		C.tabline.buffer_content[buf] = table.concat({ " ", content, " " })
		table.insert(C.tabline.buffer_list, buf)
		vim.notify("C.tabline: added buffer " .. buf .. " to tabline", vim.log.levels.INFO)
	end

	if event == "BufDelete" and C.tabline.buffer_content[buf] then
		local idx = -1
		for i, _buf in ipairs(C.tabline.buffer_list) do
			if _buf == buf then
				idx = i
				break
			end
		end
		if idx ~= -1 then
			C.tabline.buffer_content[buf] = nil
			table.remove(C.tabline.buffer_list, idx)
			if vim.bo[buf].filetype ~= "directory" then
				vim.notify("C.tabline: removed buffer " .. buf .. " from tabline", vim.log.levels.INFO)
			end
		end
	end
end

function _G.tabline_content()
	if not C.tabline or not C.tabline.buffer_content then
		return "    "
	end

	local result = { "    " }
	for _i, buf in ipairs(C.tabline.buffer_list) do
		local content = C.tabline.buffer_content[buf]
		if vim.api.nvim_get_current_buf() == buf then
			table.insert(result, table.concat({ "%#ActiveBuf#", content, "%*" }))
		else
			table.insert(result, content)
		end
	end

	if #result == 0 then
		return "    "
	end

	return table.concat(result, " ")
end

local function setup_autocmds(augroup)
	vim.api.nvim_create_autocmd({ "BufAdd" }, {
		group = augroup,
		callback = function(args)
			local buf = args.buf
			if not C.tabline.buffer_content[buf] then
				update_tabline(buf, args.event)
			end
		end,
	})
	vim.api.nvim_create_autocmd({ "BufDelete" }, {
		group = augroup,
		nested = true,
		callback = function(args)
			local buf = args.buf
			if C.tabline.buffer_content[buf] then
				update_tabline(buf, args.event)
			end
		end,
	})
end

local function setup_keymaps()
	vim.keymap.set("n", "<leader>db", function()
		vim.cmd("bd")
	end, { silent = true, desc = "Remove the current buffer and update the tabline" })
	vim.keymap.set("n", "<leader>dB", function()
		vim.cmd("%bd")
	end, { silent = true, desc = "Remove all buffers and update the tabline" })
	vim.keymap.set("n", "<leader>b", function()
		local cnt = vim.v.count > 0 and vim.v.count or vim.fn.bufnr("#")
		if vim.api.nvim_buf_is_valid(cnt) then
			return "<cmd>" .. cnt .. "b<cr>"
		end
		vim.notify("C.statusline: invalid buffer " .. target_buf .. " for switching", vim.log.levels.INFO)
	end, { expr = true, silent = true, desc = "Switch to # or previous buffer if valid" })
end

function C.setup()
	C.tabline = { buffer_content = {}, buffer_list = {} }
	vim.opt.showtabline = 2
	vim.opt.tabline = "%!v:lua.tabline_content()"
	vim.api.nvim_set_hl(0, "ActiveBuf", color_mod.colors.active)
	local augroup = vim.api.nvim_create_augroup("TablineUserAuGroup", { clear = true })
	setup_autocmds(augroup)
	setup_keymaps()
end

C.setup()
return C
