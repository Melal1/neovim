-- I am noobie with lua so this is only expermintal
local M = {}

function M.read_current_theme()
	local theme_file = vim.fn.expand("~/.config/settings/current_theme.txt")
	local file = io.open(theme_file, "r")

	if not file then
		vim.notify("Could not open theme file: " .. theme_file, vim.log.levels.ERROR)
		return nil
	end

	local theme = file:read("*l")
	file:close()

	if not theme or theme == "" then
		vim.notify("Theme file is empty or invalid.", vim.log.levels.WARN)
		return nil
	end

	return theme
end

function M.apply_theme()
	local theme = M.read_current_theme()

	if theme then
		return theme
	else
		vim.notify("Failed to apply theme. Using default.", vim.log.levels.ERROR)
		return "default"
	end
end

function M.set_theme(theme)
	local theme_file = vim.fn.expand("~/.config/settings/current_theme.txt")
	local file = io.open(theme_file, "w")

	if not file then
		vim.notify("Could not open theme file: " .. theme_file, vim.log.levels.ERROR)
		return
	end

	file:write(theme)
	file:close()

	M.apply_theme()
end

function M.float_win_config()
	local width = math.min(math.floor(vim.o.columns * 0.8), 64)
	local height = math.floor(vim.o.lines * 0.8)

	return {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		border = "single",
	}
end

function M.find_git_root()
	local current_dir = vim.fn.getcwd()
	while current_dir ~= "/" do
		local git_dir = current_dir .. "/.git"
		if vim.fn.isdirectory(git_dir) == 1 then
			return current_dir
		end
		current_dir = vim.fn.fnamemodify(current_dir, ":h")
	end
	return nil
end

function M.ensure_todo_file_exists()
	local git_root = M.find_git_root()
	if not git_root then
		vim.notify("Not inside a Git repository", vim.log.levels.WARN)
		return nil
	end

	local todo_path = git_root .. "/todo.md"
	if vim.fn.filereadable(todo_path) == 0 then
		local file = io.open(todo_path, "w")
		if file then
			file:close()
			vim.notify("Created todo.md in Git root: " .. todo_path, vim.log.levels.INFO)
		else
			vim.notify("Failed to create todo.md in Git root: " .. todo_path, vim.log.levels.ERROR)
			return nil
		end
	end

	return todo_path
end

function M.open_floating_todo()
	local todo_path = M.ensure_todo_file_exists()
	if not todo_path then
		vim.notify("No todo.md file found or created.", vim.log.levels.ERROR)
		return
	end

	local buf = vim.fn.bufnr(todo_path, true)

	if buf == -1 then
		buf = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_set_name(buf, todo_path)
		vim.api.nvim_buf_call(buf, function()
			vim.cmd("edit " .. vim.fn.fnameescape(todo_path))
		end)
	end

	local win = vim.api.nvim_open_win(buf, true, M.float_win_config())
	vim.cmd("setlocal nospell")

	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		noremap = true,
		silent = true,
		callback = function()
			if vim.api.nvim_get_option_value("modified", { buf = buf }) then
				vim.notify("Save your changes before closing!", vim.log.levels.WARN)
			else
				vim.api.nvim_win_close(0, true)
			end
		end,
	})

	vim.api.nvim_create_autocmd("VimResized", {
		callback = function()
			vim.api.nvim_win_set_config(win, M.float_win_config())
		end,
		once = false,
	})
end

local toggles = {
	["1"] = "0",
	["0"] = "1",
	["true"] = "false",
	["false"] = "true",
	["on"] = "off",
	["off"] = "on",
	["yes"] = "no",
	["no"] = "yes",
	["enable"] = "disable",
	["disable"] = "enable",
	["enabled"] = "disabled",
	["disabled"] = "enabled",
	["&&"] = "||",
	["||"] = "&&",
	[">>"] = "<<",
	["<<"] = ">>",
	["++"] = "--",
	["--"] = "++",
	["=="] = "!=",
	["!="] = "==",
}

local variants = {
	["true"] = "1",
	["1"] = "true",
	["false"] = "0",
	["0"] = "false",
	["yes"] = "1",
	["no"] = "0",
	["enable"] = "1",
	["disable"] = "0",
}

local function lookup(word, mode)
	word = word:lower()
	if mode then
		return toggles[word]
	else
		return variants[word]
	end
end

function M.toggleBool(mode)
	local word = vim.fn.expand("<cWORD>")
	local replacement = lookup(word, mode)
	if not replacement then
		word = vim.fn.expand("<cword>")
		replacement = lookup(word, mode)
	end

	if replacement then
		vim.cmd("normal! ciw" .. replacement)
	else
		print("No toggle or variant available for '" .. word .. "' :) ")
	end
end

function M.find_include_dir(max_lvl)
	local current_dir = vim.fn.expand("%:p:h")

	-- Loop through the current directory and its parent directories up to max_lvl
	for i = 1, max_lvl do
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

	for i = 2, lvl do
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
				cmd = cmd .." -I".. include
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
