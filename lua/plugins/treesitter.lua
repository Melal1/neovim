return {

	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
	},
	branch = "main",
	event = { "BufRead", "BufNewFile" },
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		ts.install({ "cpp", "bash", "lua", "rust" })
	end,
}
