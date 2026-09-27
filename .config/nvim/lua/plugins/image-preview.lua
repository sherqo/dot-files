-- Image preview via chafa (Alacritty-safe: ANSI text only, no kitty/sixel)
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

-- Placeholder handler: blocks the default binary read + renders via chafa.
-- Uses :terminal-style rendering (termopen) so ANSI colors show correctly.
-- A plain buffer cannot render ANSI colors; a terminal buffer can.
---@param buf integer
---@param filepath string
function M.render(buf, filepath)
  local abs = vim.fn.fnamemodify(filepath, ':p')
  if vim.fn.executable('chafa') ~= 1 then
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].swapfile = false
    vim.bo[buf].bufhidden = 'wipe'
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      'chafa not found on PATH. Install chafa to preview images.',
    })
    return
  end
  if vim.fn.filereadable(abs) ~= 1 then
    vim.notify('Image not readable: ' .. abs, vim.log.levels.ERROR)
    return
  end
  -- Remember source path for resize re-render
  vim.b[buf].image_path = abs
  -- Make sure termopen runs in this buffer
  if vim.api.nvim_get_current_buf() ~= buf then
    vim.api.nvim_set_current_buf(buf)
  end
  vim.bo[buf].swapfile = false
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = true
  vim.bo[buf].readonly = false
  -- Responsive size: match the actual window showing this buffer
  local width = vim.fn.winwidth(0)
  local height = vim.fn.winheight(0)
  -- Leave one row for the terminal prompt/status so chafa isn't clipped
  width = math.max(width - 2, 10)
  height = math.max(height - 2, 10)
  local size = width .. 'x' .. height
  -- Run chafa inside a terminal (handles ANSI colors). NOTE: the buffer must
  -- be unmodified or termopen refuses ("requires unmodified buffer") and we'd
  -- fall into the fallback below, which dumps RAW escape codes as text. The
  -- buffer is always empty here (BufReadCmd suppressed the read), so do NOT
  -- set_lines first -- even clearing an empty buffer flips 'modified'.
  vim.bo[buf].modified = false
  local ok, job = pcall(vim.fn.termopen, { 'chafa', '--size', size, abs }, {
    on_exit = function()
      -- Keep buffer read-only-ish; terminal is already finished
      if vim.api.nvim_buf_is_valid(buf) then
        vim.bo[buf].filetype = 'image-preview'
        vim.b[buf].image_path = abs
      end
    end,
  })
  if not ok or job == nil or job == 0 then
    -- Headless / no-terminal fallback: plain chafa text (no colors, but no crash)
    local out = vim.fn.system({ 'chafa', '--size', size, abs })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(out, '\n'))
  end
  vim.bo[buf].filetype = 'image-preview'
  -- Clean view: no line numbers/gutter in the preview window
  local win = vim.fn.bufwinid(buf)
  if win ~= -1 then
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = 'no'
    vim.wo[win].cursorline = false
  end
  -- q closes the preview buffer
  vim.keymap.set('n', 'q', '<cmd>bdelete<CR>', { buffer = buf, silent = true, desc = 'Close image preview' })
end

M.intercept = M.render

-- Floating variant: `chafa` inside a centered float (ANSI colors via terminal).
-- Size is derived from the actual float dimensions so the image isn't distorted.
---@param filepath string
function M.open_float(filepath)
  local abs = vim.fn.fnamemodify(filepath, ':p')
  if not M.is_image(abs) then
    vim.notify('Not an image: ' .. filepath, vim.log.levels.WARN)
    return
  end
  if vim.fn.executable('chafa') ~= 1 then
    vim.notify('chafa not found on PATH', vim.log.levels.ERROR)
    return
  end
  local cols = vim.o.columns
  local lines = vim.o.lines
  local win_w = math.floor(cols * 0.8)
  local win_h = math.floor(lines * 0.8)
  local row = math.floor((lines - win_h) / 2)
  local col = math.floor((cols - win_w) / 2)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = win_w,
    height = win_h,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. vim.fn.fnamemodify(abs, ':t') .. ' ',
    title_pos = 'center',
  })
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  local size = (win_w - 2) .. 'x' .. (win_h - 2)
  vim.fn.termopen({ 'chafa', '--size', size, abs })
  vim.bo[buf].filetype = 'image-preview'
  vim.b[buf].image_path = abs
  vim.keymap.set({ 'n', 't' }, 'q', '<cmd>bdelete<CR>', { buffer = buf, silent = true, desc = 'Close image preview' })
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { buffer = buf, silent = true })
end

vim.api.nvim_create_user_command('ChafaPreview', function(opts)
  M.open_float(opts.args ~= '' and opts.args or vim.api.nvim_buf_get_name(0))
end, { nargs = '?', complete = 'file', desc = 'Preview image with chafa in a float' })

-- Tracks telescope preview terminals: bufnr -> channel id. Telescope reuses
-- one preview buffer per picker, but a buffer can host only ONE terminal
-- ("already connected"), so repeat previews must reuse the channel.
M._terms = {}

-- Telescope mime_hook: chafa preview inside telescope's preview pane.
-- Called by telescope only for non-text files; the is_image guard keeps
-- videos/archives/etc. on the default "binary cannot be previewed" path.
-- Uses nvim_open_term + jobstart so ANSI colors render (plain buf_set_lines
-- would show escape codes as garbage). Size comes from the actual preview
-- window so the image isn't distorted.
---@param filepath string
---@param bufnr integer
---@param opts table|nil
function M.telescope_mime_hook(filepath, bufnr, opts)
  if not M.is_image(filepath) then
    return
  end
  if vim.fn.executable('chafa') ~= 1 then
    pcall(vim.api.nvim_buf_set_lines, bufnr, 0, -1, false, { 'chafa not found on PATH' })
    return
  end
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local abs = vim.fn.fnamemodify(filepath, ':p')
  local width, height = 80, 40
  local winid = opts and opts.winid
  if winid ~= nil and vim.api.nvim_win_is_valid(winid) then
    width = math.max(vim.api.nvim_win_get_width(winid) - 2, 10)
    height = math.max(vim.api.nvim_win_get_height(winid) - 2, 10)
  end
  local chan = M._terms[bufnr]
  if chan == nil then
    local ok, term = pcall(vim.api.nvim_open_term, bufnr, {})
    if not ok then
      -- Buffer already has a terminal from elsewhere: plain text fallback
      -- rather than an error (still better than nothing).
      local out = vim.fn.system({ 'chafa', '--size', width .. 'x' .. height, abs })
      pcall(vim.api.nvim_buf_set_lines, bufnr, 0, -1, false, vim.split(out, '\n'))
      return
    end
    chan = term
    M._terms[bufnr] = chan
  else
    -- Repeat preview in the same buffer: clear screen, redraw from top-left.
    pcall(vim.api.nvim_chan_send, chan, '\27[2J\27[H')
  end
  vim.fn.jobstart({ 'chafa', '--size', width .. 'x' .. height, abs }, {
    stdout_buffered = true,
    pty = true,
    on_stdout = function(_, data, _)
      for _, line in ipairs(data) do
        pcall(vim.api.nvim_chan_send, chan, line .. '\r\n')
      end
    end,
  })
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

-- Re-render at the new window size after a resize (chafa output is static).
-- A buffer can host only ONE terminal ever ("already connected"), so the old
-- preview buffer is wiped and the file re-read -- BufReadCmd renders it fresh
-- at the new size. The re-read is scheduled: autocmds don't nest, so :edit
-- issued directly here would bypass BufReadCmd and load raw binary.
-- Floats are skipped (transient UI, keeps its size).
vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
  group = group,
  desc = 'Re-render chafa image preview after resize',
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local path = vim.b[buf].image_path
    if vim.bo[buf].filetype ~= 'image-preview' or path == nil then
      return
    end
    if vim.api.nvim_win_get_config(0).relative ~= '' then
      return
    end
    if vim.fn.filereadable(path) ~= 1 then
      return
    end
    vim.schedule(function()
      -- Only recreate if the user is still looking at that same buffer.
      if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_get_current_buf() ~= buf then
        return
      end
      vim.cmd('bdelete! ' .. buf)
      vim.cmd('edit ' .. vim.fn.fnameescape(path))
    end)
  end,
})

return M
