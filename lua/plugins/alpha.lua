return {
  "goolord/alpha-nvim",
  dependencies = {
    "echasnovski/mini.icons",
  },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Define all headers in a table (each header is a table of strings)
    local headers = {
      {
        "                                ",
        "                                ",
        "                                ",
        "• ▌ ▄ ·. ▄▄▄ .▄▄▌   ▄▄▄· ▄▄▌  ",
        "·██ ▐███▪▀▄.▀·██•  ▐█ ▀█ ██•  ",
        "▐█ ▌▐▌▐█·▐▀▀▪▄██ ▪ ▄█▀▀█ ██ ▪ ",
        "██ ██▌▐█▌▐█▄▄▌▐█▌ ▄▐█▪ ▐▌▐█▌ ▄",
        "▀▀  █▪▀▀▀ ▀▀▀ .▀▀▀  ▀  ▀ .▀▀▀ ",
        "                                ",
        "                                ",
        "                                ",
      },
      {
        "                                            ",
        "                                            ",
        "███▄ ▄███▓ ▓█████  ██▓    ▄▄▄       ██▓   ",
        "▓██▒▀█▀ ██▒ ▓█   ▀ ▓██▒   ▒████▄    ▓██▒   ",
        "▓██    ▓██░ ▒███   ▒██░   ▒██  ▀█▄  ▒██░   ",
        "▓██    ▒██  ▒▓█  ▄ ▒██░   ░██▄▄▄▄██ ▒██░   ",
        "▒▒██▒   ░██▒▒░▒████▒░██████▒▓█   ▓██▒░██████",
        "░░ ▒░   ░  ░░░░ ▒░ ░░ ▒░▓  ░▒▒   ▓▒█░░ ▒░▓  ",
        "░░  ░      ░░ ░ ░  ░░ ░ ▒  ░ ░   ▒▒ ░░ ░ ▒  ",
        " ░      ░       ░     ░ ░    ░   ▒     ░ ░  ",
        "░       ░   ░   ░  ░    ░        ░  ░    ░  ",
        "                                            ",
        "                                            ",
      },
      {
        "                                            ",
        "                                            ",
        "                                            ",
        "███╗   ███╗███████╗██╗      █████╗ ██╗     ",
        "████╗ ████║██╔════╝██║     ██╔══██╗██║     ",
        "██╔████╔██║█████╗  ██║     ███████║██║     ",
        "██║╚██╔╝██║██╔══╝  ██║     ██╔══██║██║     ",
        "██║ ╚═╝ ██║███████╗███████╗██║  ██║███████╗",
        "╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝",
        "                                            ",
        "                                            ",
      },
      {
        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
        "⣿⣿⣿⣿⣿⣿⠏⠁⣾⣿⡙⠁⠛⣹⣿⣄⠘⣿⣿⣿⣿⣿⣿",
        "⣿⣿⣿⣿⡟⠃⣰⣿⣿⣿⣿⠀⢸⣿⣿⣿⣷⡈⠻⣿⣿⣿⣿",
        "⣿⣿⡿⠇⠀⣼⣿⣿⣿⣿⣿⠀⢸⣿⣿⣿⣿⣿⡀⠘⢿⣿⣿",
        "⣿⡏⠁⠀⢾⣿⣿⣿⣿⣿⣿⠀⢸⣿⣿⣿⣿⣿⡿⠀⠀⣩⣿",
        "⣿⣿⣷⣄⠀⠙⠻⣿⣿⣿⣿⠀⢸⣿⣿⣿⡿⠋⠀⣠⣾⣿⣿",
        "⣿⣿⣿⣿⣷⣄⡀⠈⠻⢿⣿⠀⢸⣿⠟⠁⠀⣠⣾⣿⣿⣿⣿",
        "⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠙⠀⠘⠁⠀⣠⣾⣿⣿⣿⣿⣿⣿",
        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⡦⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿",
        "⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿",
        "⣿⣿⣿⣿⣿⡿⠋⠀⠀⣠⣾⠄⠀⣷⣦⡀⠀⠙⢿⣿⣿⣿⣿",
        "⣿⣿⣿⡿⠋⠀⢀⣴⣿⣿⣿⠂⠀⣿⣿⣿⣦⡀⠀⠙⠻⣿⣿",
        "⣿⠟⠋⠀⢀⣴⣿⣿⣿⣿⣿⡃⠀⣿⣿⣿⣿⣿⣷⡄⠀⠈⠻",
        "⣷⣦⡀⠀⠙⠻⣿⣿⣿⣿⣿⡇⠀⣿⣿⣿⣿⣿⠟⠁⠀⣠⣾",
        "⣿⣿⣿⣦⡀⠀⠈⠻⣿⣿⣿⡇⠀⣿⣿⣿⠟⠁⠀⣠⣾⣿⣿",
        "⣿⣿⣿⣿⣿⣦⡄⠀⠈⢻⣿⡇⠀⣿⣿⠃⠀⠀⣼⣿⣿⣿⣿",
        "⣿⣿⣿⣿⣿⣿⣷⣄⡀⠀⠙⠇⠀⠟⠁⠀⣠⣾⣿⣿⣿⣿⣿",
        "⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿",
        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿",
      },
    }

    -- Select a random header
    math.randomseed(os.time()) -- Seed the random number generator
    local random_header = headers[math.random(#headers)]
    local function footer()
      local stats = require("lazy").stats()
      local total_plugins = stats.count
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      local datetime = os.date(" %d-%m-%Y")
      return "   v"
          .. vim.version().major
          .. "."
          .. vim.version().minor
          .. "."
          .. vim.version().patch
          .. "   "
          .. total_plugins
          .. " plugins loaded in "
          .. ms
          .. "ms"
          .. "  "
          .. datetime
    end
    dashboard.section.footer.val = footer()
    dashboard.section.footer.opts.hl = "String"

    -- Set the random header
    dashboard.section.header.val = random_header

    dashboard.section.buttons.val = {
      dashboard.button("e", "  Last Session", ":SessionManager load_last_session<CR>"),
      dashboard.button("r", "  Sessions", ":SessionManager<CR>"),
      dashboard.button("c", "  Config", ":Neotree focus $HOME/.config/nvim<CR>"),
      dashboard.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
    }

    dashboard.config.opts.noautocmd = true

    vim.cmd([[ autocmd User AlphaReady echo 'Hello ' . expand('$USER') . ' ! Welcome to NeoVim!' ]])
    alpha.setup(dashboard.config)
  end,
}
