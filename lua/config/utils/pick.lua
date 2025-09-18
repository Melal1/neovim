local M = {}
local has_telescope, pickers = pcall(require, "telescope.pickers")
if not has_telescope then
	M.available = false
	return M
end
M.available = true
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local themes = require("telescope.themes")

function M.pick_files(files, callback, opts)
	opts = opts or {}

	if not M.available then
		if callback then
			callback({})
		end
		return
	end

	if type(files) ~= "table" or #files == 0 then
		if callback then
			callback({})
		end
		return
	end

	local prompt_title = opts.prompt_title or "Select files (<Tab> multi-select, <C-a> toggle all)"

	local function toggle_all(prompt_bufnr)
		local picker = action_state.get_current_picker(prompt_bufnr)
		local num_results = picker.manager:num_results()
		local selections = picker:get_multi_selection()
		local all_selected = #selections == num_results
		for i = 0, num_results - 1 do
			if all_selected then
				picker:remove_selection(i)
			else
				picker:add_selection(i)
			end
		end
	end

	pickers
		.new(themes.get_dropdown({ initial_mode = "normal" }), {
			prompt_title = prompt_title,
			finder = finders.new_table({ results = files }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				map("n", "<Tab>", actions.toggle_selection)
				map("i", "<Tab>", actions.toggle_selection)

				map("n", "<C-a>", toggle_all)
				map("i", "<C-a>", toggle_all)

				actions.select_default:replace(function()
					local picker = action_state.get_current_picker(prompt_bufnr)
					local selections = picker:get_multi_selection()
					actions.close(prompt_bufnr)
					local result = {}
					for _, f in ipairs(selections) do
						table.insert(result, f.value)
					end
					if callback then
						callback(result)
					end
				end)
				return true
			end,
		})
		:find()
end

return M
