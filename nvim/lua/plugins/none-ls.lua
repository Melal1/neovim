return {
	"nvimtools/none-ls.nvim",
	config = function()
		local none_ls = require("null-ls")
		none_ls.setup({
			sources = {
				none_ls.builtins.formatting.stylua,
			},
		})
		vim.keymap.set("n", "<leader>frm", vim.lsp.buf.format, {})
	end,
}
