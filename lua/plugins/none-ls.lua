return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
    "gbprod/none-ls-shellcheck.nvim", -- shellcheck
  },
  config = function()
    local none_ls = require("null-ls")
    none_ls.setup({
      sources = {
        none_ls.builtins.formatting.stylua,
        none_ls.builtins.formatting.shfmt,
        -- require("none-ls-shellcheck.diagnostics"),
        -- require("none-ls-shellcheck.code_actions"),
      },
    })
    vim.keymap.set("n", "<leader>frm", vim.lsp.buf.format, {})
  end,
}
