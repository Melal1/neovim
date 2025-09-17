-- Constants to avoid magic strings
local CMAKE_DIR = "cmake"
local CMAKE_FILE = "CMakeLists.txt"
local CLANGD_FILE = ".clangd"
local CLANG_TIDY_FILE = ".clang-tidy"
local PROJECT_MARKERS = { "include", "src", ".git" }
local CPP_STANDARDS = { "11", "14", "17", "20", "23" }

vim.api.nvim_create_autocmd("FileType", {
	pattern = "cpp",
	callback = function()
		-- Check if a path exists (file or directory)
		local function path_exists(path)
			return vim.fn.isdirectory(path) == 1 or vim.fn.filereadable(path) == 1
		end

		-- Walk up directory tree to find project root based on common markers
		local function find_project_root(start_dir)
			local dir = vim.fn.fnamemodify(start_dir, ":p")
			while dir and dir ~= "/" do
				for _, marker in ipairs(PROJECT_MARKERS) do
					if path_exists(dir .. "/" .. marker) then
						return dir
					end
				end
				local parent = vim.fn.fnamemodify(dir, ":h")
				if parent == dir then
					break
				end
				dir = parent
			end
			return nil
		end

		-- Get the project working directory, trying buffer location first
		local function get_project_cwd()
			local buf_dir = vim.fn.expand("%:p:h")
			if buf_dir ~= "" then
				local root = find_project_root(buf_dir)
				if root then
					return root
				end
			end

			local cwd = vim.fn.getcwd()
			return find_project_root(cwd)
		end

		-- Execute cmake configuration in specified directory
		local function run_cmake(cwd)
			local oldcwd = vim.fn.getcwd()
			vim.fn.chdir(cwd)
			vim.fn.system('cmake -S . -G "Unix Makefiles" -B ' .. CMAKE_DIR)
			vim.fn.chdir(oldcwd)
		end

		-- Get all C/C++ source files from src directory
		local function get_source_files(cwd)
			local cpp_files = vim.fn.globpath(cwd .. "/src", "**/*.cpp", true, true)
			local c_files = vim.fn.globpath(cwd .. "/src", "**/*.c", true, true)
			return vim.list_extend(cpp_files, c_files)
		end

		-- Convert absolute paths to relative cmake format
		local function format_sources_for_cmake(files)
			local formatted = {}
			for _, file in ipairs(files) do
				local rel_path = vim.fn.fnamemodify(file, ":.")
				table.insert(formatted, "   ${CMAKE_CURRENT_SOURCE_DIR}/" .. rel_path)
			end
			return formatted
		end

		-- Create CMakeLists.txt with specified standard and source files
		local function generate_cmake(cpp_std, cwd, files)
			local cmake_path = cwd .. "/" .. CMAKE_FILE
			local oldcwd = vim.fn.getcwd()
			vim.cmd("cd " .. cwd)

			local formatted_files = format_sources_for_cmake(files)
			local sources_block = "set(sources\n" .. table.concat(formatted_files, "\n") .. "\n)\n"

			local cmake_content = string.format(
				[[
cmake_minimum_required(VERSION 3.10)
project(my_project)
set(CMAKE_CXX_STANDARD %s)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
%s
add_executable(my_app ${sources})
target_include_directories(my_app PUBLIC
"${CMAKE_SOURCE_DIR}/include"
)
]],
				cpp_std,
				sources_block
			)

			vim.fn.writefile(vim.split(cmake_content, "\n"), cmake_path)
			vim.notify("Created CMakeLists.txt successfully")

			-- Generate .clangd config for LSP integration
			local clangd_content = [[
CompileFlags:
CompilationDatabase: "cmake"
]]
			vim.fn.writefile(vim.split(clangd_content, "\n"), cwd .. "/" .. CLANGD_FILE)
			vim.notify("Generated .clangd configuration")

			run_cmake(cwd)
			vim.cmd("wa | e!")
			vim.cmd("cd " .. oldcwd)
		end

		-- Extract existing source files from CMakeLists.txt
		local function get_existing_sources(cmake_path)
			local existing = {}
			local lines = vim.fn.readfile(cmake_path)

			for _, line in ipairs(lines) do
				local file = line:match("^%s*(.-)$")
				if file ~= "" and (file:match("%.c$") or file:match("%.cpp$")) then
					existing[file] = true
				end
			end
			return existing, lines
		end

		-- Initial project setup with CMake generation
		vim.api.nvim_create_user_command("CmakeInit", function()
			local cwd = get_project_cwd()
			if not cwd then
				vim.notify(
					"Couldn't find a project directory. Make sure you have 'include' and 'src' folders",
					vim.log.levels.ERROR
				)
				return
			end

			if vim.fn.input("Found project at " .. cwd .. ". Continue? (Y/n): "):lower() == "n" then
				vim.notify("Setup cancelled")
				return
			end

			local cmake_path = cwd .. "/" .. CMAKE_FILE
			if vim.fn.filereadable(cmake_path) == 1 then
				vim.notify("CMakeLists.txt already exists here")
				return
			end

			vim.ui.select(CPP_STANDARDS, { prompt = "Choose C++ Standard:" }, function(choice)
				if not choice then
					vim.notify("No standard selected, cancelling setup")
					return
				end

				local all_files = get_source_files(cwd)
				local picker = require("config.utils.pick")
				if not picker.available then
					vim.notify("Need Telescope for file selection", vim.log.levels.ERROR)
					return
				end

				picker.pick_files(all_files, function(selected)
					if not selected or #selected == 0 then
						vim.notify("No files picked, skipping CMakeLists creation")
						return
					end
					generate_cmake(choice, cwd, selected)
				end)
			end)
		end, {})

		-- Unified command for all cmake operations
		vim.api.nvim_create_user_command("CmakeSet", function(opts)
			local arg = opts.args and opts.args:lower() or ""

			local cwd = get_project_cwd()
			if not cwd then
				vim.notify("Can't find project directory", vim.log.levels.ERROR)
				return
			end

			if arg == "" then
				-- Show selection menu
				local options = {
					"addfile - Add current file to CMakeLists",
					"addall - Add all new source files",
					"remove - Remove selected files from CMakeLists",
					"clean - Remove missing files from CMakeLists",
					"std - Change C++ standard version",
					"delete - Delete cmake files and CMakeLists.txt",
					"tidy - Generate .clang-tidy config",
				}

				vim.ui.select(options, {
					prompt = "Choose CMake operation:",
					format_item = function(item)
						return item
					end,
				}, function(choice)
					if not choice then
						vim.notify("No operation selected")
						return
					end

					local operation = choice:match("^([^%s]+)")
					vim.cmd("CmakeSet " .. operation)
				end)
			elseif arg == "addfile" then
				-- Add current file to existing CMakeLists.txt

				local cmake_path = cwd .. "/" .. CMAKE_FILE
				if vim.fn.filereadable(cmake_path) == 0 then
					vim.notify("No CMakeLists.txt found. Run :CmakeInit first", vim.log.levels.ERROR)
					return
				end

				local file_name = vim.fn.fnamemodify(vim.fn.expand("%:."), ":.")
				local cmake_entry = "   ${CMAKE_CURRENT_SOURCE_DIR}/" .. file_name
				local lines = vim.fn.readfile(cmake_path)

				-- Check if file already exists in cmake
				for _, line in ipairs(lines) do
					if line:find(cmake_entry, 1, true) then
						vim.notify("File already in CMakeLists")
						return
					end
				end

				-- Insert before closing parenthesis
				for i, line in ipairs(lines) do
					if line:match("^%)") or line:match("^%)%s*$") then
						table.insert(lines, i, cmake_entry)
						break
					end
				end

				vim.fn.writefile(lines, cmake_path)
				vim.notify("Added " .. file_name .. " to build")
				run_cmake(cwd)
				vim.notify("Build files updated")
			elseif arg == "remove" then
				-- Remove selected files from CMakeLists.txt

				local cmake_path = cwd .. "/" .. CMAKE_FILE
				if vim.fn.filereadable(cmake_path) == 0 then
					vim.notify("No CMakeLists.txt found. Run :CmakeInit first", vim.log.levels.ERROR)
					return
				end

				local lines = vim.fn.readfile(cmake_path)
				local source_files = {}
				local source_lines = {}

				-- Extract current source files from CMakeLists
				for i, line in ipairs(lines) do
					local file = line:match("^%s*(.-)$")
					if file ~= "" and (file:match("%.c$") or file:match("%.cpp$")) then
						local display_name = file:gsub("%${CMAKE_CURRENT_SOURCE_DIR}/", "")
						table.insert(source_files, display_name)
						source_lines[display_name] = i
					end
				end

				if #source_files == 0 then
					vim.notify("No source files found in CMakeLists")
					return
				end

				local picker = require("config.utils.pick")
				if not picker.available then
					vim.notify("Need Telescope for file selection", vim.log.levels.ERROR)
					return
				end

				picker.pick_files(source_files, function(selected)
					if not selected or #selected == 0 then
						vim.notify("No files selected for removal")
						return
					end

					-- Remove selected files from lines (in reverse order to maintain indices)
					local indices_to_remove = {}
					for _, file in ipairs(selected) do
						if source_lines[file] then
							table.insert(indices_to_remove, source_lines[file])
						end
					end

					table.sort(indices_to_remove, function(a, b)
						return a > b
					end)
					for _, idx in ipairs(indices_to_remove) do
						table.remove(lines, idx)
					end

					vim.fn.writefile(lines, cmake_path)
					vim.notify(string.format("Removed %d files from CMakeLists", #selected))
					run_cmake(cwd)
					vim.notify("Build configuration updated")
				end)
			elseif arg == "std" then
				-- Change C++ standard version

				local cmake_path = cwd .. "/" .. CMAKE_FILE
				if vim.fn.filereadable(cmake_path) == 0 then
					vim.notify("No CMakeLists.txt found. Run :CmakeInit first", vim.log.levels.ERROR)
					return
				end

				vim.ui.select(CPP_STANDARDS, { prompt = "Choose new C++ Standard:" }, function(choice)
					if not choice then
						vim.notify("No standard selected")
						return
					end

					local lines = vim.fn.readfile(cmake_path)
					local updated = false

					for i, line in ipairs(lines) do
						if line:match("^set%(CMAKE_CXX_STANDARD") then
							lines[i] = "set(CMAKE_CXX_STANDARD " .. choice .. ")"
							updated = true
							break
						end
					end

					if updated then
						vim.fn.writefile(lines, cmake_path)
						vim.notify("Updated C++ standard to " .. choice)
						run_cmake(cwd)
						vim.notify("Build configuration updated")
					else
						vim.notify("Could not find CMAKE_CXX_STANDARD line in CMakeLists", vim.log.levels.ERROR)
					end
				end)
			elseif arg == "clean" then
				-- Remove missing files from CMakeLists.txt

				local cmake_path = cwd .. "/" .. CMAKE_FILE
				if vim.fn.filereadable(cmake_path) == 0 then
					vim.notify("No CMakeLists.txt found. Run :CmakeInit first", vim.log.levels.ERROR)
					return
				end

				local lines = vim.fn.readfile(cmake_path)
				local cleaned_lines = {}
				local removed_count = 0

				for _, line in ipairs(lines) do
					local file = line:match("^%s*(.-)$")
					if file ~= "" and (file:match("%.c$") or file:match("%.cpp$")) then
						local real_path = file:gsub("%${CMAKE_CURRENT_SOURCE_DIR}", cwd)
						if vim.fn.filereadable(real_path) == 0 then
							removed_count = removed_count + 1
						else
							table.insert(cleaned_lines, line)
						end
					else
						table.insert(cleaned_lines, line)
					end
				end

				vim.fn.writefile(lines, cmake_path)
				if removed_count > 0 then
					vim.notify(string.format("Removed %d missing files", removed_count))
				else
					vim.notify("No missing files found")
				end

				run_cmake(cwd)
				vim.notify("Build configuration refreshed")
			elseif arg == "delete" then
				-- Delete cmake build directory and CMakeLists.txt

				local cmake_build_dir = cwd .. "/" .. CMAKE_DIR
				if not path_exists(cmake_build_dir) then
					vim.notify("No cmake build directory found at " .. cmake_build_dir, vim.log.levels.ERROR)
					return
				end

				if vim.fn.input("Really delete cmake files? This can't be undone (y/N): ") ~= "y" then
					vim.notify("Deletion cancelled")
					return
				end

				vim.notify("Removing cmake files...", vim.log.levels.WARN)
				vim.fn.delete(cmake_build_dir, "rf")
				vim.fn.delete(cwd .. "/" .. CMAKE_FILE)
				vim.notify("Cmake files deleted")
			elseif arg == "addall" then
				-- Add all new source files to CMakeLists.txt

				local cmake_path = cwd .. "/" .. CMAKE_FILE
				if vim.fn.filereadable(cmake_path) == 0 then
					vim.notify("No CMakeLists.txt found. Run :CmakeInit first", vim.log.levels.ERROR)
					return
				end

				local existing_files, lines = get_existing_sources(cmake_path)
				local all_files = get_source_files(cwd)
				local added_count = 0

				for _, file in ipairs(all_files) do
					local rel_path = vim.fn.fnamemodify(file, ":.")
					local cmake_entry = "${CMAKE_CURRENT_SOURCE_DIR}/" .. rel_path

					if not existing_files[cmake_entry] then
						for i, line in ipairs(lines) do
							if line:match("^%)") or line:match("^%)%s*$") then
								table.insert(lines, i, "   " .. cmake_entry)
								added_count = added_count + 1
								break
							end
						end
					end
				end

				vim.fn.writefile(lines, cmake_path)
				if added_count > 0 then
					vim.notify(string.format("Added %d new files to build", added_count))
				else
					vim.notify("All source files already included")
				end

				run_cmake(cwd)
				vim.notify("Build configuration updated")
			elseif arg == "tidy" then
				-- Generate .clang-tidy configuration file

				local tidy_path = cwd .. "/" .. CLANG_TIDY_FILE
				if vim.fn.filereadable(tidy_path) == 1 then
					if vim.fn.input(".clang-tidy exists. Replace it? (y/N): "):lower() ~= "y" then
						vim.notify("Keeping existing .clang-tidy file")
						return
					end
				end

				local tidy_config = [[
Checks: >
-*,
bugprone-*,
performance-*,
readability-*,-readability-magic-numbers,
modernize-*,-modernize-use-trailing-return-type
WarningsAsErrors: ''
HeaderFilterRegex: ''
FormatStyle: none
]]
				vim.fn.writefile(vim.split(tidy_config, "\n"), tidy_path)
				vim.cmd("w | e!")
				vim.notify("Created .clang-tidy with sensible defaults")
			else
				vim.notify(
					"Unknown operation: " .. arg .. ". Available: addfile, addall, remove, clean, std, delete, tidy",
					vim.log.levels.ERROR
				)
			end
		end, {
			nargs = "?",
			complete = function()
				return { "addfile", "addall", "remove", "clean", "std", "delete", "tidy" }
			end,
			desc = "CMake operations: addfile, addall, remove, clean, std, delete, tidy (no args for menu)",
		})
	end,
})
