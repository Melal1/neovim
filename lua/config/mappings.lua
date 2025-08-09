-- This file contains all the key mappings for the editor only , plugins mappings are in their respective files
-- Leader key is set to space
local map = vim.keymap.set
vim.g.mapleader = " "
map("i", "jk", "<ESC>")
-- Terminal
map("t", "<ESC>", "<C-\\><C-n>")
-- map("n", "<leader>la", ":terminal lazygit <CR>")
--Search and replace
map("n", "<leader>a", [[:%s/<C-r><C-w>/<C-r><C-w>/gc<Left><Left><Left>]])
-- Visual mode mapping: Substitute the visually selected text
map("v", "<leader>a", 'y:%s/<C-R>"//gc<Left><Left><Left>', {
  noremap = true,
  silent = true,
  desc = "Substitute visually selected region", -- A helpful description for :help map
})
map("n", "<M-j>", "<cmd>cnext<CR>")
map("n", "<M-k>", "<cmd>cprev<CR>")

-- Open nvim configs

-- map("n", "<leader>opc", ":Neotree focus $HOME/.config/nvim<CR>")
-- map("n", "<leader>ops", ":Neotree focus $HOME/.config/nvim/lua/config/Snippets/<CR>")
map("n", "<leader>opc", function()
  local path = "~/.config/nvim/"
  local expanded_path = vim.fn.expand(path)

  if os.getenv("TMUX") then
    vim.fn.system(
      "tmux new-window -n 'NeoVim configuration' 'z " .. expanded_path .. " && nvim .'"
    )
  else
    vim.cmd("tabnew " .. expanded_path)
  end
end, { desc = "Open nvim in tmux window or new tab" })

map("n", "<leader>ops", function()
  local path = "~/.config/nvim/lua/config/Snippets/"
  local expanded_path = vim.fn.expand(path)

  if os.getenv("TMUX") then
    vim.fn.system(
      "tmux new-window -n 'Snippets' 'z " .. expanded_path .. " && nvim .'"
    )
  else
    vim.cmd("tabnew " .. expanded_path)
  end
end, { desc = "Open nvim in tmux window or new tab" })


map("n", "<leader>h", ":noh<CR>")

map("n", "x", '"_x')
map("n", "dd", '"_dd')
map("v", "d", '"_d')
vim.api.nvim_set_keymap('n', 'c', '"_c', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'C', '"_C', { noremap = true, silent = true })


map("x", "<leader>p", [["_dP]])
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])
map({ "n", "v" }, "<leader>d", "d")

map("n", "<leader>cd", "<cmd>:lcd %:p:h<CR>")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<leader>pv", vim.cmd.Ex)
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
map("n", "<CR>", "o<ESC>k")   -- insert blank line without exiting n mode
map("n", "<S-CR>", "O<ESC>j") -- same as above but up
map("x", "<D-j>", ":move '>+1<CR>gv-gv")
map("x", "<D-k>", ":move '<-2<CR>gv-gv")

-- Windows resizing
map("n", "<C-up>", "1<C-w>+", { noremap = false, silent = true })
map("n", "<C-down>", "1<C-w>-", { noremap = true, silent = true })
map("n", "<C-right>", "1<C-w>>", { noremap = true, silent = true })
map("n", "<C-left>", "1<C-w><", { noremap = true, silent = true })
map("n", "<C-c", "<C-o><", { noremap = true, silent = true })
map("n", "<leader>rlt", function()
  vim.cmd.colorscheme(require("config.utils").apply_theme())
end)
map("n","+",function ()
  require("config.utils").toggleBool(true)
end)
map("n","<leader>+",function ()
  require("config.utils").toggleBool(false)
end)

-- map("n", "<leader>td", function()
--   require("config.utils").open_floating_todo() -- Call the function directly
-- end, { noremap = true, silent = true, desc = "Open TODO in floating window" })
--
map("n", "<S-Tab>", "<cmd>bprev!<CR>", { silent = true })
map("n", "<Tab>", "<cmd>bnext!<CR>", { silent = true })
map("n", "<leader>bd", "<cmd>bdelete!<CR>", { silent = true })

-- map("n", "<leader>dash", ":Alpha<CR>")
