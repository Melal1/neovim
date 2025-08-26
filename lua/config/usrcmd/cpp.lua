vim.api.nvim_create_autocmd("FileType", {
	pattern = "cpp",
	callback = function()
		-- Old ( my first appr)
		-- vim.api.nvim_buf_create_user_command(0, "MeCrtCmpF", function(opts)
		-- 	local level = tonumber(opts.args) or 4
		-- 	require("config.utils.cpp").createCompFlags(level)
		-- end, {
		-- 	nargs = "?",
		-- 	desc = "Create a compile_flags.txt file for the current project",
		-- })

		-- For lsp ( renaming , include ,...etc)
    --[[ Old one was using globe "BAD" and made by ai ,
    this one is way better when making a new project run :CmakeSetup to 
    auto make CMakeLists.txt and source all of files inside src/ init ,
    when u add bunch of new files use :CmakeAddAll ,
    when u want to add current new files use :CmakeAddFile ,
    if u removed a file use :CmakeClean.
    
    ]]
		local function generate_cmake(cpp_std)
			local cwd = vim.fn.getcwd()
			local cmake_file = cwd .. "/CMakeLists.txt"

			local cpp_files = vim.fn.globpath(cwd .. "/src", "**/*.cpp", true, true)
			local c_files = vim.fn.globpath(cwd .. "/src", "**/*.c", true, true)

			local all_files = {}
			for _, f in ipairs(cpp_files) do
				table.insert(all_files, "  " .. vim.fn.fnamemodify(f, ":."))
			end
			for _, f in ipairs(c_files) do
				table.insert(all_files, "  " .. vim.fn.fnamemodify(f, ":."))
			end

			local sources_block = "set(sources\n" .. table.concat(all_files, "\n") .. "\n)\n"

			local cmake_content = string.format(
				[[
cmake_minimum_required(VERSION 3.8)
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
			vim.notify("CMakeLists.txt created with " .. #all_files .. " files.")
		end

		vim.api.nvim_create_user_command("CmakeSetup", function()
			local cmake_file = vim.fn.getcwd() .. "/CMakeLists.txt"
			if vim.fn.filereadable(cmake_file) == 1 then
				vim.notify("CMakeLists.txt already exists.", vim.log.levels.INFO)
				return
			end

			local standards = { "11", "14", "17", "20", "23" }
			vim.ui.select(standards, { prompt = "Select C++ Standard:" }, function(choice)
				if not choice then
					return
				end
				generate_cmake(choice)

				local clangd_file = vim.fn.getcwd() .. "/.clangd"
				local clangd_content = [[
CompileFlags:
  CompilationDatabase: "cmake"
]]
				vim.fn.writefile(vim.split(clangd_content, "\n"), clangd_file)

				vim.fn.system('cmake -S . -G "Unix Makefiles" -B cmake')
				vim.notify("CMake configured.")
				vim.cmd("e!")
			end)
		end, {})

		vim.api.nvim_create_user_command("CmakeAddFile", function()
			local cmake_file = vim.fn.getcwd() .. "/CMakeLists.txt"
			if vim.fn.filereadable(cmake_file) == 0 then
				vim.notify("No CMakeLists.txt found. Run :CmakeSetup first.", vim.log.levels.ERROR)
				return
			end

			local cur_file = vim.fn.fnamemodify(vim.fn.expand("%:."), ":.")
			local lines = vim.fn.readfile(cmake_file)

			for _, line in ipairs(lines) do
				if line:find(cur_file, 1, true) then
					vim.notify(cur_file .. " already in sources.", vim.log.levels.INFO)
					return
				end
			end

			for i, line in ipairs(lines) do
				if line:match("^%)") or line:match("^%)%s*$") then
					table.insert(lines, i, "  " .. cur_file)
					break
				end
			end

			vim.fn.writefile(lines, cmake_file)
			vim.notify("Added " .. cur_file .. " to sources in CMakeLists.txt.")

			vim.fn.system('cmake -S . -G "Unix Makefiles" -B cmake')
			vim.notify("CMake reconfigured.")
		end, {})

		vim.api.nvim_create_user_command("CmakeClean", function()
			local cmake_file = vim.fn.getcwd() .. "/CMakeLists.txt"
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
					if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. file) == 0 then
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
				vim.notify("Removed missing files from sources:\n" .. table.concat(removed_files, "\n"))
			else
				vim.notify("No missing files found in sources.")
			end

			vim.fn.system('cmake -S . -G "Unix Makefiles" -B cmake')
			vim.notify("CMake reconfigured after cleaning.")
		end, {})

		vim.api.nvim_create_user_command("CmakeAddAll", function()
			local cmake_file = vim.fn.getcwd() .. "/CMakeLists.txt"
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

			local cwd = vim.fn.getcwd()
			local cpp_files = vim.fn.globpath(cwd .. "/src", "**/*.cpp", true, true)
			local c_files = vim.fn.globpath(cwd .. "/src", "**/*.c", true, true)
			local all_files = vim.list_extend(cpp_files, c_files)

			local added_files = {}
			for _, f in ipairs(all_files) do
				local rel_path = vim.fn.fnamemodify(f, ":.")
				if not existing_files[rel_path] then
					for i, line in ipairs(lines) do
						if line:match("^%)") or line:match("^%)%s*$") then
							table.insert(lines, i, "  " .. rel_path)
							table.insert(added_files, rel_path)
							break
						end
					end
				end
			end

			vim.fn.writefile(lines, cmake_file)
			if #added_files > 0 then
				vim.notify("Added new files to CMakeLists:\n" .. table.concat(added_files, "\n"))
			else
				vim.notify("No new files found to add.")
			end

			vim.fn.system('cmake -S . -G "Unix Makefiles" -B cmake')
			vim.notify("CMake reconfigured after adding new files.")
		end, {})
		-- End here
    
	end,
})
