return {

	"nvim-treesitter/nvim-treesitter", 
	branch = "main",
	event = { "BufRead", "BufNewFile" },
	-- dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" }, --TODO: 
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install({"cpp","bash","lua","rust"})
  end,
}
