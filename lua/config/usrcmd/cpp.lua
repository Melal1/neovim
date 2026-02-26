vim.api.nvim_create_autocmd("FileType", {
	pattern = "cpp",
	callback = function()
		vim.keymap.set("n", "<leader>rm", "<cmd>Make add<CR>", { desc = "Add file to Makefile" })
		vim.keymap.set("n", "<leader>RF", "<cmd>Make fastrun<CR>")
		vim.keymap.set("n", "<leader>rf", "<cmd>Make run<CR>")
		vim.keymap.set("n", "<leader>rF", "<cmd>Make runb<CR>")
		vim.keymap.set("n", "<leader>rb", "<cmd>Make build<CR>", { desc = "Build current target" })
		vim.keymap.set("n", "<leader>rl", "<cmd>Make link<CR>", { desc = "Manage link groups" })
		-- vim.keymap.set("n", "<leader>rF", "<cmd>Make run split<CR>")

		vim.api.nvim_create_user_command("Make", function(opts)
			if opts.fargs[1] == "fastrun" then
				require("config.utils.make").FastRun()
				return
			end
			require("config.utils.make").Make(opts.fargs)
		end, {
			nargs = "*",
			complete = function(arglead, CmdLine)
				local Args = vim.split(CmdLine, "%s+")
				if Args[2] == "run" then
					local run_opts = { "split", "float", "tab" }
					if arglead and arglead ~= "" then
						return vim.tbl_filter(function(item)
							return item:find("^" .. vim.pesc(arglead)) ~= nil
						end, run_opts)
					end
					return run_opts
				end

				local items = {
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
					"tasks",
					"link",
					"fastrun",
				}
				if arglead and arglead ~= "" then
					return vim.tbl_filter(function(item)
						return item:find("^" .. vim.pesc(arglead)) ~= nil
					end, items)
				end
				return items
			end,
		})
	end,
})
