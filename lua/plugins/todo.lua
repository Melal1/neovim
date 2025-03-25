return {
	"folke/todo-comments.nvim",
	event = { "VeryLazy", "BufRead" },
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		highlight = {
			comments_only = false,
		},
	},
}
