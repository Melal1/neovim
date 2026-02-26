vim.api.nvim_create_autocmd("FileType", {
	pattern = "cpp",
	callback = function()
		local cmake = require("cmake-tools")
		if cmake.is_cmake_project() then
			vim.keymap.set("n", "<leader>rf", function()
				vim.cmd(":cd %:p:h")
				local path = cmake.get_launch_target_path()
				if path then
					require("config.utils.toggleTerm").SingleShot(path)
				else
					cmake.select_launch_target({}, function(res)
						if res:is_ok() then
							require("config.utils.toggleTerm").SingleShot(cmake.get_launch_target_path())
						else
							vim.notify("Unde")
						end
					end)
				end
			end)
			vim.keymap.set("n", "<leader>rb", function()
				vim.cmd(":cd %:p:h")
				vim.cmd("CMakeBuild")
			end)
			vim.keymap.set("n", "<leader>rF", function()
				vim.cmd(":cd %:p:h")
				cmake.build({}, function(results)
					if results:is_ok() then
						local path = cmake.get_launch_target_path()
						if path then
							require("config.utils.toggleTerm").SingleShot(path)
						else
							cmake.select_launch_target({}, function(res)
								if res:is_ok() then
									require("config.utils.toggleTerm").SingleShot(cmake.get_launch_target_path())
								else
									vim.notify("Unde")
								end
							end)
						end
					else
						vim.notify("Can not run the target : build has erros")
					end
				end)
			end)
		else
			vim.keymap.set("n", "<leader>rm", "<cmd>Make add<CR>", { desc = "Add file to Makefile" })
			vim.keymap.set("n", "<leader>RF", "<cmd>Make fastrun<CR>")
			vim.keymap.set("n", "<leader>rf", "<cmd>Make run split<CR>")
			vim.keymap.set("n", "<leader>rF", "<cmd>Make runb split<CR>")
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
			--
		end
	end,
})
