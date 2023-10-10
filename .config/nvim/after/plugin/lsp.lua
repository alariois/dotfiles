local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  'tsserver',
  'lua_ls',
  'rust_analyzer',
})

-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})


local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vtr", function() require'telescope.builtin'.lsp_references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-l>", function() vim.lsp.buf.signature_help() end, opts)

    --- Guard against servers without the signatureHelper capability
  if client.server_capabilities.signatureHelpProvider then
    require('lsp-overloads').setup(client, {
        -- UI options are mostly the same as those passed to vim.lsp.util.open_floating_preview
        ui = {
          border = "single",           -- The border to use for the signature popup window. Accepts same border values as |nvim_open_win()|.
          height = nil,               -- Height of the signature popup window (nil allows dynamic sizing based on content of the help)
          width = nil,                -- Width of the signature popup window (nil allows dynamic sizing based on content of the help)
          wrap = true,                -- Wrap long lines
          wrap_at = nil,              -- Character to wrap at for computing height when wrap enabled
          max_width = nil,            -- Maximum signature popup width
          max_height = nil,           -- Maximum signature popup height
          -- Events that will close the signature popup window: use {"CursorMoved", "CursorMovedI", "InsertCharPre"} to hide the window when typing
          close_events = { "CursorMoved", "BufHidden", "InsertLeave" },
          focusable = true,           -- Make the popup float focusable
          focus = false,              -- If focusable is also true, and this is set to true, navigating through overloads will focus into the popup window (probably not what you want)
          offset_x = 0,               -- Horizontal offset of the floating window relative to the cursor position
          offset_y = 0,                -- Vertical offset of the floating window relative to the cursor position
          floating_window_above_cur_line = false -- Attempt to float the popup above the cursor position
                                                 -- (note, if the height of the float would be greater than the space left above the cursor, it will default
                                                 -- to placing the float below the cursor. The max_height option allows for finer tuning of this)
        },
        keymaps = {
          next_signature = "<C-j>",
          previous_signature = "<C-k>",
          next_parameter = "<C-l>",
          previous_parameter = "<C-h>",
          close_signature = "<A-s>"
        },
        display_automatically = true -- Uses trigger characters to automatically display the signature overloads when typing a method signature
      })
  end
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})

