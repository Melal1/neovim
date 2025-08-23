vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    -- First command: MeCrtCmpF
    vim.api.nvim_buf_create_user_command(0, "MeCrtCmpF", function(opts)
      local level = tonumber(opts.args) or 4
      require("config.utils.cpp").createCompFlags(level)
    end, {
      nargs = "?",
      desc = "Create a compile_flags.txt file for the current project",
    })

    -- Second command: ClangdSetup
    vim.api.nvim_buf_create_user_command(0, "ClangdSetup", function()
      local cwd = vim.fn.getcwd()
      local cmake_file = cwd .. "/CMakeLists.txt"
      local clangd_file = cwd .. "/.clangd"

      -- Check if CMakeLists.txt already exists
      local cmake_exists = vim.fn.filereadable(cmake_file) == 1

      -- Check if .clangd already exists
      local clangd_exists = vim.fn.filereadable(clangd_file) == 1

      if not cmake_exists then
        vim.notify("Writing CMakeLists.txt...")
        local cmake_content = [[
cmake_minimum_required(VERSION 3.8)
project(my_project)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

file(GLOB_RECURSE sources
    "*.c"
    "*.cpp"
    "src/*.c"
    "src/*.cpp"
)

add_executable(my_app ${sources})

target_include_directories(my_app PUBLIC
    "${CMAKE_SOURCE_DIR}/include"
)
]]
        vim.fn.writefile(vim.split(cmake_content, "\n"), cmake_file)
      end

      if not clangd_exists then
        vim.notify("Writing .clangd file...")
        local clangd_content = [[
CompileFlags:
  CompilationDatabase: "cmake"
]]
        vim.fn.writefile(vim.split(clangd_content, "\n"), clangd_file)
      end

      vim.notify("Running CMake to generate compile_commands.json...")
      vim.fn.system('cmake -S . -G "Unix Makefiles" -B cmake')
      vim.notify("Restarting lsp")
      vim.cmd("e!")

    end, {})
  end,
})
