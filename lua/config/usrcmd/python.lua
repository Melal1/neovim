vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.tabstop = 2 -- number of visual spaces per TAB
		vim.opt_local.shiftwidth = 2 -- number of spaces for autoindent
		vim.opt_local.softtabstop = 2 -- number of spaces when pressing TAB
		vim.opt_local.expandtab = true -- convert tabs to spaces

		local file = vim.fn.expand("%:p")
		if file ~= "" then
			vim.keymap.set("n", "<leader>rf", function()
				require("config.utils.toggleTerm").SingleShot("python3 " .. file)
			end, { desc = "Run current Python file" })
		end
	end,
})
