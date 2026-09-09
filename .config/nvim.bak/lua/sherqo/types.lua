---@class sherqo.Highlight: vim.api.keyset.highlight
---@field style? vim.api.keyset.highlight

---@alias sherqo.Highlights table<string,sherqo.Highlight|string>

---@alias sherqo.HighlightsFn fun(colors: ColorScheme, opts:sherqo.Config):sherqo.Highlights

---@class sherqo.Cache
---@field groups sherqo.Highlights
---@field inputs table
