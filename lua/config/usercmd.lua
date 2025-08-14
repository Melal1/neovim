-- Create compile_flags.txt file for cpp 
vim.api.nvim_create_user_command(
    'MeCrtCmpF',
    function(opts)
        local level = tonumber(opts.args) or 4
        require('config.utils').createCompFlags(level)
    end,
    {
        nargs = '?',
        desc = 'Create a compile_flags.txt file for the current project',
    }
)
