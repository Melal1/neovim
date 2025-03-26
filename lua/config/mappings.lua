-- This file contains all the key mappings for the editor only , plugins mappings are in their respective files
-- Leader key is set to space
vim.g.mapleader = " "
vim.keymap.set("i", "jk", "<ESC>")
-- Terminal
vim.keymap.set("t", "<ESC>", "<C-\\><C-n>")
vim.keymap.set("n", "<leader>la", ":terminal lazygit <CR>")
--Search and replace
vim.keymap.set("n", "<leader>a", [[:%s/<C-r><C-w>/<C-r><C-w>/gc<Left><Left><Left>]])
vim.keymap.set("n", "<leader>h", ":noh<CR>")

vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "dd", '"_dd')
vim.keymap.set("v", "d", '"_d')
-- vim.keymap.set("n", "<c-v>", '"+p')
vim.keymap.set("n", "diw", '"_diw')
vim.keymap.set("n", "ciw", '"_ciw')
vim.keymap.set("n", "daw", '"_daw')
vim.keymap.set("n", "caw", '"_caw')

vim.keymap.set("n", "<leader>diw", "diw")
vim.keymap.set("n", "<leader>ciw", "ciw")
vim.keymap.set("n", "<leader>daw", "daw")
vim.keymap.set("n", "<leader>caw", "caw")

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({ "n", "v" }, "<leader>d", "d")

vim.keymap.set("n", "<leader>cd", "<cmd>:lcd %:p:h<CR>")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<CR>", "o<ESC>k") -- insert blank line without exiting n mode
vim.keymap.set("n", "<S-CR>", "O<ESC>j") -- same as above but up
vim.keymap.set("x", "<D-j>", ":move '>+1<CR>gv-gv")
vim.keymap.set("x", "<D-k>", ":move '<-2<CR>gv-gv")

-- Windows resizing
vim.keymap.set("n", "<C-up>", "1<C-w>+", { noremap = true, silent = true })
vim.keymap.set("n", "<C-down>", "1<C-w>-", { noremap = true, silent = true })
vim.keymap.set("n", "<C-right>", "1<C-w>>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-left>", "1<C-w><", { noremap = true, silent = true })
vim.keymap.set("n", "<C-c", "<C-o><", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rlt", function()
	vim.cmd.colorscheme(require("config.utils").apply_theme())
end)

vim.keymap.set("n", "<leader>td", function()
	require("config.utils").open_floating_todo() -- Call the function directly
end, { noremap = true, silent = true, desc = "Open TODO in floating window" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprev!<CR>", { silent = true })
vim.keymap.set("n", "<Tab>", "<cmd>bnext!<CR>", { silent = true })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete!<CR>", { silent = true })
