-- This does not quite work yet, have to use interactive shell
vim.o.shell = vim.fn.expand('~/vim-shell.sh')

-- use interactive shell (SLOW!!!)
-- vim.o.shellcmdflag = '-ic'

-- run shell command and populate args with the output
-- EXAMPLE
-- :argsh find -name "*.c"
vim.api.nvim_create_user_command(
  'PA',
  function(opts)
    local shell_command = opts.args
    local file_list = vim.fn.systemlist(shell_command)
    if #file_list == 0 or (file_list[1] ~= nil and vim.startswith(file_list[1], 'Command failed:')) then
      print('Command failed or no files found')
    else
      vim.cmd('args ' .. table.concat(file_list, ' '))
    end
  end,
  { nargs = 1 }
)

require("theprimeagen");
