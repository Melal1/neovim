return {
	"uga-rosa/ccc.nvim",
	keys = { -- Lazy-load via keymaps instead of event alone
		{ "<leader>cp", "<cmd>CccPick<CR>", desc = "Pick color under cursor" },
		{ "<leader>cc", "<cmd>CccConvert<CR>", desc = "Convert color format" },
		{ "<leader>cct", "<cmd>CccHighlighterToggle<CR>", desc = "Toggle color highlighter" },
		{ "<C-c>", "<Plug>(ccc-insert)", mode = "i" }, -- Insert mode
		{ "<leader>cs", "<Plug>(ccc-select-color)", mode = "v" }, -- Visual mode
	},
	config = function()
		require("ccc").setup({
			highlighter = {
				auto_enable = false, -- Keep disabled by default to save time
				lsp = true, -- Leverage LSP for accuracy
			},
			outputs = {
				require("ccc").output.hex, -- #RRGGBB
				require("ccc").output.css_rgb, -- rgb(255, 0, 0)
				require("ccc").output.css_rgba, -- rgba(255, 0, 0, 0.5)
			},
		})
	end,
}
