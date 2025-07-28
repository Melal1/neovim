return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
    "gbprod/none-ls-shellcheck.nvim", -- shellcheck
  },
  event = "VeryLazy",

  config = function()
    local none_ls = require("null-ls")
    none_ls.setup({
      on_attach = function(client)
        client.offset_encoding = "utf-8"
      end,
      sources = {
        none_ls.builtins.formatting.stylua,
        none_ls.builtins.formatting.shfmt,
        none_ls.builtins.formatting.clang_format,
        none_ls.builtins.formatting.nixpkgs_fmt,
        none_ls.builtins.formatting.prettier,
        require("none-ls.diagnostics.eslint"),
        -- require("none-ls-shellcheck.diagnostics"),
        -- require("none-ls-shellcheck.code_actions"),
      },
      -- on_attach = function(client, bufnr)
      --   if client.supports_method("textDocument/formatting") then
      --     local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      --     vim.api.nvim_clear_autocmds({
      --       group = augroup,
      --       buffer = bufnr,
      --     })
      --     vim.api.nvim_create_autocmd("BufWritePre", {
      --       group = augroup,
      --       buffer = bufnr,
      --       callback = function()
      --         vim.lsp.buf.format({ bufnr = bufnr })
      --       end,
      --     })
      --   end
      -- end,
    })
    vim.keymap.set("n", "<leader>frm", vim.lsp.buf.format, {})
  end,
}
