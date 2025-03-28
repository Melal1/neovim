return {
	-- theme = "lushwal",
	"CRAG666/code_runner.nvim",
	keys = {
		{
			"<leader>rf",
			"<cmd>RunFile<CR>",
		},
		{
			"<leader>rc",
			"<cmd>RunClose<CR>",
		},
	},

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
	end,
}
