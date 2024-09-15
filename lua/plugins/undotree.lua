return {
    "mbbill/undotree",
    config = function()
        -- Set keymap for toggling undotree
        vim.keymap.set('n', '<leader>U', vim.cmd.UndotreeToggle)
        
        -- Set window layout for undotree
       vim.g.undotree_WindowLayout = 3
    end,
}

