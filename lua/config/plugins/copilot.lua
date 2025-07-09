return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      -- Disable default Tab mapping
      vim.g.copilot_no_tab_map = true

      -- Accept suggestion with Ctrl-J
      vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")',
        { expr = true, silent = true })

      -- Track Copilot state
      vim.g.copilot_enabled = true

      -- Toggle function
      function ToggleCopilot()
        if vim.g.copilot_enabled then
          vim.cmd("Copilot disable")
          vim.g.copilot_enabled = false
          print("Copilot disabled")
        else
          vim.cmd("Copilot enable")
          vim.g.copilot_enabled = true
          print("Copilot enabled")
        end
      end

      -- Keymaps to control Copilot
      vim.api.nvim_set_keymap("n", "<leader>ce", ":Copilot enable<CR>",
        { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<leader>cd", ":Copilot disable<CR>",
        { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<leader>ct", ":lua ToggleCopilot()<CR>",
        { noremap = true, silent = true })
    end,
  }
}
