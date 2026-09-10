-- File Explorer: nvim-tree (restored from nvim.bak)
-- Extracted from nvim.bak/lua/sherqo/plugins.lua:19

local gh = require('config.util').gh

vim.pack.add {
  gh 'nvim-tree/nvim-tree.lua',
  gh 'nvim-tree/nvim-web-devicons', -- already in ui.lua but ensure loaded
}

require('nvim-tree').setup {}

vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })
