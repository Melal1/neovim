local telescope = require("telescope")
local builtin = require("telescope.builtin")
return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			"ahmedkhalf/project.nvim",
		},
		config = function()
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

			require("project_nvim").setup({})
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
			vim.keymap.set("n", "<leader>fp", "<cmd>:Telescope projects<cr>", {})
      -- Custom : will try to open def if failed open it on telescope
			vim.keymap.set("n", "gd", function()
				local path = vim.fn.expand("<cfile>")
				if vim.fn.filereadable(vim.fn.expand(path)) == 1 then
					vim.cmd("edit " .. path)
				else
					builtin.find_files({ default_text = path })
				end
			end, { noremap = true, silent = true, desc = "Go to file or search" })

			-- Load the ui-select extension
			telescope.load_extension("ui-select")
			telescope.load_extension("projects")
		end,
	},
}
