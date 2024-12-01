-- MEMO: C-Left doesn't work when using Mac
vim.api.nvim_set_keymap("n", "<A-Left>", ":vertical resize -2<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-Right>", ":vertical resize +2<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-Up>", ":resize +2<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-Down>", ":resize -2<CR>", { noremap = true, silent = true })

-- jj
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true, silent = true })
