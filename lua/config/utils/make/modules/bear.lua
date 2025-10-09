local Parser = require("config.utils.make.parser")
local Utils = require("config.utils.make.utils")

---@class Bear
local M = {}

---Run bear for the current file
---@param Content string Makefile content
---@param Rootdir string Root directory of the project
---@return boolean success True if bear succeeded
function M.CurrentFile(Content, Rootdir)
	local Vars = Parser.ParseVariables(Content)
	local BuildDir = Vars["BUILD_DIR"]
	local RelativePath = Utils.GetRelativePath(vim.fn.expand("%"), Rootdir)

	if not RelativePath then
		return false
	end

	local Targets = Parser.AnalyzeAllSections(Content)

	for _, Ent in ipairs(Targets) do
		if (Ent.analysis.type == "full" or Ent.analysis.type == "obj") and Ent.path == RelativePath then
			for _, Target in ipairs(Ent.analysis.targets) do
				if Target.name:match("^%$%(BUILD_DIR%).+%.o$") then
					local ModifiedName = Target.name:gsub("%$%(BUILD_DIR%)", BuildDir)
					local cmd = string.format(
						"cd %s && bear --append -- make -B %s",
						vim.fn.shellescape(Rootdir),
						vim.fn.shellescape(ModifiedName)
					)

					local output = vim.fn.system(cmd)

					if vim.v.shell_error ~= 0 then
						vim.notify(
							"Bear failed for target: " .. ModifiedName .. "\nError: " .. tostring(output),
							vim.log.levels.ERROR,
							{ title = "Make + Bear" }
						)
						return false
					end

					return true
				end
			end
		end
	end

	return false
end

---Run bear for specific target lines
---@param Lines string[] Target lines
---@param Rootdir string Root directory of the project
---@param BuildDir string Build directory as specified in Makefile
---@return boolean success True if bear succeeded
function M.Target(Lines, Rootdir, BuildDir)
	for _, Line in ipairs(Lines) do
		-- Match object file targets
		local targetName = Line:match("^([^:]+):")
		if targetName and targetName:match("^%$%(BUILD_DIR%).+%.o$") then
			local ModifiedName = targetName:gsub("%$%(BUILD_DIR%)", BuildDir):match("^%s*(.-)%s*$")
			local cmd = string.format(
				"cd %s && bear --append -- make -B %s",
				vim.fn.shellescape(Rootdir),
				vim.fn.shellescape(ModifiedName)
			)

			local output = vim.fn.system(cmd)

			if vim.v.shell_error ~= 0 then
				vim.notify(
					"Bear failed for target: " .. ModifiedName .. "\nError: " .. tostring(output),
					vim.log.levels.ERROR,
					{ title = "Make + Bear" }
				)
				return false
			end

			return true
		end
	end

	return false
end

return M
