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

function Parser.HasBuildVariables(Content, MakefileVars)
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

function Parser.ParseTargets(Content)
	local Targets = {}
	if not Content then
		return Targets
	end

	local NormalizedContent = Content:gsub("\\\n", " ")

	for Line in NormalizedContent:gmatch("[^\n]+") do
		Line = Line:match("^%s*(.-)%s*$")
		if Line and Line ~= "" and not Line:match("^#") then
			local Target = Line:match("^([%w%._%-/]+)%s*:")
			if Target then
				local TargetInfo = {
					Name = Target,
					IsObject = Target:match("%.o$") ~= nil,
					IsExecutable = Target:match("%.o$") == nil and not Target:match("^run"),
					IsRunTarget = Target:match("^run") ~= nil,
					FullLine = Line,
				}
				Targets[Target] = TargetInfo
			end
		end
	end

	return Targets
end

function Parser.TargetExists(Content, TargetName)
	if not Content then
		return false
	end

	local Pattern = "^%s*" .. Utils.EscapePattern(TargetName) .. "%s*:"
	for Line in Content:gmatch("[^\n]+") do
		if Line:match(Pattern) then
			return true
		end
	end
	return false
end

function Parser.GetObjectFiles(Targets)
	local ObjectFiles = {}
	for Name, Info in pairs(Targets) do
		if Info.IsObject then
			table.insert(ObjectFiles, Name)
		end
	end
	return ObjectFiles
end

function Parser.ParseDependencies(Line)
	local Deps = {}
	local DepString = Line:match("^([^:]+):%s*(.*)$")
	if DepString then
		for Dep in DepString:gmatch("%S+") do
			table.insert(Deps, Dep)
		end
	end
	return Deps
end

return Parser
