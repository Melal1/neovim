return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  keys = {
    { "<leader>tc", "<cmd>Copilot toggle<CR>", mode = "n", desc = "Toggle Copilot" },
  },
  opts = {
    suggestion = { enabled = false },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
}

