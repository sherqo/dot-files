-- Autocomplete & Snippets (blink.cmp + LuaSnip + copilot)
-- Extracted from init.lua Section 8 + restored copilot from nvim.bak

local gh = require('config.util').gh

-- Copilot (restored from nvim.bak plugins.lua:88)
vim.pack.add { gh 'zbirenbaum/copilot.lua' }
require('copilot').setup {
  suggestion = { enabled = false },
  panel = { enabled = false },
}

-- NOTE: zbirenbaum/copilot-cmp removed — it requires hrsh7th/nvim-cmp (module 'cmp')
-- which you don't have (you use blink.cmp). Keeping it caused:
--   copilot_cmp/init.lua:31: module 'cmp' not found on LspAttach/InsertEnter
-- If you want Copilot in the blink.cmp popup, use a blink bridge instead:
--   vim.pack.add { gh 'fang2hou/blink-copilot' }
--   and add 'copilot' to sources.default below + providers.copilot config

-- Snippet Engine
vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
require('luasnip').setup {}

vim.pack.add { gh 'rafamadriz/friendly-snippets' }
require('luasnip.loaders.from_vscode').lazy_load()

-- Autocomplete Engine
vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
require('blink.cmp').setup {
  keymap = {
    preset = 'super-tab',
  },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    trigger = {
      show_on_keyword = true,
      show_on_trigger_character = true,
      show_on_insert_on_trigger_character = true,
    },
    list = {
      selection = {
        preselect = false, -- Don't auto-select the first option immediately
        auto_insert = false, -- Don't auto-insert text into the buffer while typing
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 0, -- Instant documentation without speed loss
    },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets' },
    providers = {
      lsp = {
        timeout_ms = 2000,
        max_items = 50, -- Ensures broad completion candidates are returned
      },
      path = {
        score_offset = 3,
      },
      snippets = {
        score_offset = 2,
      },
    },
  },

  snippets = { preset = 'luasnip' },

  -- Fast native Rust matcher to fix latency without dropping candidates
  fuzzy = { implementation = 'prefer_rust_with_warning' },

  signature = { enabled = true },
}
