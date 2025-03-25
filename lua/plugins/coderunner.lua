return {
	-- theme = "lushwal",
	"CRAG666/code_runner.nvim",
	event = "VeryLazy",

	config = function()
		require("code_runner").setup({
			filetype = {
				cpp = {
					"cd $dir &&",
					"g++ $fileName -o $fileNameWithoutExt &&",
					"./$fileNameWithoutExt &&",
					"rm $fileNameWithoutExt",
				},
			},
		})

		vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false })
		vim.keymap.set("n", "<leader>rc", ":RunClose<CR>", { noremap = true, silent = false })
	end,
}
