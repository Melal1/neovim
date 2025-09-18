vim.api.nvim_create_autocmd("FileType", {
	pattern = "cpp",
	callback = function()
		vim.keymap.set("n", "<leader>rm", "<cmd>RunMake add<CR>", { desc = "Add file to Makefile" })

		vim.api.nvim_create_user_command("RunMake", function(opts)
			if not opts.args or opts.args == "" then
				vim.notify("RunMake requires one argument", vim.log.levels.WARN)
				return
			end
			require("config.utils.make").RunMake(opts.args)
		end, {
			nargs = 1,
			complete = function()
				return { "add", "edit", "run", "open" }
			end,
		})
	end,
})
