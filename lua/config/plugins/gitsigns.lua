return {
  'lewis6991/gitsigns.nvim',
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require('gitsigns').setup {
      signs                        = {
        add          = { text = '▎' },
        change       = { text = '▎' },
        delete       = { text = '󰍵' },
        topdelete    = { text = '󰍵' },
        changedelete = { text = '▎' },
        untracked    = { text = '▎' },
      },
      signcolumn                   = true,
      numhl                        = false,
      linehl                       = false,
      word_diff                    = false,
      watch_gitdir                 = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked          = true,
      current_line_blame           = true,
      current_line_blame_opts      = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 300,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      update_debounce              = 200,
      max_file_length              = 40000,
      preview_config               = {
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
      },
    }

    -- Keybindings using updated nav_hunk API
    local gs = require('gitsigns')

    vim.keymap.set('n', ']c', function() gs.nav_hunk("next") end,
      { desc = 'Next Git hunk' })
    vim.keymap.set('n', '[c', function() gs.nav_hunk("prev") end,
      { desc = 'Prev Git hunk' })
    vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
    vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
    vim.keymap.set('n', '<leader>hb', function() gs.blame_line { full = true } end,
      { desc = 'Blame line' })
    vim.keymap.set('n', '<leader>ht', gs.toggle_current_line_blame,
      { desc = 'Toggle line blame' })
  end
}
