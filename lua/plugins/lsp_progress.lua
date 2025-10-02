return {
	"linrongbin16/lsp-progress.nvim",
	event = "BufRead",
	config = function()
		local sorted_clients = nil
		local copilot_name = nil

		vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
			callback = function(args)
				sorted_clients = nil
				if args.data and args.data.client_id then
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if copilot_name == nil and client and client.name == "copilot" then
						local funny_names = {
							"Gamemode 1",
							"Creative",
							"EasyMode",
							"Spectator",
							"Herobrine",
							"Villager",
							"Redstone",
							"Code Spawner",
							"No Xp",
							"Copilot",
							"",
						}
						copilot_name = funny_names[math.random(#funny_names)]
					end
				end
			end,
		})

		require("lsp-progress").setup({
			spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
			decay = 200,
			console_log = false,
			file_log = false,

			series_format = function(_, _, percentage, done)
				if done then
					return ""
				end
				if percentage then
					return string.format("%d%%", percentage)
				end
				return nil
			end,

			client_format = function(client_name, spinner, series_messages)
				if #series_messages > 0 then
					return {
						name = client_name,
						body = spinner .. " " .. table.concat(series_messages, ", "),
					}
				end
				return { name = client_name }
			end,

			format = function(client_messages)
				if not sorted_clients then
					local clients = vim.lsp.get_clients()
					table.sort(clients, function(a, b)
						return a.name < b.name
					end)
					sorted_clients = clients
				end

				local messages_map = {}
				for _, climsg in ipairs(client_messages) do
					messages_map[climsg.name] = climsg.body
				end

				local builder = {}
				local seen = {}

				for _, cli in ipairs(sorted_clients) do
					if not seen[cli.name] then
						local display_name = cli.name
						if cli.name == "copilot" and copilot_name then
							display_name = copilot_name
						end

						local msg = messages_map[cli.name]
						if msg then
							table.insert(builder, string.format("[%s] %s", display_name, msg))
						else
							table.insert(builder, string.format("[%s]", display_name))
						end
						seen[cli.name] = true
					end
				end

				return table.concat(builder, " ")
			end,
		})
	end,
}
