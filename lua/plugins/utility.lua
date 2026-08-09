return {
	--- c sharp
	-- lazy.nvim
	{
		"GustavEikaas/easy-dotnet.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
		ft = "cs",
		config = function()
			local dotnet = require("easy-dotnet")
			dotnet.setup({
				external_terminal = {
					command = "kitty",
					args = { "--hold", "--" },
				},
				lsp = {
					enabled = false,
				},
				debugger = {
					bin_path = "netcoredbg",
					engine = "netcoredbg",
					console = "externalTerminal",
					apply_value_converters = true,
					auto_register_dap = true,
					mappings = {
						open_variable_viewer = { lhs = "T", desc = "open variable viewer" },
					},
				},
			})

			vim.keymap.set("n", "<leader>nr",  dotnet.run,                 { desc = "dotnet: run (picker)" })
			vim.keymap.set("n", "<leader>nR", dotnet.run_default,         { desc = "dotnet: run default project" })
			vim.keymap.set("n", "<leader>np",  dotnet.run_profile,         { desc = "dotnet: run --launch-profile" })
			vim.keymap.set("n", "<leader>nP",  dotnet.run_profile_default, { desc = "dotnet: run default with profile" })
			vim.keymap.set("n", "<leader>nw",  dotnet.watch,               { desc = "dotnet: watch (picker)" })
			vim.keymap.set("n", "<leader>nW", dotnet.watch_default,        { desc = "dotnet: watch default project" })

			vim.keymap.set("n", "<leader>nb", dotnet.build,    { desc = "dotnet: build (picker)" })
			vim.keymap.set("n", "<leader>nt", dotnet.test,     { desc = "dotnet: test (picker)" })
			vim.keymap.set("n", "<leader>nc", dotnet.clean,     { desc = "dotnet: clean" })

			vim.keymap.set("n", "<leader>nd",  dotnet.debug,         { desc = "dotnet: debug (picker)" })
			vim.keymap.set("n", "<leader>nD", dotnet.debug_default, { desc = "dotnet: debug default" })

			vim.keymap.set("n", "<leader>no", dotnet.testrunner, { desc = "dotnet: toggle test runner" })
		end,
	},

	{
		"seblyng/roslyn.nvim",
		---@module 'roslyn.config'
		---@type RoslynNvimConfig
		opts = {
			filewatching = "roslyn",
		},
		ft = { "cs" },
	},
	-- BuildSystem: make.nvim
	{
		dir = "~/Dev/projects/lua/make.nvim",
		name = "make.nvim",
		enabled = true,
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		ft = { "cpp" },
		---@type make.Options
		opts = {
			SourceExtensions = { ".cpp", ".c", ".cc", ".cxx" },
			RootMarkers = { ".git", "src", "include", "build", "Makefile" },
			MaxSearchLevels = 5,
			CacheUseHash = true,
			CacheFormat = "luabytecode", -- or "mpack"
			CacheDir = ".cache/make.nviM",
			CacheLog = false,
			EnableBackup = false,
		},
		config = function()
			vim.keymap.set("n", "<leader>rf", function()
				if vim.bo.filetype == "cpp" then
					vim.cmd("Make run")
				end
			end, { desc = "Run the current cpp file with make.nvim" })
		end,
	},

	-- Git
	{
		"sindrets/diffview.nvim",
		-- Only load when these commands are used
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		keys = {
			{ "<leader>GD", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
			{ "<leader>GH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview Current File History" },
			{ "<leader>GQ", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
		},
		opts = {
			enhanced_diff_hl = true, -- Better highlights
			use_icons = true,
			icons = {
				folder_closed = "",
				folder_open = "",
			},
			signs = {
				fold_closed = "",
				fold_open = "",
				done = "✓",
			},
			view = {
				-- Customize the layout of the 3-way merge
				merge_tool = {
					-- layout = "diff3_horizontal",
					disable_diagnostics = true, -- Don't show red squiggly lines during conflicts
				},
			},
		},
	},

	-- CodeCompanion Ai
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},

		cmd = { "CodeCompanion", "CodeCompanionChat" },

		-- 1. Define your options here
		opts = {
			interactions = {
				chat = {
					adapter = {
						name = "gemini",
						model = "gemini-3.1-flash-lite-preview",
					},
				},
				inline = {
					adapter = {
						name = "gemini",
						model = "gemini-3.1-flash-lite-preview",
					},
				},
				cmd = {
					adapter = {
						name = "gemini",
						model = "gemini-3.1-flash-lite-preview",
					},
				},
			},
		},
		-- 2. You MUST pass 'opts' into this function
		config = function(_, opts)
			-- 3. Tell CodeCompanion to actually use your opts!
			require("codecompanion").setup(opts)

			-- 4. Your Keymaps
			vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
			vim.keymap.set(
				{ "n", "v" },
				"<LocalLeader>a",
				"<cmd>CodeCompanionChat Toggle<cr>",
				{ noremap = true, silent = true }
			)
			vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

			vim.cmd([[cab cc CodeCompanion]])
		end,
	},

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
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
      {"<leader>daw", "<cmd>DapViewWatch<CR>",  desc = "Add under cursor to watch list" },
      {"<leader>dfr",function() local w = require('dap.ui.widgets'); w.sidebar(w.frames).open() end , desc = "Call stack"},
      {"<leader>dNV",  function() require("osv").launch({port = 8086}) end,                          desc = "Launch OSV"},
      {"<leader>dt", function()
        require("dap").terminate()
        _G.DAP_IS_ACTIVE = false
        require("nvim-dap-virtual-text").disable()
        pcall(function()
          require("config.statusline").refresh_winbar()
        end)
      end, desc = "Terminate"},
    },
		config = function()
			local dap = require("dap")
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
						local msg = require("make").Debug(true)
						return msg
					end,
					stopAtEntry = false,
					setupCommands = {
						{
							text = "-enable-pretty-printing",
							description = "enable pretty printing",
							ignoreFailures = false,
						},
					},
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
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					stopAtEntry = false,
					setupCommands = {
						{
							text = "-enable-pretty-printing",
							description = "enable pretty printing",
							ignoreFailures = false,
						},
					},
				},
				{
					name = "Launch file",
					type = "cppdbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtEntry = false,
					setupCommands = {
						{
							text = "-enable-pretty-printing",
							description = "enable pretty printing",
							ignoreFailures = false,
						},
					},
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
				require("nvim-dap-virtual-text").enable()
				pcall(function()
					require("config.statusline").refresh_winbar()
				end)
			end
			dap.listeners.before.launch.st = function()
				_G.DAP_IS_ACTIVE = true
				require("nvim-dap-virtual-text").enable()
				pcall(function()
					require("config.statusline").refresh_winbar()
				end)
			end
			dap.listeners.before.event_terminated.st = function()
				_G.DAP_IS_ACTIVE = false
				require("nvim-dap-virtual-text").disable()
				pcall(function()
					require("config.statusline").refresh_winbar()
				end)
			end
			dap.listeners.before.event_exited.st = function()
				_G.DAP_IS_ACTIVE = false
				require("nvim-dap-virtual-text").disable()
				pcall(function()
					require("config.statusline").refresh_winbar()
				end)
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
	-- {
	-- 	"nvim-telescope/telescope.nvim",
	-- 	tag = "0.1.8",
	-- 	cmd = "Telescope",
	-- 	-- Looks messy btw , but this is a simple solution
	--    -- stylua: ignore
	-- 	keys = {
	-- 		{ "<leader>opc",function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,desc = "Find Plugin File" },
	-- 		{"<leader>frg",function() require("telescope.builtin").registers() end,desc = "Registers",},
	-- 		{"<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find Files",},
	-- 		{"<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live Grep",},
	-- 		{"<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers",},
	-- 		{"<leader>fp", function() require("telescope").extensions.projects.projects() end, desc = "Projects",},
	-- 		{"<leader>fSt", function() local word = vim.fn.expand("<cWORD>") require("telescope.builtin").grep_string({ search = word }) end, desc = "Grep WORD under cursor (includes punctuation)",},
	-- 		{"<leader>fst", function() local word = vim.fn.expand("<cword>") require("telescope.builtin").grep_string({ search = word }) end, desc = "Grep word under cursor (stops at punctuation)",},
	-- 		{"<leader>fo", function() require("telescope.builtin").oldfiles() end, desc = "Old Files",},
	-- 		{"<leader>OO", function() require("telescope.builtin").lsp_document_symbols() end, desc = "LSP Document Symbols",},
	-- 		{"<leader>fdia", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics",},
	-- 		{"<leader>frf",function () require("telescope.builtin").lsp_references() end, desc = "LSP References",},
	-- 	},
	--
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"jmacadie/telescope-hierarchy.nvim",
	-- 		{
	-- 			"nvim-telescope/telescope-fzf-native.nvim",
	-- 			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
	-- 		},
	-- 		"nvim-telescope/telescope-ui-select.nvim",
	-- 		"ahmedkhalf/project.nvim",
	-- 	},
	-- 	config = function()
	-- 		local telescope = require("telescope")
	-- 		local actions = require("telescope.actions")
	-- 		telescope.setup({
	-- 			defaults = {
	-- 				preview = {
	-- 					treesitter = false,
	-- 				},
	-- 				mappings = {
	-- 					i = {
	-- 						["<esc>"] = actions.close,
	-- 					},
	-- 				},
	-- 				path_display = {
	-- 					"filename_first",
	-- 				},
	-- 				previewer = false,
	-- 				prompt_prefix = "    ",
	-- 				selection_caret = " ",
	-- 				file_ignore_patterns = { "node_modules", "package-lock.json", "lazy-lock.json" },
	-- 				scroll_strategy = "limit", -- don't rollover when scrolling
	-- 				initial_mode = "insert",
	-- 				select_strategy = "reset",
	-- 				sorting_strategy = "ascending",
	-- 				color_devicons = true,
	-- 				border = true,
	-- 				borderchars = {
	-- 					prompt = { "─", "│", "─", "│", "┌", "┐", "│", "│" },
	-- 					results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
	-- 					preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
	-- 				},
	-- 				set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
	-- 				layout_config = {
	-- 					prompt_position = "top",
	-- 					preview_cutoff = 120,
	-- 				},
	-- 				vimgrep_arguments = {
	-- 					"rg",
	-- 					"--color=never",
	-- 					"--no-heading",
	-- 					"--with-filename",
	-- 					"--line-number",
	-- 					"--column",
	-- 					"--smart-case",
	-- 					"--hidden",
	-- 					"--glob=!.git/",
	-- 				},
	-- 			},
	-- 			pickers = {
	-- 				buffers = {
	-- 					mappings = {
	-- 						i = {
	-- 							["<c-d>"] = actions.delete_buffer,
	-- 						},
	-- 						n = {
	-- 							["<c-d>"] = actions.delete_buffer,
	-- 						},
	-- 					},
	-- 					previewer = false,
	-- 					initial_mode = "normal",
	-- 					-- theme = "dropdown",
	-- 					layout_config = {
	-- 						height = 0.4,
	-- 						width = 0.6,
	-- 						prompt_position = "top",
	-- 						preview_cutoff = 120,
	-- 					},
	-- 				},
	-- 				current_buffer_fuzzy_find = {
	-- 					previewer = true,
	-- 					layout_config = {
	-- 						prompt_position = "top",
	-- 						preview_cutoff = 120,
	-- 					},
	-- 				},
	-- 			},
	-- 			extensions = {
	-- 				["ui-select"] = {
	-- 					require("telescope.themes").get_dropdown({
	-- 						previewer = false,
	-- 						initial_mode = "normal",
	-- 						sorting_strategy = "ascending",
	-- 						layout_strategy = "horizontal",
	-- 						layout_config = {
	-- 							horizontal = {
	-- 								width = 0.5,
	-- 								height = 0.4,
	-- 								preview_width = 0.6,
	-- 							},
	-- 						},
	-- 					}),
	-- 				},
	-- 			},
	-- 		})
	--
	-- 		-- Setup project.nvim
	-- 		require("project_nvim").setup({})
	--
	-- 		-- Load extensions
	-- 		telescope.load_extension("ui-select")
	-- 		telescope.load_extension("projects")
	-- 		telescope.load_extension("fzf")
	-- 		telescope.load_extension("hierarchy")
	-- 	end,
	-- },
	-- File Picker : Snacks
		"folke/snacks.nvim",
		VeryLazy = true,
		config = function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "OilActionsPost",
				callback = function(event)
					if event.data.actions[1].type == "move" then
						Snacks.rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
					end
				end,
			})
			Snacks.setup({
				picker = { enabled = true },
				rename = { enabled = true },
			})
		end,
		---@type snacks.Config
				"<leader><space>",
				function()
					Snacks.picker.smart()
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader>,",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>/",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			-- {
			-- 	"<leader>n",
			-- 	function()
			-- 		Snacks.picker.notifications()
			-- 	end,
			-- 	desc = "Notification History",
			-- },
			-- {
			-- 	"<leader>e",
			-- 	function()
			-- 		Snacks.explorer()
			-- 	end,
			-- 	desc = "File Explorer",
			-- },
			-- find
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fc",
				function()
					Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config File",
			},
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fg",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Git Files",
			},
			{
				"<leader>fp",
				function()
					Snacks.picker.projects()
				end,
				desc = "Projects",
			},
			{
				"<leader>frr",
				function()
					Snacks.picker.recent()
				end,
				desc = "Recent",
			},
			-- git
			-- {
			-- 	"<leader>gb",
			-- 	function()
			-- 		Snacks.picker.git_branches()
			-- 	end,
			-- 	desc = "Git Branches",
			-- },
			-- {
			-- 	"<leader>gl",
			-- 	function()
			-- 		Snacks.picker.git_log()
			-- 	end,
			-- 	desc = "Git Log",
			-- },
			-- {
			-- 	"<leader>gL",
			-- 	function()
			-- 		Snacks.picker.git_log_line()
			-- 	end,
			-- 	desc = "Git Log Line",
			-- },
			{
				"<leader>gs",
				function()
					Snacks.picker.git_status()
				end,
				desc = "Git Status",
			},
			-- {
			-- 	"<leader>gS",
			-- 	function()
			-- 		Snacks.picker.git_stash()
			-- 	end,
			-- 	desc = "Git Stash",
			-- },
			{
				"<leader>gd",
				function()
					Snacks.picker.git_diff()
				end,
				desc = "Git Diff (Hunks)",
			},
			-- {
			-- 	"<leader>gf",
			-- 	function()
			-- 		Snacks.picker.git_log_file()
			-- 	end,
			-- 	desc = "Git Log File",
			-- },
			-- gh
			-- Grep
			{
				"<leader>b/",
				function()
					Snacks.picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>B/",
				function()
					Snacks.picker.grep_buffers()
				end,
				desc = "Grep Open Buffers",
			},
			{
				"<leader>w/",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Visual selection or word",
				mode = { "n", "x" },
			},
			-- search
			{
				'<leader>rg"',
				function()
					Snacks.picker.registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>shis",
				function()
					Snacks.picker.search_history()
				end,
				desc = "Search History",
			},
			{
				"<leader>sa",
				function()
					Snacks.picker.autocmds()
				end,
				desc = "Autocmds",
			},
			{
				"<leader>sC",
				function()
					Snacks.picker.commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>sD",
				function()
					Snacks.picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>sh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>sH",
				function()
					Snacks.picker.highlights()
				end,
				desc = "Highlights",
			},
			{
				"<leader>si",
				function()
					Snacks.picker.icons()
				end,
				desc = "Icons",
			},
			{
				"<leader>sj",
				function()
					Snacks.picker.jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>sm",
				function()
					Snacks.picker.marks()
				end,
				desc = "Marks",
			},
			{
				"<leader>sM",
				function()
					Snacks.picker.man()
				end,
				desc = "Man Pages",
			},
			{
				"<leader>sp",
				function()
					Snacks.picker.lazy()
				end,
				desc = "Search for Plugin Spec",
			},
			{
				"<leader>sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>sR",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>su",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo History",
			{
				"<leader>suC",
				function()
					Snacks.picker.colorschemes()
				end,
				desc = "Colorschemes",
			},
			-- LSP
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"gD",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"gI",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"gy",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto T[y]pe Definition",
			},
			{
				"gai",
				function()
					Snacks.picker.lsp_incoming_calls()
				end,
				desc = "C[a]lls Incoming",
			},
			{
				"gao",
				function()
					Snacks.picker.lsp_outgoing_calls()
				end,
				desc = "C[a]lls Outgoing",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>sS",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},
			-- Other	--TODO:
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
		dependencies = {
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
		opts = {},
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
				"<leader>xs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>xl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xq",
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
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
}
