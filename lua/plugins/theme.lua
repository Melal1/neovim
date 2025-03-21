local theme = require("config.utils").apply_theme()
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = { transparent_background = true },
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme(theme)
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				transparent = true,
			})
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		config = function()
			require("kanagawa").setup({ transparent = true })
		end,
	},

	{
		"EdenEast/nightfox.nvim",
		priority = 1000,
		config = function()
			require("nightfox").setup({ options = { transparent = true } })
		end,
	},
}
