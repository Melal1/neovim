return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    -- Remove event, use cmd or keys to lazy-load
    cmd = "Telescope",
    keys = {

      { "<leader>frg", "<cmd>Telescope registers<cr>", desc = "Find Files" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
      { "<leader>fp", "<cmd>Telescope projects<cr>",   desc = "Projects" },

      {
        "<leader>fSt",
        function()
          local word = vim.fn.expand("<cWORD>")
          require("telescope.builtin").grep_string({ search = word })
        end,
        desc = "Grep WORD under cursor (includes punctuation)",
      },
      {
        "<leader>fst",
        function()
          local word = vim.fn.expand("<cword>")
          require("telescope.builtin").grep_string({ search = word })
        end,
        desc = "Grep word under cursor (stops at punctuation)",
      },
      {
        "<leader>fo",
        function()
          require("telescope.builtin").oldfiles()
        end,
      },
      -- LSP
      {
        "<leader>fsy",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
      },

      {
        "<leader>fdia",
        function()
          require("telescope.builtin").diagnostics()
        end,
      },

      -- {
      -- 	"gd",
      -- 	function()
      -- 		local path = vim.fn.expand("<cfile>")
      -- 		if vim.fn.filereadable(vim.fn.expand(path)) == 1 then
      -- 			vim.cmd("edit " .. path)
      -- 		else
      -- 			require("telescope.builtin").find_files({ default_text = path })
      -- 		end
      -- 	end,
      -- 	desc = "Go to file or search",
      -- },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "ahmedkhalf/project.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = actions.close,
            },
          },
          path_display = {
            "filename_first",
          },
          previewer = false,
          prompt_prefix = "    ",
          selection_caret = " ",
          file_ignore_patterns = { "node_modules", "package-lock.json" },
          initial_mode = "insert",
          select_strategy = "reset",
          sorting_strategy = "ascending",
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
          layout_config = {
            prompt_position = "top",
            preview_cutoff = 120,
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
          },
        },
        pickers = {
          buffers = {
            mappings = {
              i = {
                ["<c-d>"] = actions.delete_buffer,
              },
              n = {
                ["<c-d>"] = actions.delete_buffer,
              },
            },
            previewer = false,
            initial_mode = "normal",
            -- theme = "dropdown",
            layout_config = {
              height = 0.4,
              width = 0.6,
              prompt_position = "top",
              preview_cutoff = 120,
            },
          },
          current_buffer_fuzzy_find = {
            previewer = true,
            layout_config = {
              prompt_position = "top",
              preview_cutoff = 120,
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              previewer = false,
              initial_mode = "normal",
              sorting_strategy = "ascending",
              layout_strategy = "horizontal",
              layout_config = {
                horizontal = {
                  width = 0.5,
                  height = 0.4,
                  preview_width = 0.6,
                },
              },
            }),
          },
        },
      })

      -- Setup project.nvim
      require("project_nvim").setup({})

      -- Load extensions
      telescope.load_extension("ui-select")
      telescope.load_extension("projects")
    end,
  },
}
