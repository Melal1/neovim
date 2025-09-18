local M = {}

local Config = require("config.utils.make.config")
local Utils = require("config.utils.make.utils")
local Parser = require("config.utils.make.parser")
local Generator = require("config.utils.make.generator")
local RootFinder = require("config.utils.make.root_find")

M.Config = Config.DefaultConfig

function M.Setup(UserConfig)
	M.Config = vim.tbl_deep_extend("force", M.Config, UserConfig or {})
end

function M.AddToMakefile(MakefilePath, FilePath, RootPath, Content)
	if not Utils.IsValidSourceFile(FilePath, M.Config.SourceExtensions) then
		vim.notify("File is not a valid source file: " .. vim.fn.fnamemodify(FilePath, ":e"), vim.log.levels.WARN)
		return false
	end

	local Success, UpdatedContent = Generator.EnsureMakefileVariables(MakefilePath, Content, M.Config.MakefileVars)
	if not Success then
		vim.notify(UpdatedContent or "Failed to ensure Makefile variables", vim.log.levels.ERROR)
		return false
	end
	Content = UpdatedContent

	local RelativePath, Err = Utils.GetRelativePath(FilePath, RootPath)
	if not RelativePath then
		vim.notify(Err or "Failed to get relative path", vim.log.levels.WARN)
		return false
	end

	local Basename = vim.fn.fnamemodify(FilePath, ":t:r")
	local Targets = Parser.ParseTargets(Content)

	local TargetType = vim.fn.input("Target type - [o]bject file or [e]xecutable? [o/e]: ")
	if TargetType ~= "o" and TargetType ~= "e" then
		vim.notify("Invalid choice. Must be 'o' or 'e'.", vim.log.levels.WARN)
		return false
	end

	if TargetType == "o" then
		local ObjName = Basename .. ".o"
		if Targets[ObjName] then
			vim.notify("Object target '" .. ObjName .. "' already exists.", vim.log.levels.INFO)
			return false
		end

		local Lines = Generator.ObjectTarget(Basename, RelativePath, M.Config.MakefileVars)
		local AppendSuccess, WriteErr = Utils.AppendToFile(MakefilePath, Lines)
		if not AppendSuccess then
			vim.notify("Failed to write to Makefile: " .. WriteErr, vim.log.levels.ERROR)
			return false
		end

		vim.notify("Added object target: " .. ObjName, vim.log.levels.INFO)
		return true
	else
		if Targets[Basename] then
			vim.notify("Executable target '" .. Basename .. "' already exists.", vim.log.levels.INFO)
			return false
		end

		local ObjectFiles = Parser.GetObjectFiles(Targets)

		local picker = require("config.utils.pick")
		if not picker.available then
			vim.notify("Need Telescope for file selection", vim.log.levels.ERROR)
			return false
		end

		if #ObjectFiles > 0 then
			picker.pick_files(ObjectFiles, function(Selected)
				local Lines = Generator.ExecutableTarget(Basename, RelativePath, Selected, M.Config.MakefileVars)
				local AppendSuccess, WriteErr = Utils.AppendToFile(MakefilePath, Lines)
				if not AppendSuccess then
					vim.notify("Failed to write to Makefile: " .. WriteErr, vim.log.levels.ERROR)
					return
				end
				vim.notify(
					"Added executable target: " .. Basename .. " with " .. #Selected .. " dependencies",
					vim.log.levels.INFO
				)
			end, { prompt_title = "Select object file dependencies (Tab to toggle, Enter to confirm)" })
		else
			local Lines = Generator.ExecutableTarget(Basename, RelativePath, {}, M.Config.MakefileVars)
			local AppendSuccess, WriteErr = Utils.AppendToFile(MakefilePath, Lines)
			if not AppendSuccess then
				vim.notify("Failed to write to Makefile: " .. WriteErr, vim.log.levels.ERROR)
				return false
			end
			vim.notify("Added standalone executable target: " .. Basename, vim.log.levels.INFO)
		end
		return true
	end
end

function M.EditTarget(MakefilePath, FilePath, RootPath, Content)
	local Basename = vim.fn.fnamemodify(FilePath, ":t:r")
	local Targets = Parser.ParseTargets(Content)

	if not Targets[Basename] then
		vim.notify("Target '" .. Basename .. "' not found in Makefile.", vim.log.levels.WARN)
		return false
	end

	local ObjectFiles = Parser.GetObjectFiles(Targets)
	if #ObjectFiles == 0 then
		vim.notify("No object files found to select as dependencies.", vim.log.levels.WARN)
		return false
	end

	local picker = require("config.utils.pick")
	if not picker.available then
		vim.notify("Need Telescope for file selection", vim.log.levels.ERROR)
		return false
	end

	picker.pick_files(ObjectFiles, function(Selected)
		local Lines = {}
		for line in Content:gmatch("([^\n]*)\n?") do
			table.insert(Lines, line)
		end

		local NewLines = {}
		local InsideTarget = false
		local TargetUpdated = false
		local LinkDepsStr = ""

		for _, line in ipairs(Lines) do
			if line:match("^%s*" .. Utils.EscapePattern(Basename) .. "%s*:") then
				local DepsStr = ""

				if #Selected > 0 then
					DepsStr = table.concat(Selected, " ") .. " "
					local Prefixed = {}
					for _, dep in ipairs(Selected) do
						table.insert(Prefixed, "$(BUILD_DIR)/" .. dep)
					end
					LinkDepsStr = table.concat(Prefixed, " ") .. " "
				end

				table.insert(NewLines, Basename .. ": " .. DepsStr .. Basename .. ".o")
				InsideTarget = true
				TargetUpdated = true
			elseif InsideTarget and line:match("^\t") then
				local CompilerVar = M.Config.MakefileVars.CC and "$(CC)" or "$(CXX)"
				table.insert(
					NewLines,
					"\t"
						.. CompilerVar
						.. " $(BUILD_DIR)/"
						.. Basename
						.. ".o "
						.. LinkDepsStr
						.. "-o $(BUILD_DIR)/"
						.. Basename
				)
				InsideTarget = false
			else
				table.insert(NewLines, line)
				InsideTarget = false
			end
		end

		if TargetUpdated then
			local NewContent = table.concat(NewLines, "\n")
			local WriteSuccess, WriteErr = Utils.WriteFile(MakefilePath, NewContent)
			if not WriteSuccess then
				vim.notify("Failed to update Makefile: " .. WriteErr, vim.log.levels.ERROR)
				return
			end
			vim.notify("Updated target: " .. Basename .. " with " .. #Selected .. " dependencies", vim.log.levels.INFO)
		else
			vim.notify("Failed to update target in Makefile", vim.log.levels.ERROR)
		end
	end, { prompt_title = "Select new dependencies for " .. Basename })

	return true
end

function M.RunTarget(MakefilePath, FilePath, Content)
	local Basename = vim.fn.fnamemodify(FilePath, ":t:r")
	local RunTargetName = "run" .. Basename
	local Targets = Parser.ParseTargets(Content or "")

	if not Targets[RunTargetName] then
		vim.notify("No run target found for: " .. Basename, vim.log.levels.WARN)
		return false
	end

	local MakefileDir = vim.fn.fnamemodify(MakefilePath, ":h")
	local Cmd = "cd " .. vim.fn.shellescape(MakefileDir) .. " && make " .. RunTargetName

	vim.cmd("terminal " .. Cmd)
	vim.notify("Running target: " .. RunTargetName, vim.log.levels.INFO)
	return true
end

function M.RunMake(Arg)
	Arg = Arg or "add"

	if type(Arg) ~= "string" or Arg == "" then
		vim.notify("Invalid argument. Use: add, edit, run, or open", vim.log.levels.WARN)
		return false
	end

	local Root, Err = RootFinder.FindRoot(nil, M.Config.MaxSearchLevels, M.Config.RootMarkers)
	if not Root then
		vim.notify("No project root found: " .. (Err or "unknown error"), vim.log.levels.WARN)
		return false
	end

	local MakefilePath = Root.Path .. "/Makefile"

	if Arg == "open" then
		if vim.loop.fs_stat(MakefilePath) then
			vim.cmd("edit " .. vim.fn.fnameescape(MakefilePath))
			vim.notify("Opened Makefile", vim.log.levels.INFO)
			return true
		else
			vim.notify("Makefile not found at " .. MakefilePath, vim.log.levels.WARN)
			return false
		end
	end

	local MakefileContent, _ = Utils.ReadFile(MakefilePath)
	if not MakefileContent then
		local VarLines = Generator.GenerateMakefileVariables(M.Config.MakefileVars)
		MakefileContent = table.concat(VarLines, "\n")
		local Success, WriteErr = Utils.WriteFile(MakefilePath, MakefileContent)
		if not Success then
			vim.notify("Could not create Makefile: " .. WriteErr, vim.log.levels.ERROR)
			return false
		end
		vim.notify("Created new Makefile with default variables", vim.log.levels.INFO)
	end

	local CurrentFile = vim.fn.expand("%:p")
	if CurrentFile == "" then
		vim.notify("No file currently open", vim.log.levels.WARN)
		return false
	end

	vim.notify("Found project in: " .. Root.Path .. " (marker: " .. Root.Marker .. ")", vim.log.levels.INFO)

	local Success = false
	if Arg == "add" then
		Success = M.AddToMakefile(MakefilePath, CurrentFile, Root.Path, MakefileContent)
	elseif Arg == "edit" then
		Success = M.EditTarget(MakefilePath, CurrentFile, Root.Path, MakefileContent)
	elseif Arg == "run" then
		Success = M.RunTarget(MakefilePath, CurrentFile, MakefileContent)
	else
		vim.notify("Unknown command: " .. Arg .. ". Use: add, edit, run, or open", vim.log.levels.WARN)
	end

	return Success
end

return M
