vim.o.splitright = true -- Make vertical splits open on the right

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or use "zbirenbaum/copilot.lua"
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken", -- optional: only needed for token counting
    context = { "buffers" },
    opts = {
      window = {
        layout = "vertical",
        width = 0.4, -- 40% of the editor width
      },
      mappings = {
        reset = {
          normal = '<C-r>',
          insert = '<C-r>',
        }
      },
    },
    keys = {
      { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
    },
  },

}
