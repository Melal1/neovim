return {

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      local lspconfig = require("lspconfig")

      lspconfig.lua_ls.setup({
        capabilities = capabilities, -- Add this for consistency
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      lspconfig.clangd.setup({
        capabilities = vim.tbl_deep_extend("force", capabilities, {
          offsetEncoding = { "utf-8" },
        }),
        root_dir = lspconfig.util.root_pattern(".git", ".clangd", "compile_commands.json", "compile_flags.txt"),
      })

      lspconfig.bashls.setup({

        capabilities = capabilities, -- Add this for consistency
      })
      lspconfig.nil_ls.setup({

        capabilities = capabilities, -- add this for consistency
      })
      lspconfig.cssls.setup({
        capabilities = capabilities,
      })
      lspconfig.tailwindcss.setup({
        capabilities = capabilities,
      })
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        init_options = {
          prefrences = {
            disableSuggestions = true,
          },
        },
      })
      lspconfig.eslint.setup({
        capabilities = capabilities,
        settings = {
          workingDirectories = { mode = "auto" },
        },
      })

      vim.keymap.set("n", "<leader>lmk", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<C-Space>", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
      vim.keymap.set("n", "gD", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "K", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, {})
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
    end,
  },
}
