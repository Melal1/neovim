local state = {
	split = {
		buf = -1,
		win = -1,
	},
}

local function create_split_terminal(opts)
	opts = opts or {}
	local height = opts.height or math.floor(vim.o.lines * 0.2)

	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	vim.cmd("belowright " .. height .. "split")
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)

	return { buf = buf, win = win }
end

local M = {}
function M.toggle()
	if not vim.api.nvim_win_is_valid(state.split.win) then
		state.split = create_split_terminal({ buf = state.split.buf })
		if vim.bo[state.split.buf].buftype ~= "terminal" then
			vim.cmd.terminal()
		end
	else
		vim.api.nvim_win_hide(state.split.win)
	end
end
function M.kill()
	if vim.api.nvim_win_is_valid(state.split.win) then
		vim.api.nvim_win_close(state.split.win, true)
	end
	if vim.api.nvim_buf_is_valid(state.split.buf) then
		vim.api.nvim_buf_delete(state.split.buf, { force = true })
	end
	state.split.buf = -1
	state.split.win = -1
end
return M
