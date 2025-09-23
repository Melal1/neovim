return {
	"linrongbin16/lsp-progress.nvim",
	config = function()
    require("lsp-progress").setup({
  spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  decay = 200,
  console_log = false,
  file_log = false,

  -- Minimal: only percentage, no "done" or full message
  series_format = function(_, _, percentage, done)
    if done then
      return "" -- hide "done"
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
    local lsp_clients = vim.lsp.get_clients()
    local messages_map = {}

    for _, climsg in ipairs(client_messages) do
      messages_map[climsg.name] = climsg.body
    end

    if #lsp_clients > 0 then
      table.sort(lsp_clients, function(a, b)
        return a.name < b.name
      end)

      local builder = {}
      for _, cli in ipairs(lsp_clients) do
        local msg = messages_map[cli.name]
        if msg then
          table.insert(builder, string.format("[%s] %s", cli.name, msg))
        else
          table.insert(builder, string.format("[%s]", cli.name))
        end
      end

      return table.concat(builder, " ")
    end
    return ""
  end,
})

	end,
}
