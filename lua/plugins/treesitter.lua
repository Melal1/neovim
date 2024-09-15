return {
  "nvim-treesitter/nvim-treesitter",
  event = "BufRead",
  build = ":TSUpdate",
  config = function () 
      require("nvim-treesitter.configs").setup({
          ensure_installed = { "c", "lua", },
          highlight = { enable = true },
          indent = { enable = true },  
        })
    end
 }

