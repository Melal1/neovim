local M = {}

function M.find_include_dir(max_lvl)
	local current_dir = vim.fn.expand("%:p:h")

	-- Loop through the current directory and its parent directories up to max_lvl
	for _ = 1, max_lvl do
		-- Construct the potential path to the 'include' directory within current_dir
		local potential_include_path = current_dir .. "/include"

		-- Use vim.uv.fs_stat to asynchronously check if the path exists and is a directory.
		-- vim.uv provides efficient file system checks via Neovim's built-in libuv bindings.
		local stat = vim.uv.fs_stat(potential_include_path)

		-- If 'stat' is not nil (path exists) and its type is 'directory', we found it!
		if stat and stat.type == "directory" then
			return potential_include_path -- Return the full path to the 'include' directory
		end

		-- If not found, move up to the parent directory for the next iteration.
		-- vim.fn.fnamemodify(path, ":h") extracts the parent directory (head) of a path.
		local parent_dir = vim.fn.fnamemodify(current_dir, ":h")

		-- If the parent directory is the same as the current directory, it means
		-- we've reached the root of the filesystem or an invalid path, so stop searching.
		if parent_dir == current_dir then
			break
		end

		current_dir = parent_dir -- Update current_dir to the parent for the next loop
	end

	return nil -- Return nil if no 'include' directory was found within the specified levels
end

--- @param lvl number The maximum level to search for both 'include' directories and
---                  potential 'compile_flags.txt' creation locations.
function M.createCompFlags(lvl)
	local current_search_path = vim.fn.expand("%:p:h")
	local options = { current_search_path }

	for _ = 2, lvl do
		current_search_path = vim.fn.fnamemodify(current_search_path, ":h")

		local compile_flags_file = current_search_path .. "/compile_flags.txt"
		local stat = vim.uv.fs_stat(compile_flags_file)

		if stat and stat.type == "file" then
			vim.notify(
				"Existing compile_flags.txt found at " .. compile_flags_file .. ", skipping this option.",
				vim.log.levels.WARN
			)
		else
			table.insert(options, current_search_path)
		end
	end

	vim.ui.select(options, { prompt = "Select the directory to create compile_flags.txt in: " }, function(selected_path)
		if not selected_path then
			vim.notify("No option selected, operation cancelled.")
			return
		end

		local include_dir = M.find_include_dir(lvl)

		if not include_dir then
			vim.notify(
				"Could not find an 'include' directory within " .. lvl .. " levels up from current file.",
				vim.log.levels.WARN
			)
			return
		end

		local compile_flags_file_path = selected_path .. "/compile_flags.txt"
		local content = "-I" .. include_dir

		local file = io.open(compile_flags_file_path, "w")
		if file then
			file:write(content)
			file:close()
			vim.notify(
				"Successfully created " .. compile_flags_file_path .. " with content: " .. content,
				vim.log.levels.INFO
			)
		else
			vim.notify(
				"Failed to create compile_flags.txt in " .. selected_path .. ". Check permissions.",
				vim.log.levels.ERROR
			)
		end
	end)
end

function M.compileAndDebug()
	local filePath = vim.fn.expand("%:p")
	local noExt = vim.fn.fnamemodify(filePath, ":r")
	local ft = vim.fn.expand("%:e")

	local ftAct = {
		cpp = function()
			local cmd = 'g++ "' .. filePath .. '" -o "' .. noExt .. '" -g'
			local include = M.find_include_dir(4)
			if include then
				cmd = cmd .. " -I" .. include
			end
			local compile_output = vim.fn.system(cmd)
			if vim.v.shell_error ~= 0 then
				print("Compilation failed:\n" .. compile_output)
				return false
			end
			return true
		end,
	}

	local db = {
		cpp = function()
			if os.getenv("TMUX") then
				local cmd = 'gdbserver --no-startup-with-shell :1234 "' .. noExt .. '"'
				vim.fn.system("tmux split-window -h -l 30 " .. cmd)
			else
				print("To have a console make sure you are on tmux")
			end
		end,
	}

	if ftAct[ft] then
		local compiled = ftAct[ft]()
		if compiled then
			db[ft]()
		end
	else
		print("File type '" .. ft .. "' is not supported")
		return
	end

	return noExt
end
return M
