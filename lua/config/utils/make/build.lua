local M = {}

local Utils = require("config.utils.make.utils")
local Parser = require("config.utils.make.parser")

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

	local vars = Parser.ParseVariables(Content or "")
	local base_dir = vars.BUILD_DIR or "./build"
	base_dir = base_dir:gsub("/debug$", ""):gsub("/release$", "")
	if base_dir:sub(-1) == "/" then
		base_dir = base_dir:sub(1, -2)
	end
	if base_dir == "" then
		base_dir = "./build"
	end
	if not update_makefile_var(lines, "BUILD_DIR", base_dir) then
		insert_makefile_var(lines, "BUILD_DIR", base_dir)
	end
	if not update_makefile_var(lines, "BUILD_MODE", normalized) then
		insert_makefile_var(lines, "BUILD_MODE", normalized)
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

return M
