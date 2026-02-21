local icons = {
	Namespace = "󰌗",
	Text = "󰉿",
	Method = "󰆧",
	Function = "󰆧",
	Constructor = "",
	Field = "󰜢",
	Variable = "󰀫",
	Class = "󰠱",
	Interface = "",
	Module = "",
	Property = "󰜢",
	Unit = "󰑭",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󱓻",
	File = "󰈚",
	Reference = "󰈇",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰏿",
	Struct = "󰙅",
	Event = "",
	Operator = "󰆕",
	TypeParameter = "󰊄",
	Table = "",
	Object = "󰅩",
	Tag = "",
	Array = "[]",
	Boolean = "",
	Number = "",
	Null = "󰟢",
	Supermaven = "",
	String = "󰉿",
	Calendar = "",
	Watch = "󰥔",
	Package = "",
	Copilot = "",
	Codeium = "",
	TabNine = "",
	BladeNav = "",
}
return {

	--Linting: none-ls
	{
		"nvimtools/none-ls.nvim",
		event = { "BufReadPost" },

		config = function()
			local null_ls = require("null-ls")

			null_ls.setup({
				sources = {
					null_ls.builtins.diagnostics.mypy,
				},
			})
		end,
	},

	--Formatting: conform
	{
		"stevearc/conform.nvim",
		keys = {
			{
				"<leader>frm",
				function()
					require("conform").format({ lsp_format = "fallback" })
				end,
				desc = "Trigger formating",
			},
		},
		opts = {},
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					python = {
						-- To fix auto-fixable lint errors.
						"ruff_fix",
						-- To run the Ruff formatter.
						"ruff_format",
						-- To organize the imports.
						"ruff_organize_imports",
					},
					lua = { "stylua" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					cpp = { "clang_format" },
					nix = { "nixpkgs_fmt" },
				},
				formatters = {
					clang_format = {
						prepend_args = {
							"--style={ \
        BasedOnStyle: LLVM, \
        IndentWidth: 2, \
        UseTab: Never, \
        ColumnLimit: 120, \
        BreakBeforeBraces: Allman, \
        AlignArrayOfStructures: None, \
        SeparateDefinitionBlocks: Always, \
        EmptyLineBeforeAccessModifier: LogicalBlock, \
        AllowShortFunctionsOnASingleLine: None, \
        BinPackArguments: false, \
        BinPackParameters: false, \
        AlignAfterOpenBracket: AlwaysBreak, \
        AllowAllArgumentsOnNextLine: true, \
        AllowAllParametersOfDeclarationOnNextLine: true, \
      }",
						},
					},
				},
			})
		end,
	},
	--Cmp : Blink
	{

		event = { "BufRead", "BufNewFile" },
		"saghen/blink.cmp",
		dependencies = { "fang2hou/blink-copilot" },
		-- dependencies = { "rafamadriz/friendly-snippets" },

		-- use a release tag to download pre-built binaries
		version = "1.*",
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {

				preset = "default",
				["<C-s>"] = { "show" },
				["<C-y>"] = { "hide" },
				["<C-e>"] = { "select_and_accept" },
				["<C-l>"] = { "snippet_forward", "fallback" },
				["<C-h>"] = { "snippet_backward", "fallback" },
				["<UP>"] = {
					function(cmp)
						cmp.show({ providers = { "snippets" } })
					end,
				},
				["<DOWN>"] = {
					function(cmp)
						cmp.show({ providers = { "lsp" } })
					end,
				},
				["<Tab>"] = false,
				["<S-Tab>"] = false,
			},
			signature = { enabled = true },

			appearance = {
				nerd_font_variant = "normal",
			},

			cmdline = {
				completion = {
					ghost_text = { enabled = false },
				},
				keymap = {
					preset = "default",
					["<C-y>"] = { "cancel" },
					["<C-e>"] = { "select_and_accept" },
				},
			},

			completion = {
				accept = {
					create_undo_point = true,
					auto_brackets = {
						-- Whether to auto-insert brackets for functions
						enabled = true,
					},
				},
				ghost_text = {
					enabled = false,
					show_with_menu = false,
				},
				menu = {
					scrollbar = false,
					auto_show = false,
					border = "single",
					draw = {
						padding = { 1, 1 },
						components = {
							kind_icon = {
								highlight = function(ctx)
									return ctx.kind
								end,
								text = function(ctx)
									local icon = (icons[ctx.kind] or "󰈚")
									return icon
								end,
							},

							kind = {
								highlight = function(ctx)
									return ctx.kind
								end,
							},
							label = {
								width = { fill = true, max = 60 },
								text = function(ctx)
									return ctx.label .. ctx.label_detail
								end,
								highlight = function(ctx)
									-- label and label details
									local highlights = {
										{
											0,
											#ctx.label,
											group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
										},
									}
									if ctx.label_detail then
										table.insert(
											highlights,
											{ #ctx.label, #ctx.label + #ctx.label_detail, group = "BlinkCmpLabelDetail" }
										)
									end

									-- characters matched on the label by the fuzzy matcher
									for _, idx in ipairs(ctx.label_matched_indices) do
										table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
									end

									return highlights
								end,
							},
						},
						-- gap = 2,
						columns = {
							{ "kind_icon" },
							{ "label" },
							{ "kind" },
						},
					},
				},
				documentation = {
					auto_show = false,
				},
			},

			sources = {
				default = { "snippets", "lsp", "path", "buffer", "copilot" },

				providers = {
					copilot = {
						name = "copilot",
						module = "blink-copilot",
						score_offset = 100,
						async = true,
					},
					lsp = {
						score_offset = 9,
					},
					snippets = {
						score_offset = 10,
					},
				},
			},
			fuzzy = {
				sorts = {
					"exact",
					"score",
					"sort_text",
				},
				implementation = "rust",
			},
		},
		opts_extend = { "sources.default" },
	},
	--Treesitter
	{

		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
		},
		branch = "main",
		event = { "BufRead", "BufNew" },
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.install({ "pyhton", "cpp", "bash", "lua", "rust", "make" })
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(details)
					vim.defer_fn(function()
						local bufnr = details.buf
						if not pcall(vim.treesitter.start, bufnr) then
							return -- Exit if treesitter was unable to start
						end
						vim.bo[bufnr].syntax = "on" -- fallback syntax highlighting
						vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- treesitter folds
						-- vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" -- treesitter indentation
					end, 50) -- delay in milliseconds
				end,
			})
		end,
	},
}
