-- Image preview via chafa (Alacritty-safe: ANSI text only, no kitty/sixel)
-- Commit 1: detection only. Intercepts image buffers so raw binary is never shown.
local M = {}

-- Extensions we treat as images (must match chafa-supported raster formats)
M.extensions = {
  png = true,
  jpg = true,
  jpeg = true,
  gif = true,
  webp = true,
  bmp = true,
}

M.patterns = {
  '*.png',
  '*.jpg',
  '*.jpeg',
  '*.gif',
  '*.webp',
  '*.bmp',
}

---@param path string
---@return boolean
function M.is_image(path)
  if not path or path == '' then
    return false
  end
  local ext = path:lower():match('%.([^%.%/\\]+)$')
  return ext ~= nil and M.extensions[ext] == true
end

-- Placeholder handler: blocks the default binary read.
-- The real chafa render lands in Commit 2 (M.render).
---@param buf integer
---@param filepath string
function M.intercept(buf, filepath)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].swapfile = false
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    'Image preview: ' .. vim.fn.fnamemodify(filepath, ':t'),
    '',
    '(chafa render lands here in commit 2)',
  })
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  vim.bo[buf].filetype = 'image-preview'
end

local group = vim.api.nvim_create_augroup('image-preview', { clear = true })

vim.api.nvim_create_autocmd('BufReadCmd', {
  group = group,
  pattern = M.patterns,
  desc = 'Intercept image files instead of showing raw binary',
  callback = function(ev)
    -- ev.file may be relative; keep it for display + later absolute resolve
    M.intercept(ev.buf, ev.file ~= '' and ev.file or ev.match)
  end,
})

return M
