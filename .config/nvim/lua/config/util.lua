-- Helper to build GitHub URL for vim.pack
-- Usage: gh 'owner/repo' -> 'https://github.com/owner/repo'
local M = {}

---@param repo string
---@return string
function M.gh(repo)
  return 'https://github.com/' .. repo
end

return M
