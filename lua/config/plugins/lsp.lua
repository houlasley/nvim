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

    -- SAFE RENAME (Fix for Neovim 0.12 annotated edits requirement)
    local function safe_rename(new_name)
      local curr = new_name or vim.fn.input("Rename to > ", vim.fn.expand("<cword>"))
      if curr == "" then return end

      vim.lsp.buf_request(0, "textDocument/rename", {
        textDocument = vim.lsp.util.make_text_document_params(),
        newName = curr,
        position = vim.lsp.util.make_position_params().position,
      }, function(_, result, ctx)
        if not result then return end

        -- Add changeAnnotations if missing (fixes Neovim 0.12 crash)
        if result.documentChanges then
          result.changeAnnotations = result.changeAnnotations or {}

          for _, change in ipairs(result.documentChanges) do
            for _, edit in ipairs(change.edits or {}) do
              if edit.annotationId and not result.changeAnnotations[edit.annotationId] then
                result.changeAnnotations[edit.annotationId] = {
                  label = "rename",
                  needsConfirmation = false,
                }
              end
            end
          end
        end

        local client = vim.lsp.get_client_by_id(ctx.client_id)
        vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)
      end)
    end

    -- Globally override Neovim's rename
    vim.lsp.buf.rename = safe_rename

    local function on_attach(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

      -- Shortcut for rename (grn)
      vim.keymap.set("n", "grn", function() safe_rename() end, opts)

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
          },
          diagnostics = {
            enable = true,
            globals = { "vim" }
          }
        }
      }
    })

    -- Python (pyright)
    lspconfig.pyright.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
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

    -- TypeScript + Vue Plugin
    lspconfig.ts_ls.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)

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
            languages = { "javascript", "typescript" },
          },
        },
      },
      filetypes = { "typescript", "javascript" },
      root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
    })

    -- Volar (Vue)
    lspconfig.volar.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
      filetypes = { "vue" },
      root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
    })

    -- Rust
    lspconfig.rust_analyzer.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = { command = "clippy" },
          cargo = { allFeatures = true },
          inlayHints = {
            lifetimeElisionHints = { enable = true, useParameterNames = true },
            bindingModeHints = { enable = true },
            closureReturnTypeHints = { enable = "always" },
            expressionAdjustmentHints = { enable = "always" },
          },
        },
      },
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

              -- NOTE: organizeImports removed here
              -- because rename fix uses apply_workspace_edit safely
              -- and organizeImports auto-apply can crash Neovim 0.12
            end,
          })
        end
      end,
    })
  end,
}
