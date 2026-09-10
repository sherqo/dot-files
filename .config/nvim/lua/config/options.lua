-- Options: Core Neovim settings, leaders, editor behavior
-- Extracted from init.lua Section 1

vim.loader.enable() -- Enable faster startup by caching compiled Lua modules

vim.g.mapleader = ' ' -- Set <space> as the leader key
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a' -- Enable mouse mode, can be useful for resizing splits
vim.o.showmode = false -- Don't show the mode, since it's already in the status line
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus' -- Sync clipboard between OS and Neovim
end)
vim.o.breakindent = true -- Enable break indent
vim.o.wrap = false -- Disable text warp
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 20
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.inccommand = 'split' -- Preview substitutions live, as you type!
vim.o.cursorline = true -- Show which line your cursor is on
vim.o.scrolloff = 8
vim.o.confirm = true -- To show a nice command asking if you did :q with unsaved changes
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
-- vim.o.undofile = true -- Enable undo/redo changes even after closing and reopening a file
