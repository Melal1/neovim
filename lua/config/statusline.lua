local M = {}

-- Highlighting ----------------------------------------------------------------
vim.cmd("hi statusline guibg=NONE")
vim.cmd("hi StatuslineTerm guibg=NONE")

local colors = {
	bg = "#141415",
	bg_alt = "#252530",
	fg = "#cdcdcd",
	fg_dim = "#282828",
	gray = "#696461",
	red = "#d8647e",
	green = "#7fa563",
	yellow = "#f3be7c",
	blue = "#6e94b2",
	magenta = "#bb9dbd",
	cyan = "#aeaed1",
	red_bright = "#e08398",
	green_bright = "#99b782",
	yellow_bright = "#f5cb96",
	blue_bright = "#8ba9c1",
	magenta_bright = "#c9b1ca",
	cyan_bright = "#bebeda",
}

local hl = vim.api.nvim_set_hl
hl(0, "StatusLineFileName", { fg = colors.gray })
hl(0, "GitBranch", { fg = colors.fg })
hl(0, "DapIcon", { fg = colors.magenta_bright })
hl(0, "CopilotStatus", { fg = colors.cyan_bright })
hl(0, "DiagWarn", { fg = colors.yellow_bright })
hl(0, "DiagError", { fg = colors.red_bright })
hl(0, "ModeCom", { fg = colors.cyan_bright, bold = true })
hl(0, "ModeVisual", { fg = colors.magenta, bold = true })
hl(0, "ModeReplace", { fg = colors.red, bold = true })
hl(0, "ModeCommand", { fg = colors.yellow, bold = true })
hl(0, "ModeSelect", { fg = colors.cyan, bold = true })
hl(0, "ModeTerminal", { fg = colors.magenta_bright, bold = true })
hl(0, "ModeOther", { fg = colors.fg_dim, bold = true })
hl(0, "ModeComInv", { fg = colors.bg, bg = colors.cyan_bright, bold = true })
hl(0, "ModeVisualInv", { fg = colors.bg, bg = colors.magenta, bold = true })
hl(0, "ModeReplaceInv", { fg = colors.bg, bg = colors.red, bold = true })
hl(0, "ModeCommandInv", { fg = colors.bg, bg = colors.yellow, bold = true })
hl(0, "ModeSelectInv", { fg = colors.bg, bg = colors.cyan, bold = true })
hl(0, "ModeTerminalInv", { fg = colors.bg, bg = colors.magenta_bright, bold = true })
hl(0, "ModeOtherInv", { fg = colors.bg, bg = colors.fg_dim, bold = true })

-- Modes -------------------------------------------------------------------------

vim.o.showmode = false

local CTRL_V = vim.api.nvim_replace_termcodes("<C-v>", true, true, true)
local CTRL_S = vim.api.nvim_replace_termcodes("<C-s>", true, true, true)
local WebDevIcons = require("nvim-web-devicons")

local modes = setmetatable({
	n = { long = " NORMAL ", short = " N ", hl = "ModeComInv" },
	v = { long = " VISUAL ", short = " V ", hl = "ModeVisualInv" },
	V = { long = " V-LINE ", short = " V-L ", hl = "ModeVisualInv" },
	[CTRL_V] = { long = " V-BLOCK ", short = " V-B ", hl = "ModeVisualInv" },
	s = { long = " SELECT ", short = " S ", hl = "ModeSelectInv" },
	S = { long = " S-LINE ", short = " S-L ", hl = "ModeSelectInv" },
	[CTRL_S] = { long = " S-BLOCK ", short = " S-B ", hl = "ModeSelectInv" },
	i = { long = " INSERT ", short = " I ", hl = "ModeComInv" },
	R = { long = " REPLACE ", short = " R ", hl = "ModeReplaceInv" },
	c = { long = " COMMAND ", short = " C ", hl = "ModeCommandInv" },
	r = { long = " PROMPT ", short = " P ", hl = "ModeOtherInv" },
	[" ! "] = { long = " SHELL ", short = "Sh", hl = "ModeOtherInv" },
	t = { long = " TERMINAL ", short = " T ", hl = "ModeTerminalInv" },
}, {
	__index = function()
		return { long = " UNKNOWN ", short = " U ", hl = "ModeOtherInv" }
	end,
})

-- Utility: wrap text with highlight ------------------------------------------
local function hl_str(hl_name, text)
	return "%#" .. hl_name .. "#" .. text .. "%#Normal#"
end

-- Window truncation detection --------------------------------------------------
local trunc100 = true
local function is_truncated(width)
	local w = (vim.o.laststatus == 3) and vim.o.columns or vim.api.nvim_win_get_width(0)
	return w < width
end

-- MODE COMPONENT --------------------------------------------------------------
local function mode_component()
	local m = modes[vim.fn.mode()]
	-- return hl_str(m.hl, (trunc100 and m.short or m.long))
	return hl_str(m.hl, m.short)
end

-- GIT COMPONENT ----------------------------------------------------------------
function M.git_component()
	local head = vim.b.gitsigns_head
	if not head or head == "" then
		return ""
	end
	return hl_str("GitBranch", trunc100 and "   " or ("  " .. head .. " "))
end

-- LINE / COLUMN ----------------------------------------------------------------
local function line_col()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	if trunc100 then
		return hl_str("StatusLineFileName", string.format(" %d:%d ", row, col + 1))
	end
	return hl_str("StatusLineFileName", string.format(" Ln%d, Col%d ", row, col + 1))
end

-- VARIABLES UPDATED BY AUTOCOMMANDS -------------------------------------------
local copilot = ""
local file_icon = ""
local diag_enabled = false

math.randomseed(os.time())
local funny = { "Creative", "EasyMode", "Spectator", "Redstone", "!Xp", " " }


-- AUTOCOMMAND: LSP attach/detach + BufEnter -----------------------------------
vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "BufEnter" }, {
	callback = function(args)
		local buf = args.buf
		local client = args.data and args.data.client_id and vim.lsp.get_client_by_id(args.data.client_id)

		-- Handle Copilot client detection
		if client and client.name == "copilot" then
			if args.event == "LspAttach" then
				copilot = hl_str("CopilotStatus", funny[math.random(#funny)])
			else
				copilot = ""
			end
		end

		-- File icon update
		local ft = vim.bo[buf].filetype
		file_icon = WebDevIcons.get_icon_by_filetype(ft)
		if not file_icon then
			file_icon = ""
		end

		-- Diagnostics enabled if at least one LSP is attached
		local clients = vim.lsp.get_clients({ bufnr = buf })
		diag_enabled = (#clients > 0 and copilot == "") or (#clients > 1)
	end,
})

-- DIAGNOSTICS COMPONENT --------------------------------------------------------
function M.diagnostics_component()
	if not diag_enabled then
		return ""
	end
	local counts = { E = 0, W = 0, H = 0, I = 0 }
	for _, d in ipairs(vim.diagnostic.get(0)) do
		if d.severity == vim.diagnostic.severity.ERROR then
			counts.E = counts.E + 1
		elseif d.severity == vim.diagnostic.severity.WARN then
			counts.W = counts.W + 1
		elseif d.severity == vim.diagnostic.severity.HINT then
			counts.H = counts.H + 1
		elseif d.severity == vim.diagnostic.severity.INFO then
			counts.I = counts.I + 1
		end
	end
	local parts = {}
	if counts.E > 0 then
		table.insert(parts, "%#DiagError# " .. counts.E)
	else
		table.insert(parts, "%#StatusLineFileName# " .. counts.E)
	end
	if counts.W > 0 then
		table.insert(parts, "%#DiagWarn# " .. counts.W)
	else
		table.insert(parts, "%#StatusLineFileName# " .. counts.W)
	end
	if counts.H > 0 then
		table.insert(parts, "%#CopilotStatus#H:" .. counts.H)
	end
	if counts.I > 0 then
		table.insert(parts, "%#DiagnosticInfo#I:" .. counts.I)
	end
	return " " .. table.concat(parts, " ") .. "%#Normal# "
end

-- DAP COMPONENT ----------------------------------------------------------------
_G.DAP_IS_ACTIVE = false

function M.dap_component()
	if not _G.DAP_IS_ACTIVE then
		return ""
	end

	local dap = require("dap")

	local name = vim.fn.expand("%:t")

	if trunc100 then
		return string.format(
			"%%#DapIcon#Debugging:%%#Normal# %%#CopilotStatus#%s%%#Normal# %%#DapIcon# %%#Normal#",
			name
		)
	end

	return string.format(
		"%%#DapIcon#Debugging:%%#Normal# %%#CopilotStatus#%s%%#Normal# %%#DapIcon# %%#Normal# %%#CopilotStatus#%s%%#Normal#",
		name,
		dap.status()
	)
end

-- BUFFER FLAGS -----------------------------------------------------------------
function M.buffer_flags_component()
	local b = vim.bo
	local out = {}
	if b.modified then
		out[#out + 1] = " [+]"
	end
	if b.readonly then
		out[#out + 1] = " [RO]"
	end
	if not b.modifiable then
		out[#out + 1] = " [-]"
	end
	return table.concat(out)
end

-- CURRENT WORKING DIRECTORY ----------------------------------------------------
M.cwd = function()
	if vim.o.columns > 85 then
		return "%#ModeCom#  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " "
	end
	return ""
end

-- BREADCRUMB TOGGLE ------------------------------------------------------------
local breadcrumb_on = true

vim.api.nvim_create_user_command("Crumb", function(o)
	if o.args == "on" then
		breadcrumb_on = true
		return
	end
	if o.args == "off" then
		breadcrumb_on = false
		return
	end
	vim.notify("Usage: Crumb on | off")
end, { nargs = 1 })

-- RENDER -----------------------------------------------------------------------
local breadcrumb = ""
local ignore = {
	["dap-view"] = true,
	["dap-view-term"] = true,
	["dap-view-help"] = true,
}
function M.render()
	trunc100 = is_truncated(100)
	local ft = vim.bo.filetype

	if not ignore[ft] then
		if breadcrumb_on and not _G.DAP_IS_ACTIVE then
			local navic = require("nvim-navic")
			breadcrumb = navic.get_location()
			vim.o.winbar = ""
		else
			if _G.DAP_IS_ACTIVE then
				vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
				breadcrumb = ""
			end
		end
	end

	return table.concat({
		mode_component(),
		" ",

		(_G.DAP_IS_ACTIVE and "")
			or (vim.bo.buftype == "terminal" and ("%#StatusLineFileName# " .. (vim.env.SHELL and vim.fn.fnamemodify(
				vim.env.SHELL,
				":t"
			) or "shell")))
			or ("%#StatusLineFileName#" .. (file_icon or "") .. " " .. vim.fn.expand("%:t")),

		" ",
		M.diagnostics_component(),
		" ",
		"%=", -- left/center/right separator
		M.dap_component(),
		breadcrumb,
		"%=",
		"                  ",
		copilot,
		M.buffer_flags_component(),
		M.git_component(),
		M.cwd(),
		line_col(),
	})
end

vim.o.statusline = "%!v:lua.require'config.statusline'.render()"
return M
