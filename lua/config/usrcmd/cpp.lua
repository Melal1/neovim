vim.api.nvim_create_autocmd("FileType", {
	pattern = "cpp",
	callback = function()
		vim.keymap.set("n", "<leader>rm", "<cmd>Make add<CR>", { desc = "Add file to Makefile" })
		vim.keymap.set("n", "<leader>RF", "<cmd>Make fastrun<CR>")
		vim.keymap.set("n", "<leader>rf", "<cmd>Make run split<CR>")
		vim.keymap.set("n", "<leader>rF", "<cmd>Make runb split<CR>")
		-- vim.keymap.set("n", "<leader>rF", "<cmd>Make run split<CR>")

		vim.api.nvim_create_user_command("Make", function(opts)
			if opts.fargs[1] == "fastrun" then
				require("config.utils.make").FastRun()
				return
			end
			require("config.utils.make").Make(opts.fargs)
		end, {
			nargs = "*",
			complete = function(_, CmdLine)
				local Args = vim.split(CmdLine, "%s+")
				if Args[2] == "run" then
					return { "split", "float", "tab" }
				end

				return {
					"picker",
					"build",
					"bear",
					"bearall",
					"add",
					"edit",
					"run",
					"runb",
					"open",
					"edit_all",
					"remove",
					"analysis",
					"fastrun",
				}
			end,
		})
	end,
})
