-- ========================================
-- functions
-- ========================================

-- random title function
local function get_random_title()
	math.randomseed(os.time()) -- Seed the random number generator with current time
	local option = math.random(1, 20) -- Random number between 1 and 2
	if option == 1 then
		return "NotVsCode - %t" -- First title format
	else
		return "Neovim - %t" -- Second title format
	end
end

-- ========================================
-- general options
-- ========================================
vim.opt.title = true
vim.opt.titlestring = get_random_title() -- set dynamic window title
-- vim.g.loaded_netrw = 1 -- disable netrw plugin
-- vim.g.loaded_netrwplugin = 1 -- disable netrw plugins
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.tabstop = 2 -- tab = 2 spaces
vim.opt.softtabstop = 2 -- backspace deletes 2 spaces
vim.opt.smartindent = true
vim.opt.shiftwidth = 2 -- indent = 2 spaces
vim.opt.number = true -- show line numbers
vim.opt.relativenumber = true -- show relative numbers
vim.opt.writebackup = true -- create backup before overwriting
vim.opt.updatetime = 50

-- ========================================
-- backup and swapfile settings
-- ========================================
vim.opt.undofile = true -- persistent undo history
vim.opt.updatetime = 250 -- faster cursorhold events

-- ========================================
-- visual settings
-- ========================================
vim.opt.guicursor = "" -- Fat cursor on insert mode
vim.opt.termguicolors = true -- true color support
-- vim.opt.fillchars = { eob = "" } -- hide end-of-buffer ~
vim.opt.wrap = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.api.nvim_set_hl(0, "LineNr", { fg = "#4e4e4e", bold = false }) -- Normal line numbers

-- ========================================
-- Other
-- ========================================
vim.loader.enable() -- faster lua module loading
