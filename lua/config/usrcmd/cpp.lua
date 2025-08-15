vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    vim.api.nvim_buf_create_user_command(0, "MeCrtCmpF", function(opts)
      local level = tonumber(opts.args) or 4
      require("config.utils.cpp").createCompFlags(level)
    end, {
      nargs = "?",
      desc = "Create a compile_flags.txt file for the current project",
    })
  end,
})

