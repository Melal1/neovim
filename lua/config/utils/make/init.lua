---@class MakeModule
---@field Config table
local M = {}

local Config = require("config.utils.make.config")
local Utils = require("config.utils.make.utils")
local Parser = require("config.utils.make.parser")
local Generator = require("config.utils.make.generator")
local RootFinder = require("config.utils.make.finder")

M.Config = Config.DefaultConfig

---@param UserConfig table|nil
function M.Setup(UserConfig)
	M.Config = vim.tbl_deep_extend("force", M.Config, UserConfig or {})
	if M.Config.CacheUseHash ~= nil then
		Parser.CacheUseHash = M.Config.CacheUseHash
	end
end

local function get_picker_or_warn(message)
	local picker = require("config.utils.pick")
	if not picker.available then
		Utils.Notify(message or "Telescope is required for selection.", vim.log.levels.ERROR)
		return nil
	end
	return picker
end

local function get_relative_or_warn(file_path, root_path)
	local relative_path, ok = Utils.GetRelativePath(file_path, root_path)
	if not ok then
		Utils.Notify(relative_path)
		return nil
	end
	return relative_path
end

local function get_sections_by_types(content, types)
	local result = {}
	for _, section in ipairs(Parser.AnalyzeAllSections(content)) do
		if types[section.analysis.type] then
			table.insert(result, section)
		end
	end
	return result
end

local function find_section_by_path(sections, relative_path)
	for _, section in ipairs(sections) do
		if section.path == relative_path then
			return section
		end
	end
	return nil
end

local function target_type_label(target_name)
	if target_name:match("%.o$") then
		return "(obj)"
	elseif target_name:match("^run") then
		return "(run)"
	end
	return "(exe)"
end

local function normalize_link_flags(flags)
	local result = {}
	local seen = {}
	for _, flag in ipairs(flags or {}) do
		if flag and flag ~= "" and not seen[flag] then
			seen[flag] = true
			table.insert(result, flag)
		end
	end
	return result
end

local function merge_link_flags(existing, incoming, action)
	local current = normalize_link_flags(existing)
	local updates = normalize_link_flags(incoming)

	if action == "remove" then
		local remove_map = {}
		for _, flag in ipairs(updates) do
			remove_map[flag] = true
		end
		local result = {}
		for _, flag in ipairs(current) do
			if not remove_map[flag] then
				table.insert(result, flag)
			end
		end
		return result
	end

	local seen = {}
	for _, flag in ipairs(current) do
		seen[flag] = true
	end
	for _, flag in ipairs(updates) do
		if not seen[flag] then
			table.insert(current, flag)
			seen[flag] = true
		end
	end
	return current
end

local function parse_links_block(content)
	local groups = {}
	local group_map = {}
	local individuals = {}
	local individual_map = {}

	if not content or content == "" then
		return groups, individuals
	end

	local in_block = false
	for _, line in ipairs(vim.split(content, "\n", { plain = true })) do
		if line:match("^%s*#%s*links_start") then
			in_block = true
			goto continue
		end
		if line:match("^%s*#%s*links_end") then
			break
		end
		if not in_block then
			goto continue
		end

		local group_name, rest = line:match("^%s*#%s*group:%s*(%S+)%s*(.*)$")
		if group_name then
			local flags = {}
			for flag in (rest or ""):gmatch("%S+") do
				table.insert(flags, flag)
			end
			flags = normalize_link_flags(flags)
			if #flags > 0 then
				local group = group_map[group_name]
				if not group then
					group = { name = group_name, flags = {} }
					group_map[group_name] = group
					table.insert(groups, group)
				end
				group.flags = normalize_link_flags(vim.list_extend(group.flags, flags))
			end
			goto continue
		end

		local link_rest = line:match("^%s*#%s*link:%s*(.*)$")
		if link_rest then
			for flag in link_rest:gmatch("%S+") do
				if not individual_map[flag] then
					individual_map[flag] = true
					table.insert(individuals, flag)
				end
			end
		end

		::continue::
	end
	local group_flag_map = {}
	for _, group in ipairs(groups) do
		for _, flag in ipairs(group.flags) do
			group_flag_map[flag] = true
		end
	end

	local filtered_individuals = {}
	for _, flag in ipairs(individuals) do
		if not group_flag_map[flag] then
			table.insert(filtered_individuals, flag)
		end
	end

	return groups, filtered_individuals
end

local function has_link_options(content)
	local groups, individuals = parse_links_block(content or "")
	return #groups > 0 or #individuals > 0
end

local function build_links_block(groups, individuals)
	local lines = { "# links_start" }

	for _, group in ipairs(groups or {}) do
		local name = group.name and vim.trim(group.name) or ""
		local flags = normalize_link_flags(group.flags or {})
		if name ~= "" and #flags > 0 then
			table.insert(lines, "# group: " .. name .. " " .. table.concat(flags, " "))
		end
	end

	for _, flag in ipairs(normalize_link_flags(individuals or {})) do
		table.insert(lines, "# link: " .. flag)
	end

	table.insert(lines, "# links_end")
	return lines
end

local function apply_links_block(content, groups, individuals)
	local lines = vim.split(content or "", "\n", { plain = true })
	local start_idx, end_idx = nil, nil

	for i, line in ipairs(lines) do
		if not start_idx and line:match("^%s*#%s*links_start") then
			start_idx = i
		elseif start_idx and line:match("^%s*#%s*links_end") then
			end_idx = i
			break
		end
	end

	local has_links = #groups > 0 or #individuals > 0
	if not has_links then
		if not start_idx then
			return content or ""
		end
		local cleaned = {}
		for i = 1, start_idx - 1 do
			table.insert(cleaned, lines[i])
		end
		for i = (end_idx or start_idx) + 1, #lines do
			table.insert(cleaned, lines[i])
		end
		return table.concat(cleaned, "\n")
	end

	local block_lines = build_links_block(groups, individuals)
	local new_lines = {}
	if start_idx then
		for i = 1, start_idx - 1 do
			table.insert(new_lines, lines[i])
		end
		vim.list_extend(new_lines, block_lines)
		for i = (end_idx or start_idx) + 1, #lines do
			table.insert(new_lines, lines[i])
		end
	else
		vim.list_extend(new_lines, block_lines)
		if #lines > 0 then
			table.insert(new_lines, "")
			vim.list_extend(new_lines, lines)
		end
	end

	return table.concat(new_lines, "\n")
end

local function load_link_options(makefile_path, fallback_content)
	local content = fallback_content
	if makefile_path and vim.loop.fs_stat(makefile_path) then
		content, _ = Utils.ReadFile(makefile_path)
	end
	content = content or ""
	local groups, individuals = parse_links_block(content)
	return content, groups, individuals
end

local function save_link_options(makefile_path, content, groups, individuals)
	local new_content = apply_links_block(content or "", groups or {}, individuals or {})
	local ok, err = Utils.WriteFile(makefile_path, new_content)
	if not ok then
		return false, err
	end
	return true, new_content
end

local function build_link_entries(makefile_content)
	local groups, individuals = parse_links_block(makefile_content)
	local entries = {}
	local flags_by_value = {}
	local all_flags = {}

	for _, group in ipairs(groups) do
		local value = "group:" .. group.name
		table.insert(entries, { value = value, display = "Group: " .. group.name })
		flags_by_value[value] = group.flags
		vim.list_extend(all_flags, group.flags)
	end

	for _, flag in ipairs(individuals) do
		local value = "link:" .. flag
		table.insert(entries, { value = value, display = flag })
		flags_by_value[value] = { flag }
		table.insert(all_flags, flag)
	end

	if #entries > 0 then
		table.insert(entries, 1, { value = "__ALL__", display = "All" })
		flags_by_value["__ALL__"] = all_flags
	end

	return entries, flags_by_value, normalize_link_flags(all_flags)
end

local function confirm_action(message)
	return vim.fn.confirm(message, "&Yes\n&No", 2) == 1
end

local function normalize_link_input(flag)
	flag = vim.trim(flag or "")
	if flag == "" then
		return nil
	end
	if flag:sub(1, 1) ~= "-" then
		return "-" .. flag
	end
	return flag
end

local function parse_links_input(prompt)
	local input = vim.fn.input(prompt)
	if not input or input:match("^%s*$") then
		return {}
	end
	local flags = {}
	for flag in input:gmatch("%S+") do
		local normalized = normalize_link_input(flag)
		if normalized then
			table.insert(flags, normalized)
		end
	end
	return normalize_link_flags(flags)
end

local function format_link_options(groups, individuals)
	local lines = {}
	table.insert(lines, "Groups:")
	if #groups == 0 then
		table.insert(lines, "  (none)")
	else
		for _, group in ipairs(groups) do
			table.insert(lines, "  " .. group.name)
			for _, flag in ipairs(group.flags) do
				table.insert(lines, "    - " .. flag)
			end
		end
	end
	table.insert(lines, "")
	table.insert(lines, "Individuals:")
	if #individuals == 0 then
		table.insert(lines, "  (none)")
	else
		for _, flag in ipairs(individuals) do
			table.insert(lines, "  - " .. flag)
		end
	end
	return lines
end

local function build_preselected_link_values(entries, flags_by_value, existing_flags)
	local existing_map = {}
	for _, flag in ipairs(existing_flags or {}) do
		existing_map[flag] = true
	end

	local preselected = {}
	for _, entry in ipairs(entries) do
		if entry.value ~= "__ALL__" then
			local flags = flags_by_value[entry.value] or {}
			local all_present = #flags > 0
			for _, flag in ipairs(flags) do
				if not existing_map[flag] then
					all_present = false
					break
				end
			end
			if all_present then
				table.insert(preselected, entry.value)
			end
		end
	end

	return preselected
end

local function select_links(existing_flags, makefile_content, callback, opts)
	opts = opts or {}
	local entries, flags_by_value, all_flags = build_link_entries(makefile_content or "")
	if #entries == 0 then
		callback(existing_flags or {})
		return true
	end

	local picker = get_picker_or_warn("Telescope is required for link selection")
	if not picker then
		return false
	end

	local preselected_items = {}
	if opts.preselect ~= false then
		preselected_items = build_preselected_link_values(entries, flags_by_value, existing_flags or {})
	end

	picker.pick_checklist(entries, function(selected_values)
		selected_values = selected_values or {}
		local use_all = false
		for _, value in ipairs(selected_values) do
			if value == "__ALL__" then
				use_all = true
				break
			end
		end

		local flags = {}
		if use_all then
			flags = all_flags
		else
			for _, value in ipairs(selected_values) do
				for _, flag in ipairs(flags_by_value[value] or {}) do
					table.insert(flags, flag)
				end
			end
		end

		callback(normalize_link_flags(flags))
	end, { prompt_title = opts.prompt_title or "Select link flags", preselected_items = preselected_items })
	return true
end

local function get_existing_links(content, relative_path, base_name)
	local section_content = Parser.ReadContentBetweenMarkers(content, relative_path)
	if type(section_content) == "table" then
		section_content = table.concat(section_content, "\n")
	end
	if not section_content or section_content == "" then
		return {}
	end

	local target_name = Parser.FindExecutableTargetName(section_content, base_name)
	if not target_name then
		return {}
	end

	return Parser.GetLinksForTarget(section_content, target_name)
end

local function normalize_build_mode(mode)
	if not mode or mode == "" then
		return nil
	end
	local normalized = mode:lower()
	if normalized == "debug" or normalized == "release" then
		return normalized
	end
	return nil
end

local function update_makefile_var(lines, var_name, value)
	for i, line in ipairs(lines) do
		local name, op = line:match("^%s*([%w_]+)%s*(:?=)")
		if name == var_name then
			local prefix = line:match("^(%s*)") or ""
			lines[i] = string.format("%s%s %s %s", prefix, var_name, op or "=", value)
			return true
		end
	end
	return false
end

local function insert_makefile_var(lines, var_name, value)
	local insert_at = 1
	for i, line in ipairs(lines) do
		if line:match("^%s*%w[%w_]*%s*:?=") or line:match("^%s*$") then
			insert_at = i + 1
		else
			break
		end
	end
	table.insert(lines, insert_at, string.format("%s = %s", var_name, value))
end

local function detect_build_mode(vars)
	local cxxflags = vars.CXXFLAGS or ""
	if cxxflags:match("RELEASEFLAGS") then
		return "release"
	end
	if cxxflags:match("DEBUGFLAGS") then
		return "debug"
	end
	return nil
end

function M.SetBuildMode(MakefilePath, Content, Mode)
	local normalized = normalize_build_mode(Mode)
	if not normalized then
		Utils.Notify("Usage: Make mode [debug|release].", vim.log.levels.WARN)
		return false
	end

	local value = normalized == "release" and "$(RELEASEFLAGS)" or "$(DEBUGFLAGS)"
	local lines = vim.split(Content or "", "\n", { plain = true })
	if not update_makefile_var(lines, "CXXFLAGS", value) then
		insert_makefile_var(lines, "CXXFLAGS", value)
	end

	local new_content = table.concat(lines, "\n")
	local ok, err = Utils.WriteFile(MakefilePath, new_content)
	if not ok then
		Utils.Notify("Failed to update build mode: " .. (err or "unknown error"), vim.log.levels.ERROR)
		return false
	end

	Utils.Notify("Build mode set to " .. normalized .. ".", vim.log.levels.INFO)
	return true
end

local function update_section_links(section_lines, target_name, links)
	local link_line_index = nil
	local target_line_index = nil
	local target_pattern = "^%s*" .. Utils.EscapePattern(target_name) .. "%s*:"
	local links_pattern = "^%s*" .. Utils.EscapePattern(target_name) .. "%s*:%s*LINKS%s*[%+:%?]?="

	for i, line in ipairs(section_lines) do
		local trimmed = line:match("^%s*(.-)%s*$")
		if not link_line_index and trimmed:match(links_pattern) then
			link_line_index = i
		elseif not target_line_index and trimmed:match(target_pattern) then
			target_line_index = i
		end
	end

	local new_lines = vim.list_extend({}, section_lines)
	if #links == 0 then
		if link_line_index then
			table.remove(new_lines, link_line_index)
		end
		return new_lines
	end

	local new_line = target_name .. ": LINKS += " .. table.concat(links, " ")
	if link_line_index then
		new_lines[link_line_index] = new_line
	else
		local insert_at = target_line_index or (#new_lines + 1)
		table.insert(new_lines, insert_at, new_line)
	end

	return new_lines
end

local function update_links_for_entry(content, relative_path, base_name, new_links)
	local marker_info = Parser.FindMarker(content, relative_path, true, true)
	if not marker_info.M_start or not marker_info.M_end then
		Utils.Notify("Markers not found for: " .. relative_path, vim.log.levels.ERROR)
		return nil
	end

	local lines = vim.split(content, "\n", { plain = true })
	local section_lines = {}
	for i = marker_info.M_start + 1, marker_info.M_end - 1 do
		table.insert(section_lines, lines[i])
	end

	local section_content = table.concat(section_lines, "\n")
	local target_name = Parser.FindExecutableTargetName(section_content, base_name)
	if not target_name then
		Utils.Notify("Executable target not found for: " .. relative_path, vim.log.levels.ERROR)
		return nil
	end

	local updated_section_lines = update_section_links(section_lines, target_name, normalize_link_flags(new_links))
	local new_lines = {}
	for i = 1, marker_info.M_start do
		table.insert(new_lines, lines[i])
	end
	vim.list_extend(new_lines, updated_section_lines)
	for i = marker_info.M_end, #lines do
		table.insert(new_lines, lines[i])
	end

	return table.concat(new_lines, "\n")
end

local function manage_link_options_add(picker, makefile_path, makefile_content)
	local menu_items = {
		{ value = "group", display = "Link Group" },
		{ value = "individual", display = "Individual Link(s)" },
	}

	picker.pick_menu(menu_items, function(selection)
		if not selection or selection == "" then
			return
		end

		local content, groups, individuals = load_link_options(makefile_path, makefile_content)
		if selection == "group" then
			local group_name = vim.trim(vim.fn.input("Group name: "))
			if group_name == "" then
				Utils.Notify("Group name cannot be empty", vim.log.levels.WARN)
				return
			end
			for _, group in ipairs(groups) do
				if group.name == group_name then
					Utils.Notify("Group already exists: " .. group_name, vim.log.levels.WARN)
					return
				end
			end

			local flags = parse_links_input("Enter links for group (space-separated): ")
			if #flags == 0 then
				Utils.Notify("No links provided", vim.log.levels.WARN)
				return
			end

			if not confirm_action("Save group '" .. group_name .. "' with " .. #flags .. " link(s)?") then
				return
			end

			table.insert(groups, { name = group_name, flags = flags })
			local ok, err = save_link_options(makefile_path, content, groups, individuals)
			if not ok then
				Utils.Notify("Failed to save links: " .. (err or "unknown error"), vim.log.levels.ERROR)
				return
			end
			Utils.Notify("Added group: " .. group_name, vim.log.levels.INFO)
			return
		end

		local group_flags = {}
		for _, group in ipairs(groups) do
			for _, flag in ipairs(group.flags) do
				group_flags[flag] = true
			end
		end

		local flags = parse_links_input("Enter individual links (space-separated): ")
		if #flags == 0 then
			Utils.Notify("No links provided", vim.log.levels.WARN)
			return
		end

		local filtered = {}
		for _, flag in ipairs(flags) do
			if group_flags[flag] then
				Utils.Notify("Skipping grouped link: " .. flag, vim.log.levels.WARN)
			else
				table.insert(filtered, flag)
			end
		end
		filtered = normalize_link_flags(filtered)
		if #filtered == 0 then
			Utils.Notify("No new individual links to add", vim.log.levels.WARN)
			return
		end

		if not confirm_action("Save " .. #filtered .. " individual link(s)?") then
			return
		end

		for _, flag in ipairs(filtered) do
			table.insert(individuals, flag)
		end
		local ok, err = save_link_options(makefile_path, content, groups, individuals)
		if not ok then
			Utils.Notify("Failed to save links: " .. (err or "unknown error"), vim.log.levels.ERROR)
			return
		end
		Utils.Notify("Added individual link(s)", vim.log.levels.INFO)
	end, { prompt_title = "Links: Add" })
end

local function manage_link_options_list(makefile_path, makefile_content)
	local _, groups, individuals = load_link_options(makefile_path, makefile_content)
	local lines = format_link_options(groups, individuals)
	Utils.Notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Links" })
end

local function manage_link_options_remove(picker, makefile_path, makefile_content)
	local menu_items = {
		{ value = "group", display = "Remove Group" },
		{ value = "individual", display = "Remove Individual Link(s)" },
	}

	picker.pick_menu(menu_items, function(selection)
		if not selection or selection == "" then
			return
		end

		local content, groups, individuals = load_link_options(makefile_path, makefile_content)
		if selection == "group" then
			if #groups == 0 then
				Utils.Notify("No groups to remove", vim.log.levels.WARN)
				return
			end

			local group_entries = {}
			local group_map = {}
			for _, group in ipairs(groups) do
				table.insert(group_entries, { value = group.name, display = group.name })
				group_map[group.name] = group
			end

			picker.pick_single(group_entries, function(selected_group)
				if not selected_group or selected_group == "" then
					return
				end

				local group = group_map[selected_group]
				if not group then
					return
				end

				local choice = vim.fn.confirm(
					"Remove entire group '" .. group.name .. "' or specific links?",
					"&Group\n&Links\n&Cancel",
					3
				)
				if choice == 1 then
					if not confirm_action("Confirm removal of group '" .. group.name .. "'?") then
						return
					end
					local updated = {}
					for _, entry in ipairs(groups) do
						if entry.name ~= group.name then
							table.insert(updated, entry)
						end
					end
					local ok, err = save_link_options(makefile_path, content, updated, individuals)
					if not ok then
						Utils.Notify("Failed to save links: " .. (err or "unknown error"), vim.log.levels.ERROR)
						return
					end
					Utils.Notify("Removed group: " .. group.name, vim.log.levels.INFO)
					return
				elseif choice ~= 2 then
					return
				end

				if #group.flags == 0 then
					Utils.Notify("Group has no links to remove", vim.log.levels.WARN)
					return
				end

				picker.pick_checklist(group.flags, function(selected_flags)
					selected_flags = normalize_link_flags(selected_flags or {})
					if #selected_flags == 0 then
						return
					end
					if not confirm_action("Remove " .. #selected_flags .. " link(s) from '" .. group.name .. "'?") then
						return
					end

					local remaining = {}
					local remove_map = {}
					for _, flag in ipairs(selected_flags) do
						remove_map[flag] = true
					end
					for _, flag in ipairs(group.flags) do
						if not remove_map[flag] then
							table.insert(remaining, flag)
						end
					end
					group.flags = remaining

					local updated = {}
					for _, entry in ipairs(groups) do
						if entry.name ~= group.name and #entry.flags > 0 then
							table.insert(updated, entry)
						elseif entry.name == group.name and #group.flags > 0 then
							table.insert(updated, group)
						end
					end
					if #group.flags == 0 then
						Utils.Notify("Group is now empty and will be removed", vim.log.levels.WARN)
					end
					local ok, err = save_link_options(makefile_path, content, updated, individuals)
					if not ok then
						Utils.Notify("Failed to save links: " .. (err or "unknown error"), vim.log.levels.ERROR)
						return
					end
					Utils.Notify("Updated group: " .. group.name, vim.log.levels.INFO)
				end, { prompt_title = "Remove links from " .. group.name })
			end, { prompt_title = "Select group" })
			return
		end

		if #individuals == 0 then
			Utils.Notify("No individual links to remove", vim.log.levels.WARN)
			return
		end

		picker.pick_checklist(individuals, function(selected_flags)
			selected_flags = normalize_link_flags(selected_flags or {})
			if #selected_flags == 0 then
				return
			end
			if not confirm_action("Remove " .. #selected_flags .. " individual link(s)?") then
				return
			end

			local remove_map = {}
			for _, flag in ipairs(selected_flags) do
				remove_map[flag] = true
			end
			local remaining = {}
			for _, flag in ipairs(individuals) do
				if not remove_map[flag] then
					table.insert(remaining, flag)
				end
			end
			local ok, err = save_link_options(makefile_path, content, groups, remaining)
			if not ok then
				Utils.Notify("Failed to save links: " .. (err or "unknown error"), vim.log.levels.ERROR)
				return
			end
			Utils.Notify("Removed selected individual links", vim.log.levels.INFO)
		end, { prompt_title = "Remove individual links" })
	end, { prompt_title = "Links: Remove" })
end

local function manage_link_options_edit(picker, makefile_path, makefile_content)
	local content, groups, individuals = load_link_options(makefile_path, makefile_content)
	if #groups == 0 then
		Utils.Notify("No groups to edit", vim.log.levels.WARN)
		return
	end

	local group_entries = {}
	local group_map = {}
	for _, group in ipairs(groups) do
		table.insert(group_entries, { value = group.name, display = group.name })
		group_map[group.name] = group
	end

	picker.pick_single(group_entries, function(selected_group)
		if not selected_group or selected_group == "" then
			return
		end

		local group = group_map[selected_group]
		if not group then
			return
		end

		local edit_actions = {
			{ value = "rename", display = "Rename group" },
			{ value = "add", display = "Add links to group" },
			{ value = "remove", display = "Remove links from group" },
			{ value = "replace", display = "Replace all links in group" },
		}

		picker.pick_menu(edit_actions, function(action)
			if not action or action == "" then
				return
			end

			if action == "rename" then
				local new_name = vim.trim(vim.fn.input("New group name: "))
				if new_name == "" then
					Utils.Notify("Group name cannot be empty", vim.log.levels.WARN)
					return
				end
				for _, entry in ipairs(groups) do
					if entry.name == new_name then
						Utils.Notify("Group already exists: " .. new_name, vim.log.levels.WARN)
						return
					end
				end
				if not confirm_action("Rename group '" .. group.name .. "' to '" .. new_name .. "'?") then
					return
				end
				group.name = new_name
				local ok, err = save_link_options(makefile_path, content, groups, individuals)
				if not ok then
					Utils.Notify("Failed to save links: " .. (err or "unknown error"), vim.log.levels.ERROR)
					return
				end
				Utils.Notify("Renamed group to: " .. new_name, vim.log.levels.INFO)
				return
			end

			if action == "add" then
				local flags = parse_links_input("Enter links to add (space-separated): ")
				if #flags == 0 then
					Utils.Notify("No links provided", vim.log.levels.WARN)
					return
				end
				group.flags = merge_link_flags(group.flags, flags, "add")
				if not confirm_action("Add " .. #flags .. " link(s) to '" .. group.name .. "'?") then
					return
				end
				local ok, err = save_link_options(makefile_path, content, groups, individuals)
				if not ok then
					Utils.Notify("Failed to save links: " .. (err or "unknown error"), vim.log.levels.ERROR)
					return
				end
				Utils.Notify("Updated group: " .. group.name, vim.log.levels.INFO)
				return
			end

			if action == "remove" then
				if #group.flags == 0 then
					Utils.Notify("Group has no links to remove", vim.log.levels.WARN)
					return
				end
				picker.pick_checklist(group.flags, function(selected_flags)
					selected_flags = normalize_link_flags(selected_flags or {})
					if #selected_flags == 0 then
						return
					end
					if not confirm_action("Remove " .. #selected_flags .. " link(s) from '" .. group.name .. "'?") then
						return
					end
					group.flags = merge_link_flags(group.flags, selected_flags, "remove")
					if #group.flags == 0 then
						Utils.Notify("Group is now empty and will be removed", vim.log.levels.WARN)
						local updated = {}
						for _, entry in ipairs(groups) do
							if entry.name ~= group.name then
								table.insert(updated, entry)
							end
						end
						local ok, err = save_link_options(makefile_path, content, updated, individuals)
						if not ok then
							Utils.Notify("Failed to save links: " .. (err or "unknown error"), vim.log.levels.ERROR)
							return
						end
						return
					end
					local ok, err = save_link_options(makefile_path, content, groups, individuals)
					if not ok then
						Utils.Notify("Failed to save links: " .. (err or "unknown error"), vim.log.levels.ERROR)
						return
					end
					Utils.Notify("Updated group: " .. group.name, vim.log.levels.INFO)
				end, { prompt_title = "Remove links from " .. group.name })
				return
			end

			if action == "replace" then
				local flags = parse_links_input("Enter replacement links (space-separated): ")
				if #flags == 0 then
					Utils.Notify("No links provided", vim.log.levels.WARN)
					return
				end
				if not confirm_action("Replace all links in '" .. group.name .. "'?") then
					return
				end
				group.flags = normalize_link_flags(flags)
				local ok, err = save_link_options(makefile_path, content, groups, individuals)
				if not ok then
					Utils.Notify("Failed to save links: " .. (err or "unknown error"), vim.log.levels.ERROR)
					return
				end
				Utils.Notify("Replaced links in group: " .. group.name, vim.log.levels.INFO)
			end
		end, { prompt_title = "Edit group: " .. group.name })
	end, { prompt_title = "Select group to edit" })
end

function M.ManageLinkOptionsInteractive(makefile_path, makefile_content)
	local picker = get_picker_or_warn("Telescope is required for link management")
	if not picker then
		return false
	end

	local menu_items = {
		{ value = "add", display = "Add" },
		{ value = "remove", display = "Remove" },
		{ value = "edit", display = "Edit" },
		{ value = "list", display = "List/View" },
		{ value = "exit", display = "Exit" },
	}

	picker.pick_menu(menu_items, function(selection)
		if selection == "add" then
			manage_link_options_add(picker, makefile_path, makefile_content)
		elseif selection == "remove" then
			manage_link_options_remove(picker, makefile_path, makefile_content)
		elseif selection == "edit" then
			manage_link_options_edit(picker, makefile_path, makefile_content)
		elseif selection == "list" then
			manage_link_options_list(makefile_path, makefile_content)
		end
	end, { prompt_title = "Links: Menu" })

	return true
end

---@param Content string
---@return table[]
local function GetObjectTargetsForPicker(Content)
	local sections = get_sections_by_types(Content, { obj = true })
	---@type table[]
	local names = {}

	for _, entry in ipairs(sections) do
		for _, target in ipairs(entry.analysis.targets) do
			table.insert(names, {
				value = target.name,
				display = entry.baseName .. ".o",
			})
		end
	end
	return names
end

---@param Content string
---@return table[]
local function GetExeTables(Content)
	return get_sections_by_types(Content, { full = true, executable = true })
end

---@param Content string
---@return table[]
local function GetAllTargetsForDisplay(Content)
	local allSections = Parser.AnalyzeAllSections(Content)
	---@type table[]
	local targets = {}

	for _, section in ipairs(allSections) do
		for _, target in ipairs(section.analysis.targets) do
			local targetType = target_type_label(target.name)

			table.insert(targets, {
				name = target.name,
				display = target.name .. " " .. targetType,
				type = targetType,
			})
		end
	end

	return targets
end

---@param MakefilePath string
---@param FilePath string
---@param RootPath string
---@param Content string
---@param BypassCheck boolean|nil
---@return boolean
function M.AddToMakefile(MakefilePath, FilePath, RootPath, Content, BypassCheck)
	BypassCheck = BypassCheck or false
	if not BypassCheck then
		if not Utils.IsValidSourceFile(FilePath, M.Config.SourceExtensions) then
			Utils.Notify("File is not a valid source file: " .. vim.fn.fnamemodify(FilePath, ":e"), vim.log.levels.WARN)
			return false
		end
	end

	local Vars = Parser.ParseVariables(Content)
	local BuildDir = Vars["BUILD_DIR"]

	local RelativePath = get_relative_or_warn(FilePath, RootPath)
	if not RelativePath then
		return false
	end

	local Basename = vim.fn.fnamemodify(FilePath, ":t:r")

	local TargetType = vim.fn.input("Target type - [o]bject file or [e]xecutable? [o/e]:\n")
	if TargetType ~= "o" and TargetType ~= "e" then
		Utils.Notify("\nInvalid choice. Must be 'o ( Object )' or 'e ( Executable )'.", vim.log.levels.WARN)
		return false
	end

	if TargetType == "o" then
		local ObjName = Basename .. ".o"
		if Parser.TargetExists(Content, RelativePath) then
			Utils.Notify("\nObject target '" .. ObjName .. "' already exists.", vim.log.levels.INFO)
			return false
		end

		local Lines = Generator.ObjectTarget(Basename, RelativePath, M.Config.MakefileVars)
		local AppendSuccess, WriteErr = Utils.AppendToFile(MakefilePath, Lines)
		if not AppendSuccess then
			Utils.Notify("\nFailed to write to Makefile: " .. WriteErr, vim.log.levels.ERROR)
			return false
		end

		Utils.Notify("\nAdded object target: " .. ObjName, vim.log.levels.INFO)
		local Bear = require("config.utils.make.modules.bear")
		Bear.Target(Lines, RootPath, BuildDir)
		return true
	else
		if Parser.TargetExists(Content, RelativePath) then
			Utils.Notify("\nExecutable target '" .. Basename .. "' already exists.", vim.log.levels.INFO)
			return false
		end

		local ObjectFiles = GetObjectTargetsForPicker(Content)

		local function finalize_executable(selected_deps)
			local ok = select_links({}, Content, function(selected_links)
				local Lines, status = Generator.ExecutableTarget(
					Basename,
					RelativePath,
					selected_deps,
					M.Config.MakefileVars,
					RootPath,
					selected_links
				)
				if not status then
					Utils.Notify(
						"\nFailed to generate executable target. Missing include paths for: "
							.. table.concat(Lines, ", "),
						vim.log.levels.ERROR
					)
					return
				end
				local AppendSuccess, WriteErr = Utils.AppendToFile(MakefilePath, Lines)
				if not AppendSuccess then
					Utils.Notify("\nFailed to write to Makefile: " .. WriteErr, vim.log.levels.ERROR)
					return
				end
				Utils.Notify(
					"\nAdded executable target: " .. Basename .. " with " .. #selected_deps .. " dependencies",
					vim.log.levels.INFO
				)
			end, { prompt_title = "Select link flags" })
			return ok
		end

		if #ObjectFiles > 0 then
			local picker = get_picker_or_warn("Telescope is required for selection.")
			if not picker then
				return false
			end
			picker.pick_checklist(ObjectFiles, function(Selected)
				finalize_executable(Selected or {})
			end, { prompt_title = "Select object file dependencies" })
		else
			if finalize_executable({}) == false then
				return false
			end
		end
		return true
	end
end

---@param MakefilePath string
---@param RelativePath string
---@param Content string
---@return boolean
function M.BuildTarget(MakefilePath, RelativePath, Content)
	local Targets = GetExeTables(Content)
	if not Targets or #Targets == 0 then
		Utils.Notify("No executable targets found in Makefile", vim.log.levels.WARN)
		return false
	end

	local Entry = find_section_by_path(Targets, RelativePath)
	if not Entry or not Entry.analysis.targets[2] then
		Utils.Notify("No matching target found", vim.log.levels.WARN)
		return false
	end
	local BinName = Entry.analysis.targets[2].name

	local dir = vim.fn.fnamemodify(MakefilePath, ":h")
	local MakefileVars = Parser.ParseVariables(Content)
	BinName = vim.fn.fnamemodify(BinName, ":t")
	local ReExePath = MakefileVars.BUILD_DIR:gsub("^%./", "") .. "/" .. BinName

	local cmd = string.format("cd %s && make %s", dir, ReExePath)

	vim.system({ "sh", "-c", cmd }, { text = true }, function(obj)
		vim.defer_fn(function()
			vim.schedule(function()
				if obj.code == 0 then
					Utils.Notify("Build succeeded: " .. BinName, vim.log.levels.INFO, {
						title = "Make Build",
					})
					return
				end

				local err_path = string.format("/tmp/%s.err", BinName)
				if Utils.WriteFile(err_path, obj.stderr, false) then
					Utils.Notify(
						string.format("Build failed. Error saved to: %s", err_path),
						vim.log.levels.HINT,
						{ title = "Make Build" }
					)
				else
					Utils.Notify("Build failed (could not write error file).", vim.log.levels.ERROR, {
						title = "Make Build",
					})
				end
			end)
		end, 100)
	end)

	return true
end

---@param MakefilePath string
---@param RelativePath string
---@param Content string
---@return boolean
function M.RunTargetInSpilt(MakefilePath, RelativePath, Content)
	local ok, term = pcall(require, "config.utils.toggleTerm")
	if not ok then
		Utils.Notify("toggleTerm is unavailable.", vim.log.levels.WARN)
		return false
	end

	local Targets = GetExeTables(Content)
	if not Targets or #Targets == 0 then
		Utils.Notify("No executable targets found in Makefile", vim.log.levels.WARN)
		return false
	end

	local Entry = find_section_by_path(Targets, RelativePath)
	if not Entry then
		Utils.Notify("No matching run target for " .. RelativePath, vim.log.levels.WARN)
		return false
	end
	local RunTargetName = "run" .. Entry.baseName

	local MakefileDir = vim.fn.fnamemodify(MakefilePath, ":h")
	local cmd = "cd " .. vim.fn.shellescape(MakefileDir) .. " && make " .. RunTargetName
	term.SingleShot(cmd)

	return true
end

---@param makefile_content string
---@return boolean
function M.PickAndRunTargets(makefile_content)
	local targets = GetAllTargetsForDisplay(makefile_content)
	if not targets or #targets == 0 then
		Utils.Notify("No targets found in Makefile", vim.log.levels.WARN)
		return false
	end

	local picker = get_picker_or_warn("Telescope is required for selection.")
	if not picker then
		return false
	end

	table.sort(targets, function(a, b)
		return a.display < b.display
	end)

	local display_labels = {}
	local name_by_label = {}
	for _, target in ipairs(targets) do
		table.insert(display_labels, target.display)
		name_by_label[target.display] = target.name
	end

	picker.pick_checklist(display_labels, function(selected_labels)
		if not selected_labels or #selected_labels == 0 then
			Utils.Notify("No targets selected", vim.log.levels.WARN)
			return
		end

		local selected_targets = {}
		for _, label in ipairs(selected_labels) do
			local target_name = name_by_label[label]
			if target_name then
				table.insert(selected_targets, target_name)
			end
		end

		local makefile_dir = vim.fn.getcwd()
		local cmd = "cd " .. vim.fn.shellescape(makefile_dir) .. " && make " .. table.concat(selected_targets, " ")

		vim.cmd("terminal " .. cmd)
		Utils.Notify("Running targets: " .. table.concat(selected_targets, ", "), vim.log.levels.INFO)
	end, {
		prompt_title = "Select Makefile target(s)",
	})
	return true
end

---@param MakefilePath string
---@param FilePath string
---@param RootPath string
---@param Content string
---@param Entries table[]|nil
---@param callback fun(success:boolean)|nil
---@return boolean
function M.EditTarget(MakefilePath, FilePath, RootPath, Content, Entries, callback)
	local Basename = vim.fn.fnamemodify(FilePath, ":t:r")

	local RelativePath = get_relative_or_warn(FilePath, RootPath)
	if not RelativePath then
		if callback then
			callback(false)
		end
		return false
	end

	if not Entries or #Entries == 0 then
		Entries = GetExeTables(Content)
		if not Entries or #Entries == 0 then
			Utils.Notify("No executable targets found in Makefile", vim.log.levels.WARN)
			if callback then
				callback(false)
			end
			return false
		end
	end

	local existing_deps = {}
	local entry = find_section_by_path(Entries, RelativePath)
	if entry and entry.analysis.targets[2] then
		existing_deps = { unpack(entry.analysis.targets[2].dependencies, 2) }
	end
	local existing_links = get_existing_links(Content, RelativePath, (entry and entry.baseName) or Basename)

	local ObjectFiles = GetObjectTargetsForPicker(Content)
	if not ObjectFiles or #ObjectFiles == 0 then
		if not has_link_options(Content) then
			Utils.Notify("No object files available for dependency selection", vim.log.levels.WARN)
			if callback then
				callback(false)
			end
			return false
		end

		local ok = select_links(existing_links, Content, function(selected_links)
			local updated_content =
				update_links_for_entry(Content, RelativePath, (entry and entry.baseName) or Basename, selected_links)
			if not updated_content then
				if callback then
					callback(false)
				end
				return
			end

			local Success, WriteErr = Utils.WriteFile(MakefilePath, updated_content)
			if not Success then
				Utils.Notify("Failed to write Makefile: " .. WriteErr, vim.log.levels.ERROR)
				if callback then
					callback(false)
				end
				return
			end

			Utils.Notify("Updated links for: " .. Basename, vim.log.levels.INFO)
		end, { prompt_title = "Select link flags", preselect = true })

		if ok == false and callback then
			callback(false)
		end
		return true
	end

	local picker = get_picker_or_warn("Telescope is required for editing targets")
	if not picker then
		if callback then
			callback(false)
		end
		return false
	end

	picker.pick_checklist(ObjectFiles, function(selected)
		local selected_deps = selected or {}
		local ok = select_links(existing_links, Content, function(selected_links)
			local markerInfo = Parser.FindMarker(Content, RelativePath, true, true)

			if markerInfo.M_start == -1 then
				Utils.Notify("Marker start not found for: " .. RelativePath, vim.log.levels.ERROR)
				if callback then
					callback(false)
				end
				return
			end

			if markerInfo.M_end == -1 then
				Utils.Notify("Marker end not found for: " .. RelativePath, vim.log.levels.ERROR)
				if callback then
					callback(false)
				end
				return
			end

			local Lines = vim.split(Content, "\n", { plain = true })
			local NewLines = {}
			for i = 1, markerInfo.M_start - 1 do
				table.insert(NewLines, Lines[i])
			end
			for i = markerInfo.M_end + 1, #Lines do
				table.insert(NewLines, Lines[i])
			end

			Content = table.concat(NewLines, "\n")

			local GenLines, status = Generator.ExecutableTarget(
				Basename,
				RelativePath,
				selected_deps,
				M.Config.MakefileVars,
				RootPath,
				selected_links
			)
			if not status then
				Utils.Notify(
					"Failed to regenerate target. Missing include paths for: " .. table.concat(GenLines, ", "),
					vim.log.levels.ERROR
				)
				if callback then
					callback(false)
				end
				return
			end

			Content = Content .. table.concat(GenLines, "\n")
			local Success, WriteErr = Utils.WriteFile(MakefilePath, Content)
			if not Success then
				Utils.Notify("Failed to write Makefile: " .. WriteErr, vim.log.levels.ERROR)
				if callback then
					callback(false)
				end
				return
			end

			Utils.Notify(
				"Edited target: " .. Basename .. " with " .. #selected_deps .. " dependencies",
				vim.log.levels.INFO
			)
		end, { prompt_title = "Select link flags", preselect = true })

		if ok == false and callback then
			callback(false)
		end
	end, { prompt_title = "Select new dependencies for " .. Basename, preselected_items = existing_deps })
	return true
end

---@param MakefilePath string
---@param RootPath string
---@param Content string
---@return boolean
function M.EditAllTargets(MakefilePath, RootPath, Content)
	local Entries = GetExeTables(Content)
	if not Entries or #Entries == 0 then
		Utils.Notify("No executable targets found in Makefile", vim.log.levels.WARN)
		return false
	end

	local picker = get_picker_or_warn("Telescope is required for editing targets")
	if not picker then
		return false
	end

	local pick_entries = {}
	local entry_map = {}
	for _, ent in ipairs(Entries) do
		table.insert(pick_entries, { value = ent.baseName, display = ent.baseName })
		entry_map[ent.baseName] = ent
	end

	picker.pick_single(pick_entries, function(selected)
		if #selected == 0 then
			Utils.Notify("Nothing selected.", vim.log.levels.WARN)
			return
		end

		M.EditTarget(MakefilePath, entry_map[selected].path, RootPath, Content, entry_map[selected])
	end, { prompt_title = "Select target to edit" })
	return true
end

---@param MakefilePath string
---@param Content string
---@return boolean
function M.Remove(MakefilePath, Content)
	local Entries = Parser.AnalyzeAllSections(Content)

	local map = {}
	local PickerEntries = {}

	local picker = get_picker_or_warn("Telescope is required for editing targets")
	if not picker then
		return false
	end

	for _, Entry in ipairs(Entries) do
		table.insert(PickerEntries, {
			value = Entry.startLine,
			display = Entry.baseName .. " ( " .. Entry.analysis.type .. " )",
			preview_text = Parser.ReadContentBetweenLines(Content, Entry.startLine, Entry.endLine, true),
		})
		map[Entry.startLine] = Entry
	end

	picker.pick_multi_with_preview(PickerEntries, function(selected)
		if #selected == 0 then
			Utils.Notify("Nothing selected.", vim.log.levels.WARN)
			return
		end

		local Lines = {}
		for text, nl in Content:gmatch("([^\n]*)(\n?)") do
			if text ~= "" then
				if nl ~= "" then
					text = text .. nl
				end
				table.insert(Lines, text)
			else
				if nl ~= "" then
					table.insert(Lines, nl)
				end
			end
		end

		local function RemoveEntry(StartLine, Endline, LinesTable)
			local NewLines = {}
			for i = 1, StartLine - 1 do
				table.insert(NewLines, LinesTable[i])
			end
			if LinesTable[StartLine - 1] == "\n" then
				table.remove(NewLines, StartLine - 1)
				table.insert(NewLines, "--DELETEME")
			end
			for _ = StartLine, Endline do
				table.insert(NewLines, "--DELETEME")
			end
			for i = Endline + 1, #LinesTable do
				table.insert(NewLines, LinesTable[i])
			end

			return NewLines
		end

		for _, LineNum in ipairs(selected) do
			Lines = RemoveEntry(LineNum, map[LineNum].endLine, Lines)
		end

		for i = #Lines, 1, -1 do
			if Lines[i] == "--DELETEME" then
				table.remove(Lines, i)
			end
		end

		Content = table.concat(Lines)

		local Success, WriteErr = Utils.WriteFile(MakefilePath, Content)
		if not Success then
			Utils.Notify("Failed to write Makefile: " .. WriteErr, vim.log.levels.ERROR)
			return
		end
	end, { prompt_title = "Select target(s) to remove", previewer = picker.text_per_entry_previewer("make") })
	return true
end

---@param RootPath string where it will search for sources
---@return boolean
function M.PickAndAdd(RootPath, Content)
	local picker = get_picker_or_warn("Telescope is required for selection.")
	if not picker then
		return false
	end
	local results = vim.fs.find(function(name)
		return name:match("%.cpp$") ~= nil -- change extension here
	end, { path = RootPath, type = "file", limit = math.huge })

	if #results == 0 then
		Utils.Notify("No source files found in project", vim.log.levels.WARN)
		return false
	end

	local RawEntries = Parser.AnalyzeAllSections(Content)
	local ExistingTargets = {}

	for _, Entry in ipairs(RawEntries) do
		table.insert(ExistingTargets, Entry.path)
	end

	picker.pick_checklist(results, function(selected) end)
	return true
end

function M.FastRun()
	local makefile_path = vim.fn.expand("%:p:h") .. "/Makefile"
	local makefile_dir = vim.fn.fnamemodify(makefile_path, ":h")
	Parser.SetCacheRoot(makefile_dir, makefile_path)
	local file_path = vim.fn.expand("%:p")
	local relative_path = get_relative_or_warn(file_path, makefile_dir)
	if not relative_path then
		return false
	end

	local makefile_content = nil
	if vim.loop.fs_stat(makefile_path) then
		makefile_content, _ = Utils.ReadFile(makefile_path)
		if makefile_content and makefile_content ~= "" and Parser.TargetExists(makefile_content, relative_path) then
			M.Make({ "run" })
			return true
		end
	end

	local ensured = Generator.EnsureMakefileVariables(makefile_path, makefile_content, M.Config.MakefileVars)
	if ensured == nil then
		return false
	end

	local basename = vim.fn.fnamemodify(file_path, ":t:r")
	local ok = select_links({}, makefile_content, function(selected_links)
		local lines = Generator.ExecutableTarget(
			basename,
			relative_path,
			{},
			M.Config.MakefileVars,
			makefile_dir,
			selected_links
		)
		local AppendSuccess, WriteErr = Utils.AppendToFile(makefile_path, lines)
		if not AppendSuccess then
			Utils.Notify("\nFailed to write to Makefile: " .. WriteErr, vim.log.levels.ERROR)
			return
		end
		M.Make({ "run" })
	end, { prompt_title = "Select link flags" })
	if ok == false then
		return false
	end
	return true
end

---@param Fargs string[]
---@return boolean|nil
function M.Make(Fargs)
	local arg = (Fargs[1] or "run"):lower()
	if #Fargs > 2 and arg ~= "link" then
		Utils.Notify("Too many arguments. Use: add, edit, run, ...", vim.log.levels.WARN)
		return false
	end

	local Root, Err = RootFinder.FindRoot(nil, M.Config.MaxSearchLevels, M.Config.RootMarkers)

	if not Root then
		Utils.Notify("No project root found: " .. (Err or "unknown error"), vim.log.levels.WARN)
		return false
	end

	Parser.SetCacheRoot(Root.Path, MakefilePath)
	local MakefilePath = Root.Path .. "/Makefile"

	local Stat = vim.loop.fs_stat(MakefilePath)
	if not Stat then
		-- This will only get triggered if there is another root marker other than Makefile and Makefile don't exist
		local ans = vim.fn.input("Makefile not found. Create it? (y/n): ")

		if ans ~= "y" and ans ~= "Y" then
			return false
		end

		local Success = Generator.EnsureMakefileVariables(MakefilePath, nil, M.Config.MakefileVars)
		if Success == nil then
			return nil
		end
		if Fargs[1] == "run" or Fargs[1] == "runb" then
			M.Make({ "add" })
			return false
		end
		M.Make(Fargs)
		return false
	end

	if arg == "open" then
		if vim.loop.fs_stat(MakefilePath) then
			vim.cmd("edit " .. vim.fn.fnameescape(MakefilePath))
			Utils.Notify("Opened Makefile", vim.log.levels.INFO)
			return true
		else
			Utils.Notify("Makefile not found at " .. MakefilePath, vim.log.levels.WARN)
			return false
		end
	end

	local MakefileContent, _ = Utils.ReadFile(MakefilePath)
	local Success = Generator.EnsureMakefileVariables(MakefilePath, MakefileContent, M.Config.MakefileVars)
	if not Success then
		if Success == nil then
			Utils.Notify("Failed to ensure Makefile variables", vim.log.levels.ERROR)
			return nil
		end
		return M.Make(Fargs)
	end
	if not MakefileContent then
		MakefileContent = ""
	end

	local CurrentFile = vim.fn.expand("%:p")
	if CurrentFile == "" then
		Utils.Notify("No file currently open", vim.log.levels.WARN)
		return false
	end
	-- if #Fargs == 2 then
	-- 	if Arg == "run" or Arg == "runb" then
	-- 		Fargs[2] = Fargs[2]:lower()
	-- 		local RelativePath, okay = Utils.GetRelativePath(CurrentFile, Root.Path)
	-- 		if not okay then
	-- 			Utils.Notify(RelativePath, vim.log.levels.ERROR)
	-- 			return false
	-- 		end
	-- 		if Fargs[2] == "split" then
	-- 			M.RunTargetInSpilt(MakefilePath, RelativePath, MakefileContent)
	-- 		elseif Fargs[2] == "float" then
	-- 			M.RunTargetInSpilt(MakefilePath, RelativePath, MakefileContent)
	-- 		elseif Fargs[2] == "tab" then
	-- 			M.RunTargetInSpilt(MakefilePath, RelativePath, MakefileContent)
	-- 		end
	-- 		if Arg == "runb" then
	-- 			local Bear = require("config.utils.make.modules.bear")
	-- 			Bear.CurrentFile(MakefileContent, Root.Path, RelativePath, function()
	-- 				M.Make({ "run" })
	-- 			end)
	-- 		end
	-- 	end
	-- end

	if arg == "add" then
		return M.AddToMakefile(MakefilePath, CurrentFile, Root.Path, MakefileContent)
	elseif arg == "bearall" then
		return require("config.utils.make.modules.bear").SelectTarget(MakefileContent, Root.Path)
	elseif arg == "run" then
		local RelativePath, _ = Utils.GetRelativePath(CurrentFile, Root.Path)
		M.RunTargetInSpilt(MakefilePath, RelativePath, MakefileContent)
		return true
	elseif arg == "runb" then
		local Bear = require("config.utils.make.modules.bear")
		local RelativePath, _ = Utils.GetRelativePath(CurrentFile, Root.Path)
		Bear.CurrentFile(MakefileContent, Root.Path, RelativePath, function()
			M.Make({ "run" })
		end)
		return true
	elseif arg == "build" then
		local RelativePath, _ = Utils.GetRelativePath(CurrentFile, Root.Path)
		M.BuildTarget(MakefilePath, RelativePath, MakefileContent)
	elseif arg == "edit" then
		return M.EditTarget(MakefilePath, CurrentFile, Root.Path, MakefileContent)
	elseif arg == "tasks" then
		return M.PickAndRunTargets(MakefileContent)
	elseif arg == "edit_all" then
		return M.EditAllTargets(MakefilePath, Root.Path, MakefileContent)
	elseif arg == "remove" then
		return M.Remove(MakefilePath, MakefileContent)
	elseif arg == "analysis" then
		Parser.PrintAnalysisSummary(MakefileContent)
		return true
	elseif arg == "bear" then
		local Bear = require("config.utils.make.modules.bear")
		return Bear.CurrentFile(MakefileContent, Root.Path)
	elseif arg == "mode" then
		return M.SetBuildMode(MakefilePath, MakefileContent, Fargs[2])
	elseif arg == "link" then
		return M.ManageLinkOptionsInteractive(MakefilePath, MakefileContent)
	else
		Utils.Notify("Unknown command.", vim.log.levels.WARN)
		return false
	end
end

return M
