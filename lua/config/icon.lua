local C = {}

local ok, devicons = pcall(require, "nvim-web-devicons")
if not ok then
	vim.notify("C.icon: couldn't load nvim-web-devicons", vim.log.levels.INFO)
	return
end

function C.get_icon_by_filetype(type)
	return devicons.get_icon_by_filetype(type)
end

function C.get_icon(buf, name)
	if not name or name == "" then
		return devicons.get_icon_by_filetype(vim.bo[buf].filetype)
	end
	-- :t Tail (last path component only)
	local fname = vim.fn.fnamemodify(name, ":t")
	-- :e Extension only
	local ext = vim.fn.fnamemodify(name, ":e")
	local icon = devicons.get_icon(fname, ext, { default = true })
	return icon
end

return C
