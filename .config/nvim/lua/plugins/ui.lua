-- UI / Core UX Plugins
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini, lualine
-- Extracted from init.lua Section 4

local gh = require('config.util').gh

-- [[ Installing and Configuring Plugins ]]
-- To install a plugin simply call `vim.pack.add` with its git url.

vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}

-- gitsigns: git signs + utilities
vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
local gitsigns = require 'gitsigns'
gitsigns.setup {
  signs = {
    add = { text = '+' }, ---@diagnostic disable-line: missing-fields
    change = { text = '~' }, ---@diagnostic disable-line: missing-fields
    delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
    topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
    changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
  },
  -- gitsigns.nvim's recommended keymaps:
  on_attach = function(bufnr)
    -- Navigation
    vim.keymap.set('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange', buf = bufnr })

    vim.keymap.set('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange', buf = bufnr })

    -- Visual mode actions
    vim.keymap.set('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk', buf = bufnr })
    vim.keymap.set('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk', buf = bufnr })
    -- Normal mode actions
    vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk', buf = bufnr })
    vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk', buf = bufnr })
    vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer', buf = bufnr })
    vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer', buf = bufnr })
    vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk', buf = bufnr })
    vim.keymap.set('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline', buf = bufnr })
    vim.keymap.set('n', '<leader>hb', function()
      gitsigns.blame_line { full = true }
    end, { desc = 'git [b]lame line', buf = bufnr })
    vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index', buf = bufnr })
    vim.keymap.set('n', '<leader>hD', function()
      gitsigns.diffthis '~'
    end, { desc = 'git [D]iff against last commit', buf = bufnr })
    vim.keymap.set('n', '<leader>hQ', function()
      gitsigns.setqflist 'all'
    end, { desc = 'git hunk [Q]uickfix list (all files in repo)', buf = bufnr })
    vim.keymap.set('n', '<leader>hq', gitsigns.setqflist, { desc = 'git hunk [q]uickfix list (all changes in this file)', buf = bufnr })
    -- Toggles
    vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line', buf = bufnr })
    vim.keymap.set('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '[T]oggle git intra-line [w]ord diff', buf = bufnr })
    -- Text object
    vim.keymap.set({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'text object [i]nside [h]unk', buf = bufnr })
  end,
}

-- which-key: show pending keybinds
vim.pack.add { gh 'folke/which-key.nvim' }
require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}

-- Colorscheme

-- NOTE:------------ tokyonight start ----------------- 

-- vim.pack.add { gh 'folke/tokyonight.nvim' }
---@diagnostic disable-next-line: missing-fields
-- require('tokyonight').setup {}
-- vim.cmd.colorscheme 'tokyonight-night'
----------------- tokyonight end ----------------- 

-- NOTE:----------- terminal theme start ---------------
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.cmd.colorscheme 'default'

local colors = {
  bg        = '#202330',
  fg        = '#FFF0F5',
  black     = '#202330',
  red       = '#FF4C7A',
  green     = '#3BC089',
  yellow    = '#D0963A',
  blue      = '#6767CE',
  magenta   = '#C77DFF',
  cyan      = '#4CC9C0',
  white     = '#FFF0F5',
  gray      = '#565970',
  brred     = '#FF7F9D',
  brgreen   = '#9CD162',
  bryellow  = '#FEC831',
  brblue    = '#A2C2EB',
  brmagenta = '#E6A1FF',
  brcyan    = '#75E0D6',
}

local hl = vim.api.nvim_set_hl

-- Core syntax
hl(0, 'Comment',      { fg = colors.gray, italic = true })
hl(0, 'String',       { fg = colors.green })
hl(0, 'Character',    { fg = colors.green })
hl(0, 'Number',       { fg = colors.brmagenta })
hl(0, 'Boolean',      { fg = colors.brmagenta })
hl(0, 'Function',     { fg = colors.brcyan })
hl(0, 'Keyword',      { fg = colors.blue })
hl(0, 'Statement',    { fg = colors.blue })
hl(0, 'Conditional',  { fg = colors.blue })
hl(0, 'Repeat',       { fg = colors.blue })
hl(0, 'Operator',     { fg = colors.fg })
hl(0, 'Constant',     { fg = colors.magenta })
hl(0, 'Type',         { fg = colors.yellow })
hl(0, 'Identifier',   { fg = colors.fg })
hl(0, 'PreProc',      { fg = colors.cyan })
hl(0, 'Special',      { fg = colors.brred })
hl(0, 'Error',        { fg = colors.red, bold = true })
hl(0, 'Todo',         { fg = colors.bg, bg = colors.bryellow, bold = true })

-- Diagnostics
hl(0, 'DiagnosticError', { fg = colors.red })
hl(0, 'DiagnosticWarn',  { fg = colors.yellow })
hl(0, 'DiagnosticInfo',  { fg = colors.blue })
hl(0, 'DiagnosticHint',  { fg = colors.cyan })

-- UI
hl(0, 'CursorLine',   { bg = colors.dim and colors.dim.black or '#15171F' })
hl(0, 'Visual',       { bg = '#472541' })   -- matches your selection.background
hl(0, 'Search',       { fg = colors.bg, bg = colors.brmagenta })
hl(0, 'IncSearch',    { fg = colors.bg, bg = colors.red })
hl(0, 'Pmenu',        { fg = colors.fg, bg = '#15171F' })
hl(0, 'PmenuSel',     { fg = colors.bg, bg = colors.brcyan })
hl(0, 'MatchParen',   { fg = colors.bryellow, bold = true })

-- indent-blankline
hl(0, 'IblScope',  { fg = colors.gray })
hl(0, 'IblIndent', { fg = '#3a3d4a' })

-- Transparency (kept from your original)
local transparent_groups = {
  'Normal',
  'NormalNC',
  'NormalFloat',
  'FloatBorder',
  'SignColumn',
  'EndOfBuffer',
}

for _, group in ipairs(transparent_groups) do
  hl(0, group, { bg = 'NONE' })
end

hl(0, 'LineNr',       { fg = colors.gray, bg = 'NONE' })
hl(0, 'CursorLineNr', { fg = colors.brmagenta, bg = 'NONE', bold = true })
----------------- terminal theme end -----------------

-- todo-comments
vim.pack.add { gh 'folke/todo-comments.nvim' }
require('todo-comments').setup {}

-- devicons
vim.pack.add { gh 'nvim-tree/nvim-web-devicons' }

-- lualine
vim.pack.add { gh 'nvim-lualine/lualine.nvim' }

require('lualine').setup {
  options = {
    theme = 'auto',
    icons_enabled = vim.g.have_nerd_font,
    component_separators = { left = '│', right = '│' },
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'hostname', 'filetype', 'fileformat' },
  },
  inactive_sections = {
    lualine_b = { 'diff' },
  },
}

-- top right clock
vim.api.nvim_set_hl(0, 'Clock', { fg = '#75E0D6', bg = '#202330' })
local buf = vim.api.nvim_create_buf(false, true)

local win = vim.api.nvim_open_win(buf, false, {
  relative = 'editor', width = 5, height = 1,
  row = 0, col = vim.o.columns - 5,
  style = 'minimal', border = 'none', focusable = false
})

vim.wo[win].winhl = 'Normal:Clock'

local timer = vim.uv.new_timer()
if timer then
  timer:start(0, 1000, vim.schedule_wrap(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { tostring(os.date('%H:%M')) })
    end
  end))
end

