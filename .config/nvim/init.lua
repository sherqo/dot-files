-- init.lua - Modular entry point
-- Original single-file content (687 lines) split into lua/config/* and lua/plugins/*
-- Backup of original is at init.lua.single.bak

-- 1. Options must come first (sets mapleader before any plugins use it)
require 'config.options'

-- 2. Keymaps and autocmds (no plugin dependencies, but depends on options)
require 'config.keymaps'
require 'config.autocmds'

-- 3. UI / Core UX plugins (tokyonight, gitsigns, which-key, lualine, etc.)
require 'plugins.ui'

-- 3b. File explorer (nvim-tree, restored from bak)
require 'plugins.explorer'

-- 3c. Editing helpers (autopairs, indent-blankline, restored from bak)
require 'plugins.editing'

-- 4. Search & Navigation (telescope)
require 'plugins.telescope'

-- 5. LSP + Mason
require 'plugins.lsp'

-- 6. Formatting (conform)
require 'plugins.formatting'

-- 7. Autocomplete & Snippets (blink.cmp, LuaSnip)
require 'plugins.completion'

-- 8. Treesitter
require 'plugins.treesitter'
