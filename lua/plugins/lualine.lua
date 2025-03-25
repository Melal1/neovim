return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({

			options = {
				theme = "auto",
				component_separators = "",
				section_separators = "",
				globalstatus = true,
			},

			sections = {
				lualine_a = { { "mode", icon = "" } },
				lualine_b = { { "branch", icon = "" } },
				lualine_c = {
					{

						"filename",
						file_status = true,
						newfile_status = false,
						path = 0,

						symbols = {
							modified = "[+]",
							readonly = "[!]",
							unnamed = "[󰕎]",
							newfile = "[New]",
						},
					},
				},
				lualine_x = {
					-- function()
					-- 	local encoding = vim.o.fileencoding
					-- 	if encoding == "" then
					-- 		return vim.bo.fileformat .. " :: " .. vim.bo.filetype
					-- 	else
					-- 		return encoding .. " :: " .. vim.bo.fileformat .. " :: " .. vim.bo.filetype
					-- 	end
					-- end,
					{
						"filetype",
						icon = { align = "right" },
					},
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
