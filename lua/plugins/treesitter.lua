return {

  "nvim-treesitter/nvim-treesitter",
  event = { "BufRead" , "BufNewFile"},
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "cpp", "lua", "bash", "javascript", "typescript" },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
