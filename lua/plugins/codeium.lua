return {
	"Exafunction/codeium.nvim",
	enabled = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	event = "BufRead",
	config = function()
		require("codeium").setup({})
	end,
}
