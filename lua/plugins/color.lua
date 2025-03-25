-- local mapping = ccc.mapping
return {
	"uga-rosa/ccc.nvim",
  event = "BufRead";
	config = function()
		local ccc = require("ccc")
		-- Custom key mappings for ccc commands
		local keymap = vim.api.nvim_set_keymap
		local opts = { noremap = true, silent = true }

		-- Normal mode mappings
		keymap("n", "<leader>cp", ":CccPick<CR>", opts) -- Pick color under cursor
		keymap("n", "<leader>cc", ":CccConvert<CR>", opts) -- Convert color format
		keymap("n", "<leader>cct", ":CccHighlighterToggle<CR>", opts) -- Toggle highlighter

		-- Optional: Insert mode mapping for <Plug>(ccc-insert)
		keymap("i", "<C-c>", "<Plug>(ccc-insert)", opts)

		-- Optional: Visual mode mapping for <Plug>(ccc-select-color)
		keymap("v", "<leader>cs", "<Plug>(ccc-select-color)", opts)
		ccc.setup({
			highlighter = {
				auto_enable = false,
				lsp = true,
			},
			outputs = {
				ccc.output.hex, -- #RRGGBB
				ccc.output.css_rgb, -- rgb(255, 0, 0)
				ccc.output.css_rgba, -- rgba(255, 0, 0, 0.5)
			},
		})
	end,
}
