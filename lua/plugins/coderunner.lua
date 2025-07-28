return {
	"CRAG666/code_runner.nvim",
	keys = {
		{
			"<leader>rf",
			"<cmd>w | RunFile<CR>",
		},
		{
			"<leader>rc",
			"<cmd>RunClose<CR>",
		},
		{
			"<leader>rt",
			"<cmd>w | RunFile tab<CR>",
		},
	},

	config = function()
    require("telescope")
		require("code_runner").setup({
            startinsert = true,
			filetype = {
				cpp = function(...)
					local options = {
            "Empty",
            "-lncurses"
					}

					vim.ui.select(options, { prompt = "Compile with ?" }, function(choice)
						if not choice or choice == "Empty" then
							choice = ""
						end

						local cpp_base = {
							"cd $dir &&",
							"g++ $fileName -o",
							"/tmp/$fileNameWithoutExt",
							choice,
						}

						local cpp_exec = {
							"&& /tmp/$fileNameWithoutExt &&",
							"rm /tmp/$fileNameWithoutExt",
						}

						require("code_runner.commands").run_from_fn(vim.list_extend(cpp_base, cpp_exec))
					end)
				end,
			},
		})
	end,
}
