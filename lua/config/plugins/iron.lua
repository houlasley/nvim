return {
  {
    "Vigemus/iron.nvim",
    config = function()
      require("iron.core").setup {
        config = {
          -- Define a REPL for Python
          repl_definition = {
            python = {
              command = { "python", "-i" } -- interactive Python shell
            }
          },
          -- Open the REPL in a vertical split on the right
          repl_open_cmd = "vertical botright 80 split",
        },
        keymaps = {
          send_motion       = "<leader>sc",
          visual_send       = "<leader>sc",
          send_file         = "<leader>sf",
          send_line         = "<leader>sl",
          send_until_cursor = "<leader>su",
          send_mark         = "<leader>sm",
          mark_motion       = "<leader>mc",
          mark_visual       = "<leader>mc",
          remove_mark       = "<leader>md",
          cr                = "<leader>s<cr>",
          interrupt         = "<leader>s<space>",
          exit              = "<leader>sq",
          clear             = "<leader>cl"
        },
        highlight = {
          italic = true
        },
      }
    end,
  }

}
