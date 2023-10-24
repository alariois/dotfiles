local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>pS', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

-- Case-insensitive grep
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({
		search = vim.fn.input("Smart Grep > "),
		ignorecase = true,  -- This makes the search case-insensitive
        smartcase = true    -- Enables smart case searching
	});
end)

-- live grep
vim.keymap.set('n', '<leader>pr', function()
	local pattern = vim.fn.input("Regex Grep > ")
	builtin.live_grep()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(pattern, true, true, true), 'n', true)
end)
