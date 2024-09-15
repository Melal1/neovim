-- optiotns 
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set writebackup")
--vim.cmd("set backup")
--vim.cmd("set swapfile")
vim.cmd("set undofile")
vim.cmd("set updatetime=250")
vim.loader.enable()




-- Global bindings
vim.g.mapleader = " "
vim.keymap.set("i", "jk", "<ESC>")
--Search and replace
vim.keymap.set("n", "<leader>a", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>]])
vim.keymap.set("n", "<leader>h", ":noh<CR>")
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n","dd", '"_dd' )
vim.keymap.set("v", "d" , '"_d')
vim.keymap.set("n", "diw", '"_diw')
vim.keymap.set("n", "ciw", '"_ciw')
vim.keymap.set("v", "<C-x>", '"_x')
vim.keymap.set("n", "<leader>cd", "<cmd>:lcd %:p:h<CR>")
vim.keymap.set("v", "<c-c>", '"+y')
vim.keymap.set("n", "<c-v>", '"+p')
vim.keymap.set("x", "<c-c>", '"+y')
vim.keymap.set('n', '<leader>tf', function()
    -- Ensure the image plugin is loaded before toggling Neotree
    require('lazy').load({ plugins = { '3rd/image.nvim' } })
    vim.cmd('Neotree filesystem')  -- Adjust this if the command is different
end)


