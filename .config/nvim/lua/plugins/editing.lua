-- Editing helpers: autopairs + indent guides
-- Restored from nvim.bak/lua/sherqo/plugins.lua:189,197

local gh = require('config.util').gh

-- nvim-autopairs: auto close brackets/quotes
vim.pack.add { gh 'windwp/nvim-autopairs' }
require('nvim-autopairs').setup {}

-- indent-blankline: indent guides
vim.pack.add { gh 'lukas-reineke/indent-blankline.nvim' }
require('ibl').setup {}
