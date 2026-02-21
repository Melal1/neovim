return {
	--Debugging: DAP
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"jbyuki/one-small-step-for-vimkind",
			{
				"igorlfs/nvim-dap-view",
				---@module 'dap-view'
				---@type dapview.Config
				keys = {
					{
						"<leader>du",
						"<cmd>DapViewToggle<CR>",
						desc = "Start Ui",
					},
				},
				opts = {
					winbar = {
						sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
						default_section = "scopes",
					},
				},
			},
			{
				"theHamsta/nvim-dap-virtual-text",
			},
		},
        -- stylua: ignore
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<Right>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<Up>", function() require("dap").step_out() end, desc = "Step Out" },
      { "<Down>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      {"<leader>dt", function()
        require("dap").terminate()
        _G.DAP_IS_ACTIVE = false
        vim.cmd("DapVirtualTextToggle")
        vim.cmd("DapVirtualTextToggle")
      end, desc = "Terminate"},
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
		config = function()
			local dap = require("dap")
			vim.keymap.set("n", "<leader>daw", "<cmd>DapViewWatch<CR>", { desc = "Add under cursor to watch list" })
			require("nvim-dap-virtual-text").setup({
				only_first_definition = false,
			})
			local debuggerPath = os.getenv("CODELLDB_PATH")

			dap.adapters.cppdbg = {
				id = "cppdbg",
				type = "executable",
				command = debuggerPath,
			}

			-- CPP

			dap.configurations.cpp = {
				{
					name = "Attach to gdbserver :1234 ( Make )",
					type = "cppdbg",
					request = "launch",
					MIMode = "gdb",
					miDebuggerServerAddress = "localhost:1234",
					miDebuggerPath = "/run/current-system/sw/bin/gdb",
					cwd = "${workspaceFolder}",
					program = function()
						local msg = require("config.utils.debug").Debug(true)
						return msg
					end,
				},
				{
					name = "Attach to gdbserver :1234",
					type = "cppdbg",
					request = "launch",
					MIMode = "gdb",
					miDebuggerServerAddress = "localhost:1234",
					miDebuggerPath = "/run/current-system/sw/bin/gdb",
					cwd = "${workspaceFolder}",
					program = function()
						local msg = require("config.utils.debug").Debug()
						return msg
					end,
				},
				{
					name = "Launch file",
					type = "cppdbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtEntry = true,
				},
			}
			dap.configurations.lua = {
				{
					type = "nlua",
					request = "attach",
					name = "Attach to running Neovim instance",
				},
			}

			dap.adapters.nlua = function(callback, config)
				callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
			end

			dap.listeners.before.attach.st = function()
				_G.DAP_IS_ACTIVE = true
			end
			dap.listeners.before.launch.st = function()
				_G.DAP_IS_ACTIVE = true
			end
			dap.listeners.before.event_terminated.st = function()
				_G.DAP_IS_ACTIVE = false
			end
			vim.cmd("DapVirtualTextToggle")
			vim.cmd("DapVirtualTextToggle")
			dap.listeners.before.event_exited.st = function()
				_G.DAP_IS_ACTIVE = false
				vim.cmd("DapVirtualTextToggle")
				vim.cmd("DapVirtualTextToggle")
			end
		end,
	},
	--Flash
	{
		"folke/flash.nvim",
		keys = {
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},

	{
		"SmiteshP/nvim-navbuddy",
		dependencies = {
			"SmiteshP/nvim-navic",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			custom_hl_group = nil, -- "Visual" or any other hl group to use instead of inverted colors
		},
		init = function()
			vim.keymap.set("n", "<leader>oo", function()
				require("nvim-navbuddy").open()
			end, { desc = "Open outline window ( NavBuddy )" })
		end,
		lazy = true,
	},
	--Telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		cmd = "Telescope",
		-- Looks messy btw , but this is a simple solution
    -- stylua: ignore
		keys = {
			{ "<leader>opc",function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,desc = "Find Plugin File" },
			{"<leader>frg",function() require("telescope.builtin").registers() end,desc = "Registers",},
			{"<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find Files",},
			{"<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live Grep",},
			{"<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers",},
			{"<leader>fp", function() require("telescope").extensions.projects.projects() end, desc = "Projects",},
			{"<leader>fSt", function() local word = vim.fn.expand("<cWORD>") require("telescope.builtin").grep_string({ search = word }) end, desc = "Grep WORD under cursor (includes punctuation)",},
			{"<leader>fst", function() local word = vim.fn.expand("<cword>") require("telescope.builtin").grep_string({ search = word }) end, desc = "Grep word under cursor (stops at punctuation)",},
			{"<leader>fo", function() require("telescope.builtin").oldfiles() end, desc = "Old Files",},
			{"<leader>OO", function() require("telescope.builtin").lsp_document_symbols() end, desc = "LSP Document Symbols",},
			{"<leader>fdia", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics",},
      {"<leader>frf",function () require("telescope.builtin").lsps_references() end, desc = "LSP References",},
		},

		dependencies = {
			"nvim-lua/plenary.nvim",
			"jmacadie/telescope-hierarchy.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
			},
			"nvim-telescope/telescope-ui-select.nvim",
			"ahmedkhalf/project.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			telescope.setup({
				defaults = {
					preview = {
						treesitter = false,
					},
					mappings = {
						i = {
							["<esc>"] = actions.close,
						},
					},
					path_display = {
						"filename_first",
					},
					previewer = false,
					prompt_prefix = "    ",
					selection_caret = " ",
					file_ignore_patterns = { "node_modules", "package-lock.json", "lazy-lock.json" },
					scroll_strategy = "limit", -- don't rollover when scrolling
					initial_mode = "insert",
					select_strategy = "reset",
					sorting_strategy = "ascending",
					color_devicons = true,
					border = true,
					borderchars = {
						prompt = { "─", "│", "─", "│", "┌", "┐", "│", "│" },
						results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
						preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					},
					set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
					layout_config = {
						prompt_position = "top",
						preview_cutoff = 120,
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
						"--glob=!.git/",
					},
				},
				pickers = {
					buffers = {
						mappings = {
							i = {
								["<c-d>"] = actions.delete_buffer,
							},
							n = {
								["<c-d>"] = actions.delete_buffer,
							},
						},
						previewer = false,
						initial_mode = "normal",
						-- theme = "dropdown",
						layout_config = {
							height = 0.4,
							width = 0.6,
							prompt_position = "top",
							preview_cutoff = 120,
						},
					},
					current_buffer_fuzzy_find = {
						previewer = true,
						layout_config = {
							prompt_position = "top",
							preview_cutoff = 120,
						},
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({
							previewer = false,
							initial_mode = "normal",
							sorting_strategy = "ascending",
							layout_strategy = "horizontal",
							layout_config = {
								horizontal = {
									width = 0.5,
									height = 0.4,
									preview_width = 0.6,
								},
							},
						}),
					},
				},
			})

			-- Setup project.nvim
			require("project_nvim").setup({})

			-- Load extensions
			telescope.load_extension("ui-select")
			telescope.load_extension("projects")
			telescope.load_extension("fzf")
			telescope.load_extension("hierarchy")
		end,
	},
	--TODO:
	{
		"folke/todo-comments.nvim",
		keys = { { "<leader>ltd" } },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			highlight = {
				comments_only = false,
			},
		},
	},
	--Search and replace: spectre
	{
		cmd = "Spectre",
		"nvim-pack/nvim-spectre",
		dependecies = {
			"nvim-lua/plenary.nvim",
		},
	},
	--FileTree: Oil
	{
		{
			"stevearc/oil.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
				require("oil").setup({
					default_file_explorer = true,
					delete_to_trash = true,
					skip_confirm_for_simple_edits = true,
					view_options = {
						show_hidden = true,
						natural_order = true,
						is_always_hidden = function(name, _)
							return name == ".." or name == ".git"
						end,
					},
					win_options = {
						wrap = true,
					},
				})
			end,
		},
		{
			"benomahony/oil-git.nvim",
			dependencies = { "stevearc/oil.nvim" },
			event = { "InsertEnter" },
		},
		{
			"JezerM/oil-lsp-diagnostics.nvim",
			dependencies = { "stevearc/oil.nvim" },
			opts = {},
			event = { "InsertEnter" },
		},
	},
	--FileTree: NeoTree
	{
		"nvim-neo-tree/neo-tree.nvim",
		keys = {
			{ "<C-n>", "<cmd>Neotree float toggle<CR>" },
		},
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			mappings = {
				["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = false } },
			},
			close_if_last_window = false,
			filesystem = {
				bind_to_cwd = true,
				follow_current_file = { enabled = true },
				hijack_netrw_behavior = "disabled", -- don't auto open

				filtered_items = {
					visible = true,
					show_hidden_count = true,
					hide_dotfiles = true,
					hide_gitignored = false,
					hide_by_name = {
						".git",
						".DS_Store",
						"thumbs.db",
					},
					never_show = {},
				},
			},
		},

		config = function(_, opts)
			require("neo-tree").setup(opts)
		end,
	},
	--Undo: Undotree
	{
		"mbbill/undotree",
		keys = {
			{
				"<leader>lut",
				"<cmd>UndotreeToggle<CR>",
				desc = "Toggle Undotree",
			},
		},
		config = function()
			vim.g.undotree_WindowLayout = 3
		end,
	},
	--Diagnostics: Trouble
	{
		"folke/trouble.nvim",
		opts = {
			modes = {
				project_dia = {
					mode = "diagnostics", -- inherit from diagnostics mode
					filter = {
						any = {
							buf = 1, -- current buffer
							{
								severity = vim.diagnostic.severity.ERROR, -- errors only
								-- limit to files in the current project
								function(item)
									return item.filename:find((vim.loop or vim.uv).cwd(), 1, true)
								end,
							},
						},
					},
				},
			},
		},
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>xp",
				"<cmd>Trouble project_dia<CR>",
				desc = "Project Diagonstics ( Trouble )",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	--Buf: Mini Buf Do
	{
		"nvim-mini/mini.bufremove",
		keys = {
			{
				"<leader>bd",
				function()
					MiniBufremove.delete(0, false) -- delete current buffer safely
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>bD",
				function()
					MiniBufremove.delete(0, true) -- force delete (discard changes)
				end,
				desc = "Force Delete Buffer",
			},
		},
		version = false,
		config = function()
			require("mini.bufremove").setup()
		end,
	},
	--Git
	{
		"NeogitOrg/neogit",
		lazy = true,
		dependencies = {
			"nvim-lua/plenary.nvim", -- required

			"sindrets/diffview.nvim",

			"nvim-telescope/telescope.nvim",
		},
		opts = {
			graph_style = "kitty",
		},

		cmd = "Neogit",
		keys = {
			{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		-- event = "BufRead",
		-- event = "InsertEnter",
		keys = { "<leader>lgt" },

		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "┃" },
					change = { text = "┃" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				signs_staged = {
					add = { text = "┃" },
					change = { text = "┃" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				signs_staged_enable = true,
				signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
				numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
				linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
				word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
				watch_gitdir = {
					follow_files = true,
				},
				auto_attach = true,
				attach_to_untracked = false,
				current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
					delay = 100,
					ignore_whitespace = false,
					virt_text_priority = 100,
					use_focus = true,
				},
				current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
				sign_priority = 6,
				update_debounce = 100,
				status_formatter = nil, -- Use default
				max_file_length = 40000, -- Disable if file is longer than this (in lines)
				preview_config = {
					-- Options passed to nvim_open_win
					border = "single",
					style = "minimal",
					relative = "cursor",
					row = 0,
					col = 1,
				},
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, lhs, rhs, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, lhs, rhs, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							vim.cmd("normal! ]c")
						else
							gitsigns.next_hunk()
						end
					end)

					map("n", "[c", function()
						if vim.wo.diff then
							vim.cmd("normal! [c")
						else
							gitsigns.prev_hunk()
						end
					end)

					-- Actions
					map("n", "<leader>hs", gitsigns.stage_hunk)
					map("n", "<leader>hr", gitsigns.reset_hunk)
					map("v", "<leader>hs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("v", "<leader>hr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("n", "<leader>hS", gitsigns.stage_buffer)
					map("n", "<leader>hu", gitsigns.undo_stage_hunk)
					map("n", "<leader>hR", gitsigns.reset_buffer)
					map("n", "<leader>hp", gitsigns.preview_hunk)
					map("n", "<leader>hb", function()
						gitsigns.blame_line({ full = true })
					end)
					map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
					map("n", "<leader>hd", gitsigns.diffthis)
					map("n", "<leader>hD", function()
						gitsigns.diffthis("~")
					end)
					map("n", "<leader>td", gitsigns.toggle_deleted)
				end,
			})
		end,
	},
	--Ai: Copilot
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		keys = {
			{ "<leader>tc", "<cmd>Copilot enable | Copilot toggle<CR>", mode = "n", desc = "Toggle Copilot" },
			{ "<leader><leader>tc", "<cmd>Copilot disable<CR>", mode = "n", desc = "Toggle Copilot" },
		},
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
			},
		},
	},
	{
		"p00f/clangd_extensions.nvim",
		lazy = true,
		opts = {
			inlay_hints = {
				inline = false,
			},
			ast = {
				--These require codicons (https://github.com/microsoft/vscode-codicons)
				role_icons = {
					type = "",
					declaration = "",
					expression = "",
					specifier = "",
					statement = "",
					["template argument"] = "",
				},
				kind_icons = {
					Compound = "",
					Recovery = "",
					TranslationUnit = "",
					PackExpansion = "",
					TemplateTypeParm = "",
					TemplateTemplateParm = "",
					TemplateParamObject = "",
				},
			},
		},
	},
}
