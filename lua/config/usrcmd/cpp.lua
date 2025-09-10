vim.api.nvim_create_autocmd("FileType", {
	pattern = "cpp",
	callback = function()
		local function run_cmake(cwd)
			local oldcwd = vim.fn.getcwd()
			vim.fn.chdir(cwd)
			vim.fn.system('cmake -S . -G "Unix Makefiles" -B cmake')
			vim.fn.chdir(oldcwd)
		end

		local function path_exists(path)
			return vim.fn.isdirectory(path) == 1 or vim.fn.filereadable(path) == 1
		end

		local function find_project_root(start_dir)
			local markers = { "include", "src", ".git" }
			local dir = vim.fn.fnamemodify(start_dir, ":p")
			while dir and dir ~= "/" do
				for _, marker in ipairs(markers) do
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

		local function get_project_cwd()
			local buf_dir = vim.fn.expand("%:p:h")
			if buf_dir ~= "" then
				local root = find_project_root(buf_dir)
				if root then
					return root
				end
			end
			local cwd = vim.fn.getcwd()
			local root = find_project_root(cwd)
			if root then
				return root
			end
			return nil
		end

		local function generate_cmake(cpp_std, cwd, files)
			local cmake_file = cwd .. "/CMakeLists.txt"
			local oldcwd = vim.fn.getcwd()
			vim.cmd("cd " .. cwd)

			for i, f in ipairs(files) do
				files[i] = vim.fn.fnamemodify(f, ":.")
				files[i] = "   ${CMAKE_CURRENT_SOURCE_DIR}/" .. files[i]
			end

			local sources_block = "set(sources\n" .. table.concat(files, "\n") .. "\n)\n"

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

			vim.fn.writefile(vim.split(cmake_content, "\n"), cmake_file)
			vim.notify("CMakeLists.txt created.", vim.log.levels.INFO)

			local clangd_file = cwd .. "/.clangd"
			local clangd_content = [[
CompileFlags:
  CompilationDatabase: "cmake"
]]

			vim.fn.writefile(vim.split(clangd_content, "\n"), clangd_file)
			vim.notify("Generated .clangd file.", vim.log.levels.INFO)

			vim.fn.chdir(cwd)
			vim.fn.system('cmake -S . -G "Unix Makefiles" -B cmake')
			vim.fn.chdir(oldcwd)

			vim.cmd("wa | e!")
			vim.cmd("cd " .. oldcwd)
		end

		vim.api.nvim_create_user_command("CmakeSetup", function()
			local cwd = get_project_cwd()
			if not cwd then
				vim.notify(
					"No valid directory structure found. Ensure 'include' and 'src' directories exist.",
					vim.log.levels.ERROR
				)
				return
			end
			if vim.fn.input("Root dir is " .. cwd .. " is this okay ? (Y/n)"):lower() == "n" then
				vim.notify("Canceled setup.", vim.log.levels.INFO)
				return
			end

			local cmake_file = cwd .. "/CMakeLists.txt"
			if vim.fn.filereadable(cmake_file) == 1 then
				vim.notify("CMakeLists.txt already exists. Skipping setup.", vim.log.levels.INFO)
				return
			end

			local standards = { "11", "14", "17", "20", "23" }
			vim.ui.select(standards, { prompt = "Select C++ Standard:" }, function(choice)
				if not choice then
					vim.notify("C++ standard selection cancelled.", vim.log.levels.INFO)
					return
				end

				local cpp_all_files = vim.fn.globpath(cwd .. "/src", "**/*.cpp", true, true)
				local c_all_files = vim.fn.globpath(cwd .. "/src", "**/*.c", true, true)
				local all_av_files = vim.list_extend(cpp_all_files, c_all_files)
				local choices = {}

				local userChoice = vim.fn.input("Include all files in src/ directory? (y/N): ")
				if userChoice:lower() ~= "y" then
					local picker = require("config.utils.pick")
					if not picker.available then
						vim.notify("Telescope is required for file selection.", vim.log.levels.ERROR)
						return
					end

					picker.pick_files(all_av_files, function(selected)
						if not selected or #selected == 0 then
							vim.notify("No files selected. CMakeLists.txt will not be created.", vim.log.levels.INFO)
							return
						end
						choices = selected
						generate_cmake(choice, cwd, choices)
					end)
				else
					choices = all_av_files
					generate_cmake(choice, cwd, choices)
				end
			end)
		end, {})

		vim.api.nvim_create_user_command("CmakeAddFile", function()
			local cwd = get_project_cwd()
			if not cwd then
				vim.notify("No valid directory structure found.", vim.log.levels.ERROR)
				return
			end
			local cmake_file = cwd .. "/CMakeLists.txt"
			if vim.fn.filereadable(cmake_file) == 0 then
				vim.notify("No CMakeLists.txt found. Run :CmakeSetup first.", vim.log.levels.ERROR)
				return
			end

			local fileName = vim.fn.fnamemodify(vim.fn.expand("%:."), ":.")
			local cur_file = "   ${CMAKE_CURRENT_SOURCE_DIR}/" .. fileName

			local lines = vim.fn.readfile(cmake_file)

			for _, line in ipairs(lines) do
				if line:find(cur_file, 1, true) then
					vim.notify(cur_file .. " already in sources.", vim.log.levels.INFO)
					return
				end
			end

			for i, line in ipairs(lines) do
				if line:match("^%)") or line:match("^%)%s*$") then
					table.insert(lines, i, "  " .. cur_file)
					break
				end
			end

			vim.fn.writefile(lines, cmake_file)
			vim.notify("Added " .. fileName .. " to sources.", vim.log.levels.INFO)

			run_cmake(cwd)
			vim.notify("CMake reconfigured.", vim.log.levels.INFO)
		end, {})

		vim.api.nvim_create_user_command("CmakeClean", function()
			local cwd = get_project_cwd()
			if not cwd then
				vim.notify("No valid directory structure found.", vim.log.levels.ERROR)
				return
			end
			local cmake_file = cwd .. "/CMakeLists.txt"
			if vim.fn.filereadable(cmake_file) == 0 then
				vim.notify("No CMakeLists.txt found. Run :CmakeSetup first.", vim.log.levels.ERROR)
				return
			end

			local lines = vim.fn.readfile(cmake_file)
			local cleaned_lines = {}
			local removed_files = {}

			for _, line in ipairs(lines) do
				local file = line:match("^%s*(.-)$")
				if file ~= "" and (file:match("%.c$") or file:match("%.cpp$")) then
					local real_path = file:gsub("%${CMAKE_CURRENT_SOURCE_DIR}", cwd)

					if vim.fn.filereadable(real_path) == 0 then
						table.insert(removed_files, file)
					else
						table.insert(cleaned_lines, line)
					end
				else
					table.insert(cleaned_lines, line)
				end
			end

			vim.fn.writefile(cleaned_lines, cmake_file)
			if #removed_files > 0 then
				vim.notify("Removed " .. #removed_files .. " missing files from sources.", vim.log.levels.INFO)
			else
				vim.notify("No missing files found in sources.", vim.log.levels.INFO)
			end

			run_cmake(cwd)
			vim.notify("CMake reconfigured.", vim.log.levels.INFO)
		end, {})

		vim.api.nvim_create_user_command("CmakeDelete", function()
			local cwd = get_project_cwd()
			if not cwd then
				vim.notify("No valid directory structure found.", vim.log.levels.ERROR)
				return
			end

			if not path_exists(cwd .. "/cmake") then
				vim.notify("No cmake build directory found.", vim.log.levels.ERROR)
				vim.notify(cwd .. "/cmake")
				return
			end

			if vim.fn.input("Are you sure you want to delete? (y/N)") ~= "y" then
				return
			end

			vim.notify("Deleting cmake build directory and CMakeLists.txt", vim.log.levels.WARN)
			vim.fn.delete(cwd .. "/cmake", "rf")
			vim.fn.delete(cwd .. "/CMakeLists.txt")

			vim.notify("Deleted cmake build directory and CMakeLists.txt", vim.log.levels.INFO)
		end, {})

		vim.api.nvim_create_user_command("CmakeAddAll", function()
			local cwd = get_project_cwd()
			if not cwd then
				vim.notify("No valid directory structure found.", vim.log.levels.ERROR)
				return
			end

			local cmake_file = cwd .. "/CMakeLists.txt"
			if vim.fn.filereadable(cmake_file) == 0 then
				vim.notify("No CMakeLists.txt found. Run :CmakeSetup first.", vim.log.levels.ERROR)
				return
			end

			local lines = vim.fn.readfile(cmake_file)
			local existing_files = {}
			for _, line in ipairs(lines) do
				local file = line:match("^%s*(.-)$")
				if file ~= "" and (file:match("%.c$") or file:match("%.cpp$")) then
					existing_files[file] = true
				end
			end

			local cpp_files = vim.fn.globpath(cwd .. "/src", "**/*.cpp", true, true)
			local c_files = vim.fn.globpath(cwd .. "/src", "**/*.c", true, true)
			local all_f = vim.list_extend(cpp_files, c_files)

			local added_files = {}
			for _, f in ipairs(all_f) do
				local rel_path = vim.fn.fnamemodify(f, ":.")
				rel_path = "${CMAKE_CURRENT_SOURCE_DIR}/" .. rel_path -- no spaces here

				if not existing_files[rel_path] then
					for i, line in ipairs(lines) do
						if line:match("^%)") or line:match("^%)%s*$") then
							table.insert(lines, i, "     " .. rel_path) -- add spaces only here
							table.insert(added_files, rel_path)
							break
						end
					end
				end
			end

			vim.fn.writefile(lines, cmake_file)
			if #added_files > 0 then
				vim.notify("Added " .. #added_files .. " new files to CMakeLists.", vim.log.levels.INFO)
			else
				vim.notify("No new files found to add.", vim.log.levels.INFO)
			end

			run_cmake(cwd)
			vim.notify("CMake reconfigured.", vim.log.levels.INFO)
		end, {
			desc = "Add all new source files (default) or headers (h) to CMakeLists",
		})
	end,
})
