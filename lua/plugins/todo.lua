return {
  --TODO:
  "folke/todo-comments.nvim",
  keys = { { "<leader>ltd" }, { "<leader>tds", ":TodoTelescope<CR>" } },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    highlight = {
      comments_only = false,
    },
  },
}
