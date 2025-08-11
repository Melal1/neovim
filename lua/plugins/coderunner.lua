local choice = ""

return {
	"CRAG666/code_runner.nvim",
	keys = {
		{
			"<leader>rF",
			function()
				local filetype = vim.bo.filetype
				if filetype ~= "cpp" then
					vim.cmd("write")
					vim.cmd("RunFile")
					return
				end

				local options = {
					"Empty",
					"-lncurses",
				}
				vim.ui.select(options, { prompt = "Compile with ?" }, function(selected)
					if not selected or selected == "Empty" then
						choice = ""
					else
						choice = selected
					end
					vim.cmd("write")
					vim.cmd("RunFile")
				end)
			end,
		},
		{
			"<leader>rf",
			"<cmd>RunFile<CR>",
		},
		{
			"<leader>rc",
			"<cmd>RunClose<CR>",
		},
	},

	config = function()
		require("telescope")
		require("code_runner").setup({
			startinsert = true,
			filetype = {
				cpp = function()
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


					return vim.list_extend(cpp_base, cpp_exec)
				end,
			},
		})
	end,
}
