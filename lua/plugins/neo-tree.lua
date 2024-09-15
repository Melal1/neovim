return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", 
      "MunifTanjim/nui.nvim", 
  
  },
    opts = {
              mappings = {
                ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
    },
      close_if_last_window = false,
      filesystem = {
      bind_to_cwd = true,
      follow_current_file = { enabled = true },

      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = true,
        hide_gitignored = false,
        hide_by_name = {
          ".git",
          ".DS_Store",
          "thumbs.db",
        },
        never_show = {},
      },
    },
    },
  
  config = function(_,opts)
    require("neo-tree").setup(opts)
    vim.keymap.set("n" , "<C-n>" , ":Neotree filesystem toggle left<CR>")
    vim.keymap.set("n" , "<leader>n" , ":Neotree filesystem focus<CR>")
  end
}
