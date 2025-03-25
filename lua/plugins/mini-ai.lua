return {
	"echasnovski/mini.ai",
	version = false,
	event = "BufRead",
	config = function()
		require("mini.ai").setup()
	end,
}
