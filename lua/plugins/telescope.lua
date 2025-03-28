return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		-- Remove event, use cmd or keys to lazy-load
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
			{ "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Projects" },
			{
				"gd",
				function()
					local path = vim.fn.expand("<cfile>")
					if vim.fn.filereadable(vim.fn.expand(path)) == 1 then
						vim.cmd("edit " .. path)
					else
						require("telescope.builtin").find_files({ default_text = path })
					end
				end,
				desc = "Go to file or search",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			"ahmedkhalf/project.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({
				pickers = {
					find_files = {
						hidden = true,
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
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
