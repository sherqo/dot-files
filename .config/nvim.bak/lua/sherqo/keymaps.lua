-- save file shortcut
vim.keymap.set("n", "<leader>w", ":w<CR>")

-- Ctrl+P like VSCode - search files in project
vim.keymap.set("n", "<C-p>", function()
  require("telescope.builtin").find_files()
end)

-- cycle buffers left/right
vim.keymap.set("n", "[b", ":bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", ":bnext<CR>", { desc = "Next buffer" })

