require("telescope").load_extension("git_worktree")

-- worktree create
vim.keymap.set("n", "<leader>wc", function() require('telescope').extensions.git_worktree.create_git_worktree() end)
-- worktree switch
vim.keymap.set("n", "<leader>ws", function() require('telescope').extensions.git_worktree.git_worktrees() end)
