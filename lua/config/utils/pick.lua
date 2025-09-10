-- file_picker.lua
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

function M.pick_files(files, callback)
  if not M.available then
    if callback then callback({}) end
    return
  end

  if type(files) ~= "table" or #files == 0 then
    if callback then callback({}) end
    return
  end

  pickers.new(themes.get_dropdown({ initial_mode = "normal" }), {
    prompt_title = "Select files (multi-select with <Tab>)",
    finder = finders.new_table({ results = files }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      map("n", "<Tab>", actions.toggle_selection)
      map("i", "<Tab>", actions.toggle_selection)

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
    end
  }):find()
end

return M

