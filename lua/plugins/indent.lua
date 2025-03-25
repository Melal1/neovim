return {
	"lukas-reineke/indent-blankline.nvim",
	event = "Bufread",
	main = "ibl",
	---@module "ibl"
	---@type ibl.config
	opts = {},

	config = function()
		require("ibl").setup({

			scope = {

				enabled = false,
			},
		})
	end,
}
