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

return M
