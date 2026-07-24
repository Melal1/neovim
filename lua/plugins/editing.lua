return {
	--Tabout
	{
		"kawre/neotab.nvim",
		event = "InsertEnter",
		opts = {
			tabkey = "<Tab>",
			reverse_key = "<S-Tab>",
			act_as_tab = true,
			behavior = "nested",
			pairs = { ---@type ntab.pair[]
				{ open = "(", close = ")" },
				{ open = "[", close = "]" },
				{ open = "{", close = "}" },
				{ open = "'", close = "'" },
				{ open = '"', close = '"' },
				{ open = "`", close = "`" },
				{ open = "<", close = ">" },
			},
			exclude = {},
			smart_punctuators = {
				enabled = true,
				semicolon = {
					enabled = true,
					ft = { "cs", "c", "cpp", "java" },
				},
				escape = {
					enabled = true,
					triggers = { ---@type table<string, ntab.trigger>
						[","] = {
							pairs = {
								{ open = "'", close = "'" },
								{ open = '"', close = '"' },
							},
							format = "%s ", -- ", "
						},
					},
				},
			},
		},
	},
	--Split join
	{
		"nvim-mini/mini.splitjoin",
		version = false,
		opts = {},
		keys = {
			{
				"<leader>tj",
				function()
					require("mini.splitjoin").toggle()
				end,
				desc = "Toggle Split/Join",
			},
		},
	},
	--AutoPair: blink.pairs
	{
		"saghen/blink.pairs",
		dependencies = "saghen/blink.lib",
		version = "*",
		build = function()
			require("blink.pairs").build():pwait(60000)
		end,

		--- @module 'blink.pairs'
		--- @type blink.pairs.Config
		opts = {
			mappings = {
				-- you can call require("blink.pairs.mappings").enable()
				-- and require("blink.pairs.mappings").disable()
				-- to enable/disable mappings at runtime
				enabled = true,
				cmdline = true,
				-- or disable with `vim.g.pairs = false` (global) and `vim.b.pairs = false` (per-buffer)
				-- and/or with `vim.g.blink_pairs = false` and `vim.b.blink_pairs = false`
				disabled_filetypes = {},
				-- see the defaults:
				-- https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L14
				pairs = {},
			},
			highlights = {
				enabled = true,
				-- requires require('vim._extui').enable({}), otherwise has no effect
				cmdline = true,
				groups = {
					-- "BlinkPairsOrange",
					-- "BlinkPairsPurple",
					-- "BlinkPairsBlue",
					"@lsp.type.parameter",
					"@lsp.type.enum",
					"@keyword.exepction",
				},
				unmatched_group = "BlinkPairsUnmatched",

				-- highlights matching pairs under the cursor
				matchparen = {
					enabled = true,
					-- known issue where typing won't update matchparen highlight, disabled by default
					cmdline = false,
					-- also include pairs not on top of the cursor, but surrounding the cursor
					include_surrounding = false,
					group = "BlinkPairsMatchParen",
					priority = 250,
				},
			},
			debug = false,
		},
	},
	--Comment: Mini.comment
	{
		"nvim-mini/mini.comment",
		version = false,
		event = "BufReadPost",
		opts = {},
	},
	--Surround: Mini.Surround
	{
		"echasnovski/mini.surround",
		keys = {
			{ "gsa", desc = "Add Surrounding", mode = { "n", "v" } },
			{ "gsd", desc = "Delete Surrounding" },
			{ "gsr", desc = "Replace Surrounding" },
			{ "gsf", desc = "Find Right Surrounding" },
			{ "gsF", desc = "Find Left Surrounding" },
			{ "gsh", desc = "Highlight Surrounding" },
			{ "gsn", desc = "Update `n_lines`" },
		},
		opts = {
			mappings = {
				add = "gsa",
				delete = "gsd",
				find = "gsf",
				find_left = "gsF",
				highlight = "gsh",
				replace = "gsr",
				update_n_lines = "gsn",
			},
		},
	},
	--Text-object: Mini.ai
	{
		"echasnovski/mini.ai",
		version = false,
		event = "InsertEnter",
		opts = {},
	},
	--Treesitter-text-object
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					-- Automatically jump forward to textobj, similar to targets.vim
					lookahead = true,
					-- You can choose the select mode (default is charwise 'v')
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * method: eg 'v' or 'o'
					-- and should return the mode ('v', 'V', or '<c-v>') or a table
					-- mapping query_strings to modes.
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- linewise
						["@class.outer"] = "<c-v>", -- blockwise
					},
					-- If you set this to `true` (default is `false`) then any textobject is
					-- extended to include preceding or succeeding whitespace. Succeeding
					-- whitespace has priority in order to act similarly to eg the built-in
					-- `ap`.
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * selection_mode: eg 'v'
					-- and should return true of false
					include_surrounding_whitespace = false,
				},
				move = {
					-- whether to set jumps in the jumplist
					set_jumps = true,
				},
			})

			-- Select
			vim.keymap.set({ "x", "o" }, "ar", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@return.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ir", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@return.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "in", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@number.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ao", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@loop.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "io", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@loop.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "i=", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@assignment.rhs", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "i-", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@assignment.lhs", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "a=", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@assignment.rhs", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "a-", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@assignment.lhs", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "am", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@call.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "im", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@call.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ai", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer")
			end)
			vim.keymap.set({ "x", "o" }, "ii", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "af", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "if", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ac", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ic", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "as", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
			end)
			vim.keymap.set({ "o", "x" }, "aA", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer")
			end)
			vim.keymap.set({ "o", "x" }, "aa", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner")
			end)

			-- Swap
			vim.keymap.set("n", "<leader>=a", function()
				require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
			end)
			vim.keymap.set("n", "<leader>=f", function()
				require("nvim-treesitter-textobjects.swap").swap_next("@function.outer")
			end)
			vim.keymap.set("n", "<leader>=A", function()
				require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
			end)
			vim.keymap.set("n", "<leader>=F", function()
				require("nvim-treesitter-textobjects.swap").swap_previous("@function.outer")
			end)

			-- Move
			vim.keymap.set({ "n", "x", "o" }, "]m", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "]]", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
			end)
			-- You can also pass a list to group multiple queries.
			vim.keymap.set({ "n", "x", "o" }, "]l", function()
				require("nvim-treesitter-textobjects.move").goto_next_start(
					{ "@loop.inner", "@loop.outer" },
					"textobjects"
				)
			end)
			vim.keymap.set({ "n", "x", "o" }, "[l", function()
				require("nvim-treesitter-textobjects.move").goto_next_start(
					{ "@loop.inner", "@loop.outer" },
					"textobjects"
				)
			end)
			-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
			vim.keymap.set({ "n", "x", "o" }, "]s", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
			end)
			vim.keymap.set({ "n", "x", "o" }, "]z", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
			end)

			vim.keymap.set({ "n", "x", "o" }, "]M", function()
				require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "][", function()
				require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[m", function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[[", function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[M", function()
				require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[]", function()
				require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "]i", function()
				require("nvim-treesitter-textobjects.move").goto_next("@conditional.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[i", function()
				require("nvim-treesitter-textobjects.move").goto_previous("@conditional.outer", "textobjects")
			end)

			-- Repeat
			local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
			vim.keymap.set({ "n", "x", "o" }, "<leader>;", ts_repeat_move.repeat_last_move)
			vim.keymap.set({ "n", "x", "o" }, "<leader>,", ts_repeat_move.repeat_last_move_opposite)
		end,
	},
	{
		"gbprod/substitute.nvim",
		opts = {
			yank_substituted_text = false,
			preserve_cursor_position = true,
			range = {
				prompt_current_text = true,
				group_substituted_text = true,
			},
			exchange = {
				preserve_cursor_position = true,
			},
		},
		keys = {
			{
				"s",
				mode = { "n" },
				function()
					require("substitute").operator({
						modifiers = function(state)
							if state.vmode == "char" then
								return { "trim" }
							end
						end,
					})
				end,
				desc = "Substitute",
			},
			{
				"ss",
				mode = { "n" },
				function()
					require("substitute").line({
						modifiers = { "reindent" },
					})
				end,
				desc = "Substitute line",
			},
			{
				"<leader>s",
				mode = { "x" },
				function()
					require("substitute").operator()
				end,
			},
			{
				"s",
				mode = { "x" },
				function()
					require("substitute").visual()
				end,
				desc = "Substitute",
			},
			{
				")s",
				mode = { "n", "x" },
				function()
					require("substitute").operator({
						modifiers = { "linewise" },
					})
				end,
				desc = "Substitute linewise",
			},
			{
				"=s",
				mode = { "n" },
				function()
					require("substitute").operator({
						modifiers = { "linewise", "reindent" },
					})
				end,
				desc = "Substitute linewise and reindent",
			},
			{
				"]s",
				mode = { "n" },
				function()
					require("substitute").operator({
						modifiers = require("substitute.modifiers").build({ "join", "trim" }),
					})
				end,
				desc = "Substitute linewise and join",
			},

			{
				"sx",
				mode = { "n" },
				function()
					require("substitute.exchange").operator()
				end,
				desc = "Exchange",
			},
			{
				"sxx",
				mode = { "n" },
				function()
					require("substitute.exchange").line()
				end,
				desc = "Exchange line",
			},
			{
				"X",
				mode = { "x" },
				function()
					require("substitute.exchange").visual()
				end,
				desc = "Exchange",
			},
			{
				"sxc",
				mode = { "n" },
				function()
					require("substitute.exchange").cancel()
				end,
				desc = "Exchange cancel",
			},
		},
	},
}
