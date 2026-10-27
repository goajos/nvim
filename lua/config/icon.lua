local M = {}

local ok, devicons = pcall(require, "nvim-web-devicons")
if not ok then
  vim.notify("M.icon: couldn't load nvim-web-devicons",vim.log.levels.INFO)
  return
end

local icons = {
  help = devicons.get_icon_by_filetype("markdown")
}

local function get_default_icon(buf)
  local btype = vim.bo[buf].buftype
  if icons[btype] then
    return icons[btype]
  end
  return devicons.get_icon_by_filetype("vim")
end

function M.get_icon(buf, name)
  if not name or name == "" then
    return get_default_icon(buf)
  end
	-- :t Tail (last path component only)
	local fname = vim.fn.fnamemodify(name, ":t")
	-- :e Extension only
	local ext = vim.fn.fnamemodify(name, ":e")
	local icon = devicons.get_icon(fname, ext, { default = true })
	return icon
end

return M
