local Utils = require("config.utils.make.utils")
local Parser = require("config.utils.make.parser")
local Finder = require("config.utils.make.finder")

local Generator = {}

function Generator.GenerateMakefileVariables(MakefileVars)
	local Lines = {}

	for VarName, VarValue in pairs(MakefileVars) do
		table.insert(Lines, VarName .. " = " .. VarValue)
	end

	table.insert(Lines, "$(shell mkdir -p $(BUILD_DIR))")
	table.insert(Lines, "")

	return Lines
end

function Generator.ObjectTarget(Basename, RelativePath, MakefileVars)
	local ObjName = Basename .. ".o"
	local CompilerVar = MakefileVars.CC and "$(CC)" or "$(CXX)"
	local FlagsVar = MakefileVars.CFLAGS and "$(CFLAGS)" or "$(CXXFLAGS)"

	return {
    "#marker_start: " ..RelativePath,
    "",
		ObjName .. ": " .. RelativePath,
		"\t" .. CompilerVar .. " " .. FlagsVar .. " -c " .. RelativePath .. " -o $(BUILD_DIR)/" .. ObjName,
		"",
    "#marker_end: " ..RelativePath,
    "",
	}
end

function Generator.ExecutableTarget(Basename, RelativePath, Dependencies, MakefileVars, RootPath)
	Dependencies = Dependencies or {}
	local ObjName = Basename .. ".o"
	local ExeName = Basename
	local CompilerVar = MakefileVars.CC and "$(CC)" or "$(CXX)"
	local FlagsVar = MakefileVars.CFLAGS and "$(CFLAGS)" or "$(CXXFLAGS)"

	local DepsStr = ""
	local LinkDepsStr = ""
	local UnFoiundIncludePath = {}
	local Include = {}
	local IncludeStr = ""

	if #Dependencies > 0 then
		DepsStr = table.concat(Dependencies, " ") .. " "

		local PrefixedDeps = {}
		for _, Dep in ipairs(Dependencies) do
			table.insert(PrefixedDeps, "$(BUILD_DIR)/" .. Dep)
			local IncludePath = Finder.FindHeaderDirectory(vim.fn.fnamemodify(Dep, ":t:r"), RootPath)
			if IncludePath then
				table.insert(Include, "-I" .. IncludePath)
			else
				table.insert(UnFoiundIncludePath, Dep)
			end
		end
		LinkDepsStr = table.concat(PrefixedDeps, " ") .. " "
		IncludeStr = table.concat(Include, " ") .. " "
	end

	if #UnFoiundIncludePath > 0 then
		return nil, UnFoiundIncludePath
	end

	return true,
		{
			"#marker_start: " .. RelativePath,
      "",
			ObjName .. ": " .. RelativePath,
			"\t"
				.. CompilerVar
				.. " "
				.. FlagsVar
				.. " -c "
				.. RelativePath
				.. " -o $(BUILD_DIR)/"
				.. ObjName
				.. " "
				.. IncludeStr,
			"",

			ExeName .. ": " .. DepsStr .. ObjName,
			"\t" .. CompilerVar .. " $(BUILD_DIR)/" .. ObjName .. " " .. LinkDepsStr .. "-o $(BUILD_DIR)/" .. ExeName,
			"",

			"run" .. ExeName .. ": " .. ExeName,
			"\t$(BUILD_DIR)/" .. ExeName,
			"",

      "#marker_end: " .. RelativePath,
      "",

		}
end

function Generator.EnsureMakefileVariables(MakefilePath, Content, MakefileVars)
	if not Parser.HasReqVars(Content, MakefileVars) then
		local VarLines = Generator.GenerateMakefileVariables(MakefileVars)
		local NewContent = table.concat(VarLines, "\n") .. (Content or "")

		local Success, WriteErr = Utils.WriteFile(MakefilePath, NewContent)
		if not Success then
			return false, "Failed to add variables to Makefile: " .. WriteErr
		end

		local VarNames = {}
		for VarName, _ in pairs(MakefileVars) do
			table.insert(VarNames, VarName)
		end
		table.sort(VarNames)

		vim.notify("Added Makefile variables (" .. table.concat(VarNames, ", ") .. ")", vim.log.levels.INFO)
		return true, NewContent
	end

	return true, Content
end

return Generator
