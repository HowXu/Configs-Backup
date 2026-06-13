-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- No macro
vim.keymap.set("n", "q", "<Nop>")

-- MiniMap quick
vim.keymap.set('n', '<leader>m', '<Nop>', { desc = "MiniMap Quick Set" })
vim.keymap.set('n', '<leader>md', '<cmd>Neominimap Disable<CR>', { desc = "Disable Neominimap" })
vim.keymap.set('n', '<leader>me', '<cmd>Neominimap Enable<CR>', { desc = "Enable Neominimap" })