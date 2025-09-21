local M = {}

local Config = require("config.utils.make.config")
local Utils = require("config.utils.make.utils")
local Parser = require("config.utils.make.parser")
local Generator = require("config.utils.make.generator")
local RootFinder = require("config.utils.make.finder")

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
			picker.pick_checklist(ObjectFiles, function(Selected)
				local status, Lines =
					Generator.ExecutableTarget(Basename, RelativePath, Selected, M.Config.MakefileVars, RootPath)
				if not status then
					vim.notify(
						"Failed to generate executable target. Missing include paths for: " .. table.concat(Lines, ", "),
						vim.log.levels.ERROR
					)
					return
				end
				local AppendSuccess, WriteErr = Utils.AppendToFile(MakefilePath, Lines)
				if not AppendSuccess then
					vim.notify("Failed to write to Makefile: " .. WriteErr, vim.log.levels.ERROR)
					return
				end
				vim.notify(
					"Added executable target: " .. Basename .. " with " .. #Selected .. " dependencies",
					vim.log.levels.INFO
				)
			end, { prompt_title = "Select object file dependencies" })
		else
			local _, Lines = Generator.ExecutableTarget(Basename, RelativePath, {}, M.Config.MakefileVars, RootPath)
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

function M.PickAndRunTargets(makefile_content)
	local targets = Parser.ParseTargets(makefile_content)
	local display_labels = {}
	local real_names = {}
	local picker = require("config.utils.pick")
	if not picker.available then
		vim.notify("Need Telescope for file selection", vim.log.levels.ERROR)
		return false
	end

	for name, info in pairs(targets) do
		local label = name
		if info.IsObject then
			label = label .. " (obj)"
		elseif info.IsExecutable then
			label = label .. " (exe)"
		elseif info.IsRunTarget then
			label = label .. " (run)"
		end
		table.insert(display_labels, label)
		table.insert(real_names, name)
	end

	table.sort(display_labels)

	picker.pick_checklist(display_labels, function(selected_labels)
		if not selected_labels or #selected_labels == 0 then
			vim.notify("No targets selected", vim.log.levels.WARN)
			return
		end

		local selected_targets = {}
		for _, label in ipairs(selected_labels) do
			for i, dl in ipairs(display_labels) do
				if dl == label then
					table.insert(selected_targets, real_names[i])
					break
				end
			end
		end

		local makefile_dir = vim.fn.getcwd()
		local cmd = "cd " .. vim.fn.shellescape(makefile_dir) .. " && make " .. table.concat(selected_targets, " ")

		vim.cmd("terminal " .. cmd)
		vim.notify("Running targets: " .. table.concat(selected_targets, ", "), vim.log.levels.INFO)
	end, {
		prompt_title = "Select Makefile target(s) ",
	})
end

function M.EditAllTargets(makefile_content, makefile_path, root_path)
	local targets = Parser.ParseTargets(makefile_content)

	local target_file_map = {}
	for name, info in pairs(targets) do
		if info.IsExecutable then
			local source_name = name .. ".cpp"
			local candidate_paths = vim.fn.glob(root_path .. "/**/" .. source_name, true, true)
			if #candidate_paths > 0 then
				target_file_map[name] = candidate_paths[1]
			end
		end
	end

	local editable_targets = {}
	for name, _ in pairs(target_file_map) do
		table.insert(editable_targets, name)
	end

	if #editable_targets == 0 then
		vim.notify("No editable executable targets found", vim.log.levels.WARN)
		return
	end

	local picker = require("config.utils.pick")
	if not picker.available then
		vim.notify("Picker not available. Install Telescope for target selection.", vim.log.levels.ERROR)
		return
	end

	picker.pick_checklist(editable_targets, function(selected_targets)
		if not selected_targets or #selected_targets == 0 then
			vim.notify("No targets selected", vim.log.levels.WARN)
			return
		end

		local function edit_next(index)
			if index > #selected_targets then
				vim.notify("Updated " .. #selected_targets .. " executable target(s)", vim.log.levels.INFO)
				return
			end

			local target = selected_targets[index]
			local file_path = target_file_map[target]
			if file_path then
				M.EditTarget(makefile_path, file_path, root_path, makefile_content, function()
					edit_next(index + 1)
				end)
			else
				vim.notify("No source file found for target: " .. target, vim.log.levels.WARN)
				edit_next(index + 1)
			end
		end

		edit_next(1)
	end, {
		prompt_title = "Select executable targets to edit ",
	})
end

function M.EditTarget(MakefilePath, FilePath, RootPath, Content, callback)
	local Basename = vim.fn.fnamemodify(FilePath, ":t:r")
	local ObjName = Basename .. ".o"
	local ExeName = Basename
	local RunName = "run" .. ExeName

	local Targets = Parser.ParseTargets(Content or "")
	if not (Targets[ObjName] or Targets[ExeName] or Targets[RunName]) then
		vim.notify("No existing target found for: " .. Basename, vim.log.levels.WARN)
		if callback then
			callback(false)
		end
		return false
	end

	-- collect available object files
	local ObjectFiles = Parser.GetObjectFiles(Targets)
	if not ObjectFiles or #ObjectFiles == 0 then
		vim.notify("No object files available for dependency selection", vim.log.levels.WARN)
		if callback then
			callback(false)
		end
		return false
	end

	-- check picker availability
	local picker = require("config.utils.pick")
	if not picker.available then
		vim.notify("Telescope is required for editing targets", vim.log.levels.ERROR)
		if callback then
			callback(false)
		end
		return false
	end

	-- picker: select new dependencies
	picker.pick_checklist(ObjectFiles, function(selected)
		if not selected or #selected == 0 then
			vim.notify("No dependencies selected", vim.log.levels.WARN)
			if callback then
				callback(false)
			end
			return
		end

		local RelativePath, Err = Utils.GetRelativePath(FilePath, RootPath)
		if not RelativePath then
			vim.notify(Err or "Failed to get relative path", vim.log.levels.ERROR)
			if callback then
				callback(false)
			end
			return
		end

		local Lines = vim.split(Content, "\n", { plain = true })
		local NewLines = {}
		local StartMarker = "#marker_start: " .. RelativePath
		local EndMarker = "#marker_end: " .. RelativePath
		local skip = false
		local end_index = nil

		for idx, line in ipairs(Lines) do
      print("checking line with start marker_start " .. StartMarker .. ": " .. line)
			if line:find(StartMarker, 1, true) then
				print("-> Start marker found at line " .. idx .. ". Skipping lines...")
				skip = true
			end

			if skip == false then
				table.insert(NewLines, line)
				print("-> Keeping line: " .. line)
			else
				print("-> Skipping line: " .. line)
        print("Checking for end marker: " .. EndMarker .. " Line: " .. line)
			end

			if line:find(EndMarker, 1, true) and skip then
				print("-> End marker found at line " .. idx .. ". Stopping skip.")
				end_index = idx + 1 -- start keeping from the line after end marker
				break
			end
		end

		-- insert the remaining lines after the end marker
		if end_index then
			for i = end_index + 1, #Lines do
				table.insert(NewLines, Lines[i])
			end
		end

		Content = table.concat(NewLines, "\n")
		print("Old block removed. Content updated.")

		-- regenerate blocks
		local status, GenLines =
			Generator.ExecutableTarget(Basename, RelativePath, selected, M.Config.MakefileVars, RootPath)
		if not status then
			vim.notify(
				"Failed to regenerate target. Missing include paths for: " .. table.concat(GenLines, ", "),
				vim.log.levels.ERROR
			)
			if callback then
				callback(false)
			end
			return
		end

		-- write back Makefile
		local Success, WriteErr = Utils.WriteFile(MakefilePath, Content .. "\n" .. table.concat(GenLines, "\n"))
		if not Success then
			vim.notify("Failed to write Makefile: " .. WriteErr, vim.log.levels.ERROR)
			if callback then
				callback(false)
			end
			return
		end

		vim.notify("Edited target: " .. ExeName .. " with " .. #selected .. " dependencies", vim.log.levels.INFO)
		if callback then
			callback(true)
		end
	end, { prompt_title = "Select new dependencies for " .. ExeName })
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
		M.EditTarget(MakefilePath, CurrentFile, Root.Path, MakefileContent)
	elseif Arg == "run" then
		Success = M.RunTarget(MakefilePath, CurrentFile, MakefileContent)
	elseif Arg == "tasks" then
		M.PickAndRunTargets(MakefileContent)
	elseif Arg == "edit_all" then
		M.EditAllTargets(MakefileContent, MakefilePath, Root.Path)
	else
		vim.notify("Unknown command: " .. Arg .. ". Use: add, edit, run, or open", vim.log.levels.WARN)
	end

	return Success
end

return M
