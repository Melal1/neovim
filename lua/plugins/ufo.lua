return {
	"kevinhwang91/nvim-ufo",
	dependencies = { "kevinhwang91/promise-async" },
	event = "BufReadPost",
	config = function()
		-- vim.o.foldcolumn = "1"
		vim.o.foldenable = true
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		require("ufo").setup({
			-- open_fold_hl_timeout = 0,
			-- close_fold_kinds_for_ft = {},
			-- enable_get_fold_virt_text = false,
			-- fold_virt_text_handler = nil,
			provider_selector = function(bufnr, filetype, buftype)
				if buftype ~= "" or filetype == "neo-tree" then
					return "" -- Disable UFO for special/non-file buffers_color
				end
				return { "lsp", "indent" }
			end,
		})

		vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
		vim.keymap.set("n", "zK", function()
			local ex = require("ufo").peekFoldedLinesUnderCursor()
			if not ex then
				vim.lsp.buf.hover()
			end
		end, { desc = "Peek fold" })
	end,
}
