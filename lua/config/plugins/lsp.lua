return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "saghen/blink.cmp",
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("blink-cmp").get_lsp_capabilities()

    local function on_attach(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end

    -- Lua
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          hint = {
            enable = true,
            setType = true,
            paramType = true,
            paramName = "All",
            -- semicolon = "None",
            -- arrayIndex = "Disable",
          },
          diagnostics = {
            enable = true,
            globals = { "vim" }
          }
        }
      }
    })

    -- Python
    lspconfig.pyright.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        -- disable formatting from pyright
        client.server_capabilities.documentFormattingProvider = false
        on_attach(client, bufnr)
      end,
    })

    -- Golang
    lspconfig.gopls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        gopls = {
          gofumpt = true,
          staticcheck = true,
          usePlaceholders = true,
          analyses = {
            unusedparams = true,
            shadow = true,
          },
        },
      },
    })
    -- Ruff
    lspconfig.ruff.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        -- optional: format on save if ruff supports it
        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
      settings = {
        ruff = {
          lineLength = 88,
          select = { "E", "F", "W", "C90", "I" },
          format = { enabled = true },
        },
      },
    })

    -- TypeScript + Vue
    lspconfig.ts_ls.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        -- Format on save
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
      init_options = {
        plugins = {
          {
            name = "@vue/typescript-plugin",
            location = vim.fn.getcwd() .. "/node_modules/@vue/typescript-plugin",
            languages = { "javascript", "typescript", "vue" },
          },
        },
      },
      filetypes = { "typescript", "javascript", "vue" },
      root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
    })

    -- Auto format + organize imports on save
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ bufnr = args.buf })
              vim.lsp.buf.code_action({
                context = {
                  only = { "source.organizeImports" },
                  diagnostics = {}
                },
                apply = true,
              })
            end,
          })
        end
      end,
    })
  end,
}
