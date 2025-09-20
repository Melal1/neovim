local M = {}
vim.o.showmode = false

local mode_info = {

	["n"] = { hl = "StatusLine", name = " N " },
	["no"] = { hl = "StatusLine", name = " O-N " },
	["nov"] = { hl = "StatusLine", name = " O-V " },
	["noV"] = { hl = "StatusLine", name = " O-V " },
	["no\22"] = { hl = "StatusLine", name = " O-V " },
	["niI"] = { hl = "TabLineSel", name = " N-I " },
	["niR"] = { hl = "DiffDelete", name = " N-R " },
	["niV"] = { hl = "DiffChange", name = " N-R " },
	["nt"] = { hl = "Title", name = " N-T " },
	["ntT"] = { hl = "Title", name = " N-T " },

	["i"] = { hl = "TabLineSel", name = " I " },
	["ic"] = { hl = "TabLineSel", name = " I " },
	["ix"] = { hl = "TabLineSel", name = " I " },

	["v"] = { hl = "Visual", name = " V " },
	["vs"] = { hl = "Visual", name = " V " },
	["V"] = { hl = "Visual", name = " V " },
	["Vs"] = { hl = "Visual", name = " V " },
	["\22"] = { hl = "Visual", name = " V " },
	["\22s"] = { hl = "Visual", name = " V " },

	["s"] = { hl = "PmenuSel", name = " S " },
	["S"] = { hl = "PmenuSel", name = " S " },
	["\19"] = { hl = "PmenuSel", name = " S " },

	["R"] = { hl = "DiffDelete", name = " R " },
	["Rc"] = { hl = "DiffDelete", name = " R " },
	["Rx"] = { hl = "DiffDelete", name = " R " },
	["Rv"] = { hl = "DiffChange", name = " R " },
	["Rvc"] = { hl = "DiffChange", name = " R " },
	["Rvx"] = { hl = "DiffChange", name = " R " },

	["c"] = { hl = "WildMenu", name = " C " },
	["cv"] = { hl = "WildMenu", name = " C " },
	["ce"] = { hl = "WildMenu", name = " C " },

	["r"] = { hl = "MoreMsg", name = " P " },
	["rm"] = { hl = "MoreMsg", name = " P " },
	["r?"] = { hl = "Question", name = " P " },

	["!"] = { hl = "WarningMsg", name = " ! " },
	["t"] = { hl = "Title", name = " T " },
}

function M.git_component()
	local head = vim.b.gitsigns_head
	if not head or head == "" then
		return ""
	end
	return "%#@variable.parameter# " .. head .. "%#Normal#"
end

function M.dap_component()
	if not package.loaded["dap"] or require("dap").status() == "" then
		return ""
	end
	return "%#Character#  %#Normal# %#Macro#" .. require("dap").status() .. "%#Normal#"
end

function M.diagnostics_component()
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
		table.insert(parts, "%#DiagnosticError#E:" .. counts.E)
	end
	if counts.W > 0 then
		table.insert(parts, "%#DiagnosticWarn#W:" .. counts.W)
	end
	if counts.H > 0 then
		table.insert(parts, "%#DiagnosticHint#H:" .. counts.H)
	end
	if counts.I > 0 then
		table.insert(parts, "%#DiagnosticInfo#I:" .. counts.I)
	end

	if #parts > 0 then
		return table.concat(parts, " ") .. "%#Normal# "
	end
	return ""
end

local function mode_component()
	local mode = vim.api.nvim_get_mode().mode
	local info = mode_info[mode] or { hl = "StatusLineNC", name = " UNKNOWN " }
	return string.format("%%#%s#%s%%#Normal#", info.hl, info.name)
end

local function filepath()
	local fpath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.:h")
	if fpath == "" or fpath == "." then
		return " "
	end
	local fname = vim.fn.expand("%:t")
	if fname == "" then
		return ""
	end

	return string.format(" %%<%s/", fpath)
end

local function file_component()
	local parts = {}

	table.insert(parts, "%<%t")

	if vim.bo.modified then
		table.insert(parts, " [+]")
	end
	if vim.bo.readonly then
		table.insert(parts, " [RO]")
	end
	if not vim.bo.modifiable then
		table.insert(parts, " [-]")
	end

	return table.concat(parts, "")
end

local function position_component()
	return "%l:%c%V %P"
end

function M.render()
	return table.concat({
		mode_component(),
		" ",
		filepath(),
		file_component(),
		"  ",
		M.git_component(),
		"%=",
		M.diagnostics_component(),
		" ",
		M.dap_component(),
		"  ",
		position_component(),
	})
end

vim.o.statusline = "%!v:lua.require'config.statusline'.render()"
return M
