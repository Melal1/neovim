return {
	"echasnovski/mini.files",
	version = false,
	lazy = false,
	config = function()
		local MiniFiles = require("mini.files")
		MiniFiles.setup({})

		vim.keymap.set("n", "-", function()
			if not MiniFiles.close() then
				MiniFiles.open()
			end
		end, { desc = "Toggle mini files" })

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local buf_id = args.data.buf_id

				-- Set WD to parent
				vim.keymap.set("n", "g1", function()
					local path = (MiniFiles.get_fs_entry() or {}).path -- If MiniFiles.get_fs_entry returnd nill then it will return {} instead so .path won't fail
					if path == nil then
						return vim.notify("Cursor is not on valid entry")
					end
					vim.fn.chdir(vim.fs.dirname(path))
				end, { buffer = buf_id, desc = "Set cwd" })

				-- Yank full path
				vim.keymap.set("n", "gy", function()
					local path = (MiniFiles.get_fs_entry() or {}).path
					if path == nil then
						return vim.notify("Cursor is not on valid entry")
					end
					vim.fn.setreg(vim.v.register, path)
					vim.fn.setreg("+", path)
				end)

				-- set WD to under Cursor
				vim.keymap.set("n", "g2", function()
					local path = (MiniFiles.get_fs_entry() or {}).path
					if path then
						if vim.fn.isdirectory(path) ~= 0 then -- on lua anything but nil and false is true
							vim.fn.chdir(path)
						else
							vim.fn.chdir(vim.fs.dirname(path))
						end
					end
				end, { buffer = buf_id })
				vim.keymap.set("n", "<Tab>", function()
					MiniFiles.close()
				end,{buffer = buf_id})
			end,
		})
	end,
}
