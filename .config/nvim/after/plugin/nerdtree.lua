local map = vim.api.nvim_set_keymap

-- Options for the key mappings
local options = { noremap = true, silent = true }

map('n', '<leader>n', ':NERDTreeFocus<CR>', options)
map('n', '<C-n>', ':NERDTree<CR>', options)
map('n', '<C-t>', ':NERDTreeToggle<CR>', options)
map('n', '<C-f>', ':NERDTreeFind<CR>', options)

vim.g.NERDTreeWinSize = 60
