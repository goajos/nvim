local M = {}

local augroup = vim.api.nvim_create_augroup("DirUserAuGroup", { clear = true })

-- clear the old directory buffers when entering a non directory buffer
local prev_is_dir = false
vim.api.nvim_create_autocmd("BufLeave", {
  group = augroup,
  callback = function(args)
    if vim.bo[args.buf].filetype == "directory" then
      prev_is_dir = true
    else
      prev_is_dir = false
    end
  end
})
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = function(args)
    if vim.bo[args.buf].filetype ~= "directory" then
      if prev_is_dir then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].filetype == "directory" then
            vim.api.nvim_buf_delete(buf, {})
          end
        end
      end
    else
      -- close directory buffers with <esc>
      vim.keymap.set("n", "<esc>", function()
        vim.api.nvim_buf_delete(args.buf, { force = true })
      end, { buffer = args.buf,  silent = true})
    end
  end
})

return M
