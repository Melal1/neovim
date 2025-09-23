local Utils = require("config.utils.make.utils")
local Parser = {}

function Parser.ParseVariables(Content)
	local Variables = {}
	if not Content then
		return Variables
	end
	for Line in Content:gmatch("[^\n]+") do
		Line = Line:match("^%s*(.-)%s*$")
		if Line and Line ~= "" and not Line:match("^#") then
			local VarName, VarValue = Line:match("^([%w_]+)%s*:?=%s*(.*)$")
			if VarName and VarValue then
				Variables[VarName] = VarValue
			end
		end
	end

	return Variables
end

function Parser.HasReqVars(Content, MakefileVars)
	if not Content then
		return false
	end
	local Variables = Parser.ParseVariables(Content)
	for VarName, _ in pairs(MakefileVars) do
		if not Variables[VarName] then
			return false
		end
	end
	return true
end

function Parser.FindMarker(Content, RelativePath, CheckStart, CheckEnd)
	local info = { M_start = nil, M_end = nil }
	local escapedPath = Utils.EscapePattern(RelativePath)
	local lineNumber = 0
	if not CheckStart then
		info.M_start = -1
	end
	if not CheckEnd then
		info.M_end = -1
	end

	if info.M_start == -1 and info.M_end == -1 then
		return info
	end
	for line in Content:gmatch("([^\n]*)\n?") do
		lineNumber = lineNumber + 1
		local trimmedLine = line:match("^%s*(.-)%s*$")
		if not trimmedLine:match("^%s*#") or trimmedLine == "" then
			goto continue
		end
		if not info.M_start and CheckStart then
			if trimmedLine:match("^%s*#%s*marker_start%s*:%s*" .. escapedPath) then
				print("Start marker at line " .. lineNumber .. " with text: " .. trimmedLine)
				info.M_start = lineNumber
				if not CheckEnd then
					return info
				end
			end
		end
		if not info.M_end and info.M_start and CheckEnd then
			if trimmedLine:match("^%s*#%s*marker_end%s*:%s*" .. escapedPath) then
				print("Found End marker at line " .. lineNumber .. " with text: " .. trimmedLine)
				info.M_end = lineNumber
				return info
			end
		end
		::continue::
	end
	return info
end

function Parser.FindAllMarkerPairs(Content)
	local allPairs = {}
	local openMarkers = {}
	local lineNumber = 0
	if not Content then
		return allPairs
	end
	for line in Content:gmatch("([^\n]*)\n?") do
		lineNumber = lineNumber + 1
		local trimmedLine = line:match("^%s*(.-)%s*$")
		if trimmedLine:match("^%s*#") then
			local startPath = trimmedLine:match("^%s*#%s*marker_start%s*:%s*(.*)$")
			if startPath then
				openMarkers[startPath] = lineNumber
			end
			local endPath = trimmedLine:match("^%s*#%s*marker_end%s*:%s*(.*)$")
			if endPath then
				local startLine = openMarkers[endPath]
				if startLine then
					table.insert(allPairs, {
						path = endPath,
						StartLine = startLine,
						EndLine = lineNumber,
					})
					openMarkers[endPath] = nil
				end
			end
		end
	end
	return allPairs
end

function Parser.ReadContentBetweenMarkers(Content, RelativePath)
	local contentLines = {}
	local currentLineNumber = 0
	local markerInfo = Parser.FindMarker(Content, RelativePath, true, true)
	local StartLine = markerInfo.M_start
	local EndLine = markerInfo.M_end
	if StartLine == -1 or EndLine == -1 then
		return ""
	end
	for line in Content:gmatch("([^\n]*)\n?") do
		currentLineNumber = currentLineNumber + 1
		if currentLineNumber > StartLine and currentLineNumber < EndLine then
			table.insert(contentLines, line)
		end
	end
	return table.concat(contentLines, "\n")
end

function Parser.TargetExists(Content, TargetName)
	if not Content then
		return false
	end
	local markerInfo = Parser.FindMarker(Content, TargetName, true, false)
	return markerInfo.M_start ~= nil
end

function Parser.ParseDependencies(targetLine)
	local dependencies = {}

	local depString = targetLine:match("^[^:]*:%s*(.*)$")
	if not depString then
		return dependencies
	end

	for dep in depString:gmatch("%S+") do
		table.insert(dependencies, dep)
	end

	return dependencies
end

function Parser.ParseTarget(sectionContent, targetName)
	local target = {
		name = targetName,
		dependencies = {},
		recipe = {},
		found = false,
	}

	local lines = {}
	for line in sectionContent:gmatch("[^\n]+") do
		table.insert(lines, line)
	end

	local i = 1
	while i <= #lines do
		local line = lines[i]
		local trimmedLine = line:match("^%s*(.-)%s*$")

		local targetPattern = "^" .. Utils.EscapePattern(targetName) .. "%s*:"
		if trimmedLine:match(targetPattern) then
			target.found = true
			target.dependencies = Parser.ParseDependencies(trimmedLine)

			i = i + 1
			while i <= #lines do
				local nextLine = lines[i]
				if nextLine:match("^%s+") and not nextLine:match("^%s*#") then
					table.insert(target.recipe, nextLine:match("^%s*(.*)$"))
					i = i + 1
				else
					break
				end
			end
			break
		end
		i = i + 1
	end

	return target
end

function Parser.AnalyzeSection(sectionContent, baseName)
	if not sectionContent or sectionContent == "" then
		return {
			hasObj = false,
			hasExecutable = false,
			hasRun = false,
			type = "empty",
			targets = {},
		}
	end

	local hasObj = false
	local hasExecutable = false
	local hasRun = false
	local targets = {}

	if not baseName then
		baseName = sectionContent:match("([^/]+)%.cpp") or ""
		baseName = baseName:gsub("%.cpp$", "")
	end

	for line in sectionContent:gmatch("[^\n]+") do
		local trimmedLine = line:match("^%s*(.-)%s*$")

		if trimmedLine == "" or trimmedLine:match("^#") then
			goto continue
		end

		local targetName = trimmedLine:match("^([^:]+):")
		if targetName then
			targetName = targetName:match("^%s*(.-)%s*$")

			local targetInfo = Parser.ParseTarget(sectionContent, targetName)
			if targetInfo.found then
				table.insert(targets, targetInfo)
			end

			if targetName:match("%.o$") then
				hasObj = true
			elseif targetName == baseName then
				hasExecutable = true
			elseif targetName == "run" .. baseName then
				hasRun = true
			end
		end

		::continue::
	end

	local targetType
	if hasObj and hasExecutable and hasRun then
		targetType = "full"
	elseif hasObj and hasExecutable then
		targetType = "executable"
	elseif hasObj then
		targetType = "obj"
	elseif hasRun then
		targetType = "run"
	else
		targetType = "unknown"
	end

	return {
		hasObj = hasObj,
		hasExecutable = hasExecutable,
		hasRun = hasRun,
		type = targetType,
		targets = targets,
	}
end

function Parser.AnalyzeAllSections(Content)
	local allPairs = Parser.FindAllMarkerPairs(Content)
	local sectionAnalysis = {}

	for _, pair in ipairs(allPairs) do
		local sectionContent = Parser.ReadContentBetweenMarkers(Content, pair.path)

		local baseName = pair.path:match("([^/]+)%.cpp$")
		if baseName then
			baseName = baseName:gsub("%.cpp$", "")
		end

		local analysis = Parser.AnalyzeSection(sectionContent, baseName)

		table.insert(sectionAnalysis, {
			path = pair.path,
			baseName = baseName,
			startLine = pair.StartLine,
			endLine = pair.EndLine,
			analysis = analysis,
		})
	end

	return sectionAnalysis
end

function Parser.GetSectionsByType(Content, targetType)
	local allSections = Parser.AnalyzeAllSections(Content)
	local filteredSections = {}

	for _, section in ipairs(allSections) do
		if section.analysis.type == targetType then
			table.insert(filteredSections, section)
		end
	end

	return filteredSections
end

function Parser.GetExecutableDetails(Content, executableName)
	local allSections = Parser.AnalyzeAllSections(Content)

	for _, section in ipairs(allSections) do
		if section.baseName == executableName then
			for _, target in ipairs(section.analysis.targets) do
				if target.name == executableName and not target.name:match("%.o$") then
					return {
						name = target.name,
						dependencies = target.dependencies,
						recipe = target.recipe,
						section = section,
					}
				end
			end
		end
	end

	return nil
end

function Parser.PrintAnalysisSummary(Content)
	local allSections = Parser.AnalyzeAllSections(Content)

	print("Makefile Section Analysis:")
	print("=" .. string.rep("=", 50))

	for _, section in ipairs(allSections) do
		local analysis = section.analysis
		print(string.format("Path: %s", section.path))
		print(string.format("Base Name: %s", section.baseName or "N/A"))
		print(string.format("Type: %s", analysis.type))
		print(string.format("Has Object: %s", analysis.hasObj and "Yes" or "No"))
		print(string.format("Has Executable: %s", analysis.hasExecutable and "Yes" or "No"))
		print(string.format("Has Run: %s", analysis.hasRun and "Yes" or "No"))

		if #analysis.targets > 0 then
			print("Targets:")
			for _, target in ipairs(analysis.targets) do
				print(string.format("  - %s", target.name))
				if #target.dependencies > 0 then
					print(string.format("    Dependencies: %s", table.concat(target.dependencies, ", ")))
				end
				if #target.recipe > 0 then
					print("    Recipe:")
					for _, recipeLine in ipairs(target.recipe) do
						print(string.format("      %s", recipeLine))
					end
				end
			end
		end
		print(string.rep("-", 50))
	end
end

return Parser
