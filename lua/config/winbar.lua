local M = {}

local ok, icon_mod = pcall(require, "config.icon")
if not ok then
  vim.notify("M.winbar: couldn't load M.icon",vim.log.levels.INFO)
return
end

local ok, color_mod = pcall(require, "config.color")
if not ok then
  vim.notify("M.winbar: couldn't load M.color",vim.log.levels.INFO)
return
end

local function get_content(buf, name, icon, btype)
  local trim = vim.trim(name)
  if trim == "" then
    return ""
	end
	local parts = vim.split(name, "/", { plain = true })
	return tostring(buf) .. ": " .. icon .. " " .. parts[#parts]
end

local windows = {}

local function update_windows(active_win, buf)
  if vim.bo[buf].filetype == "directory" then
    return
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win == active_win then
      if not windows[win].buffers[buf] then
        local name = vim.api.nvim_buf_get_name(buf)
        local icon = icon_mod.get_icon(buf, name)
        local btype = vim.bo[buf].buftype
        local content = get_content(buf, name, icon, btype)
        if content == "" then
          goto continue
        end

        windows[win].buffers[buf] = table.concat({" ", content, " "})

        vim.wo[win].winbar = "%!v:lua.winbar_content()"
        vim.notify("M.winbar: added buffer name " .. name .. " to window " .. active_win, vim.log.levels.INFO)
      end
    end
    ::continue::
  end
end

local function remove_buffer(win, active_buf)
  local prev_buf = nil
  for buf, _content in pairs(windows[win].buffers) do
    if buf == active_buf then 
      windows[win].buffers[buf] = nil
      vim.notify("M.winbar: removed buffer " .. active_buf .. " from window " .. win, vim.log.levels.INFO)
      break
    else
      prev_buf = buf
    end
  end

  if prev_buf and vim.api.nvim_buf_is_valid(prev_buf) then
    vim.api.nvim_win_set_buf(win, prev_buf)
  else
    -- close the window if there is not previous buffer
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, false)
      vim.notify("M.winbar: closed window " .. win, vim.log.levels.INFO)
    end
  end
  
end

function _G.winbar_content()
	local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
  if not windows[win] or not windows[win].buffers then
    return ""
  end

  local result = {}
  for buf, content in pairs(windows[win].buffers) do
    if vim.api.nvim_get_current_buf() == buf and vim.api.nvim_get_current_win() == win then
      table.insert(result, table.concat({"%#ActiveBuf#", content, "%*"}))
    else
      table.insert(result, content)
    end
  end

  if #result == 0 then
    return ""
  end

  return table.concat(result, " ")
end

local augroup = vim.api.nvim_create_augroup("WinBarUserAuGroup", { clear = true })
function M.setup()
  vim.api.nvim_set_hl(0, "ActiveBuf", color_mod.colors.active)

  vim.api.nvim_create_autocmd("BufEnter", {
    group=augroup,
    callback=function(args)
      local buf = args.buf
      local win = args.win
      if vim.bo[buf].buftype == "help" then
        vim.wo[win].winbar = nil
      end

      if not windows[win] then
        windows[win] = { buffers = {} } 
        vim.notify("M.winbar BufEnter: created new window entry " .. win, vim.log.levels.INFO)
      end
      update_windows(win, buf)

      -- remove buffer with <leader>db, if it's the last buffer it will also close the winndow
      vim.keymap.set("n", "<leader>db", function()
        remove_buffer(win, buf)
      end, { buffer = buf,  silent = true})
  end
  })
  vim.api.nvim_create_autocmd("WinNew", {
    group=augroup,
    callback=function(args)
      local buf = args.buf
      local win = args.win
      if vim.bo[buf].buftype == "help" then
        vim.wo[win].winbar = nil
      end

      if not windows[win] then
        windows[win] = { buffers = {} } 
        vim.notify("M.winbar WinNew: created new window entry " .. win, vim.log.levels.INFO)
      end
      update_windows(win, buf)
    end
  })

  -- if the target buffer is valid for the current window:
  --   - switch to previous buffer with <leader>b
  --   - switch to vim.v.count buffer with #<leader>b
  vim.keymap.set("n", "<leader>b", function()
    local active_win = vim.api.nvim_get_current_win()
    local target_buf = vim.v.count > 0 and vim.v.count or vim.fn.bufnr("#")
    if vim.api.nvim_buf_is_valid(target_buf) and windows[active_win].buffers[target_buf] then
      return "<cmd>" .. target_buf .. "b<cr>"
    end
    vim.notify("M.winbar: invalid buffer " .. target_buf .. " for window " .. active_win, vim.log.levels.INFO)
    return
  end, { expr = true, silent = true})

  vim.opt.showtabline = 0
end

M.setup()
return M
