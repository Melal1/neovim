local map = vim.keymap.set
vim.g.mapleader = " "

map("n","<C-q>","<cmd>wqa!<CR>")
map("n","<leader><C-q>","<cmd>qa!<CR>")

map("i", "jk", "<ESC>", { desc = "Exit insert mode quickly" })

-- Terminal mode
map("t", "<ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Search and replace
map("n", "<leader>a", [[:%s/<C-r><C-w>/<C-r><C-w>/gc<Left><Left><Left>]], {
  desc = "Search and replace word under cursor with confirmation",
})
map("v", "<leader>a", 'y:%s/<C-R>"//gc<Left><Left><Left>', {
  noremap = true,
  silent = true,
  desc = "Substitute visually selected region",
})
map("n", "<leader>cw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Change all occurrences of word" })


map("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })


-- Quickfix navigation
map("n", "<A-j>", "<cmd>cnext<CR>", { desc = "Go to next quickfix item" })
map("n", "<A-k>", "<cmd>cprev<CR>", { desc = "Go to previous quickfix item" })

-- Open nvim configs in tmux window or new tab
map("n", "<leader>Opc", function()
  local path = "~/.config/nvim/"
  local expanded_path = vim.fn.expand(path)
  if os.getenv("TMUX") then
    vim.fn.system(
      "tmux new-window -n 'NeoVim configuration' 'z " .. expanded_path .. " && nvim .'"
    )
  else
    vim.cmd("tabnew " .. expanded_path)
  end
end, { desc = "Open Neovim config directory on new tmux window or tab" })

map("n","<leader>opc","<cmd>e ~/.config/nvim/<CR>",{ desc = "Open Neovim config directory on new tmux window or tab" })

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
end, { desc = "Open snippets config directory" })

map("n", "<leader>h", "<cmd>noh<CR>", { desc = "Clear search highlight" })

-- Delete without yanking
map("n", "x", '"_x', { desc = "Delete character without yanking" })
map("n", "dd", '"_dd', { desc = "Delete line without yanking" })
map("v", "d", '"_d', { desc = "Delete selection without yanking" })
vim.api.nvim_set_keymap('n', 'd', '"_d', { noremap = true, silent = true, desc = "Delete without yanking" })

-- Paste without overwriting default register in visual mode
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting default register" })

-- Clipboard mappings
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Leader + d deletes normally
map({ "n", "v" }, "<leader>d", "d", { desc = "Delete selection normally" })

-- Change working directory to current file's directory
map("n", "<leader>cd", "<cmd>cd %:p:h<CR>", { desc = "Set local working directory to current file" })

-- Center screen after scrolling/search
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll half page down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll half page up and center" })
map("n", "n", "nzzzv", { desc = "Next search result and center" })
map("n", "N", "Nzzzv", { desc = "Previous search result and center" })

map("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file explorer" })

map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- Insert blank line below/above without leaving normal mode
map("n", "<CR>", "o<ESC>k", { desc = "Insert blank line below without leaving normal mode" })
map("n", "<S-CR>", "O<ESC>j", { desc = "Insert blank line above without leaving normal mode" })

-- Move selected lines up/down in visual mode 
map("x", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down", silent = true })
map("x", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up",  silent = true })
-- Window resizing
map("n", "<C-up>", "1<C-w>+", { silent = true, desc = "Increase window height" })
map("n", "<C-down>", "1<C-w>-", { silent = true, desc = "Decrease window height" })
map("n", "<C-right>", "1<C-w>>", { silent = true, desc = "Increase window width" })
map("n", "<C-left>", "1<C-w><", { silent = true, desc = "Decrease window width" })

map("n", "<C-c>", "<C-o><", { noremap = true, silent = true, desc = "Unmapped placeholder key" })

map("n", "<leader>rlt", function()
  vim.cmd.colorscheme(require("config.utils").apply_theme())
end, { desc = "Reload colorscheme" })

map("n", "+", function()
  require("config.utils").toggleBool(true)
end, { desc = "Toggle bool" })

map("n", "<leader>+", function()
  require("config.utils").toggleBool(false)
end, { desc = "Toggle vari" })

map("n", "<S-Tab>", "<cmd>bprev!<CR>", { silent = true, desc = "Previous buffer" })
map("n", "<Tab>", "<cmd>bnext!<CR>", { silent = true, desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete!<CR>", { silent = true, desc = "Delete buffer" })




