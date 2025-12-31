return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")

      -- Mason
      require("mason").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "delve" },
        automatic_installation = true,
      })

      -- UI
      ui.setup()
      require("dap-go").setup()

      -- Virtual text (with secret masking)
      require("nvim-dap-virtual-text").setup({
        display_callback = function(variable)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)
          if name:match("secret")
              or name:match("api")
              or value:match("secret")
              or value:match("api")
          then
            return "*****"
          end

          if #variable.value > 15 then
            return " " .. string.sub(variable.value, 1, 15) .. "... "
          end

          return " " .. variable.value
        end,
      })

      ---------------------------------------------------------------------------
      -- Python (debugpy)
      ---------------------------------------------------------------------------
      dap.adapters.python = function(cb, config)
        if config.request == "attach" then
          cb({
            type = "server",
            host = config.connect.host,
            port = config.connect.port,
          })
        else
          cb({
            type = "executable",
            command = vim.fn.exepath("python"),
            args = { "-m", "debugpy.adapter" },
          })
        end
      end

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            local venv = os.getenv(".venv")
            if venv then
              return venv .. "/bin/python"
            end
            return vim.fn.exepath("python")
          end,
        },
        {
          type = "python",
          request = "launch",
          name = "Launch module",
          module = function()
            return vim.fn.input("Module name > ")
          end,
        },
        {
          type = "python",
          request = "attach",
          name = "Attach (debugpy)",
          connect = {
            host = "127.0.0.1",
            port = 5678,
          },
        },
      }

      ---------------------------------------------------------------------------
      -- Elixir
      ---------------------------------------------------------------------------
      local elixir_ls_debugger = vim.fn.exepath("elixir-ls-debugger")
      if elixir_ls_debugger ~= "" then
        dap.adapters.mix_task = {
          type = "executable",
          command = elixir_ls_debugger,
        }

        dap.configurations.elixir = {
          {
            type = "mix_task",
            name = "phoenix server",
            task = "phx.server",
            request = "launch",
            projectDir = "${workspaceFolder}",
            exitAfterTaskReturns = false,
            debugAutoInterpretAllModules = false,
          },
        }
      end

      ---------------------------------------------------------------------------
      -- Keymaps
      ---------------------------------------------------------------------------
      vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
      vim.keymap.set("n", "<space>gb", dap.run_to_cursor)

      vim.keymap.set("n", "<space>?", function()
        ui.eval(nil, { enter = true })
      end)

      vim.keymap.set("n", "<F1>", dap.continue)
      vim.keymap.set("n", "<F2>", dap.step_into)
      vim.keymap.set("n", "<F3>", dap.step_over)
      vim.keymap.set("n", "<F4>", dap.step_out)
      vim.keymap.set("n", "<F5>", dap.step_back)
      vim.keymap.set("n", "<F12>", dap.restart)

      ---------------------------------------------------------------------------
      -- UI lifecycle
      ---------------------------------------------------------------------------
      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
