return {
	{
    event = {"BufRead","BufNewFile"},
		"saghen/blink.cmp",
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

				["<C-l>"] = { "snippet_forward", "fallback" },
				["<C-h>"] = { "snippet_backward", "fallback" },
        ["<Tab>"] = false,
        ["<S-Tab>"] = false,
			},

			appearance = {
        nerd_font_variant = "mono"
			},

			completion = { documentation = { auto_show = false } },

			sources = {
				default = { "snippets", "lsp", "path", "buffer" },
        providers = {
          lsp = {
            score_offset = 9 ,
          },
          snippets = {
            score_offset = 10 ,
          }
        }
			},
      fuzzy = { implementation = "rust" }
		},
		opts_extend = { "sources.default" },
	},
}
