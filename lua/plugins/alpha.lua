return   {
    "goolord/alpha-nvim",
    dependencies = { 
    'echasnovski/mini.icons'
  },
       config = function ()
         local alpha = require'alpha'
         local dashboard = require'alpha.themes.dashboard'
         dashboard.section.header.val = {
                [[                                 ]],
                [[           ▄ ▄                   ]],
                [[       ▄   ▄▄▄     ▄ ▄▄▄ ▄ ▄     ]],
                [[       █ ▄ █▄█ ▄▄▄ █ █▄█ █ █     ]],
                [[    ▄▄ █▄█▄▄▄█ █▄█▄█▄▄█▄▄█ █     ]],
                [[  ▄ █▄▄█ ▄ ▄▄ ▄█ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄  ]],
                [[  █▄▄▄▄ ▄▄▄ █ ▄ ▄▄▄ ▄ ▄▄▄ ▄ ▄ █ ▄]],
                [[▄ █ █▄█ █▄█ █ █ █▄█ █ █▄█ ▄▄▄ █ █]],
                [[█▄█ ▄ █▄▄█▄▄█ █ ▄▄█ █ ▄ █ █▄█▄█ █]],
                [[    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█ █▄█▄▄▄█    ]],
                [[                                 ]],
                [[                                 ]],

         }
         dashboard.section.buttons.val = {
             dashboard.button( "e", "  Last Session" , ":SessionManager load_last_session<CR>"),
             dashboard.button( "r", "  Sessions" , ":SessionManager<CR>"),
             dashboard.button( "q", "󰅚  Quit NVIM" , ":qa<CR>"),
         }

         dashboard.config.opts.noautocmd = true

         vim.cmd[[autocmd User AlphaReady echo 'ready']]

         alpha.setup(dashboard.config)
     end
 }


