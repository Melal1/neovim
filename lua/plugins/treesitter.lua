return {

	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
	},
	branch = "main",
	event = { "BufRead", "BufNew" },
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		ts.install({ "cpp", "bash", "lua", "rust", "make" })
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(details)
				vim.defer_fn(function()
					local bufnr = details.buf
					if not pcall(vim.treesitter.start, bufnr) then
						return -- Exit if treesitter was unable to start
					end
					vim.bo[bufnr].syntax = "on" -- fallback syntax highlighting
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- treesitter folds
					vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" -- treesitter indentation
				end, 50) -- delay in milliseconds
			end,
		})
	end,
}
