return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
			{ "hrsh7th/cmp-path", event = "InsertEnter" },
			{ "hrsh7th/cmp-buffer", event = "InsertEnter" },
			{ "hrsh7th/cmp-nvim-lsp-signature-help", event = "InsertEnter" },
			{ "saadparwaiz1/cmp_luasnip", event = "InsertEnter" },
			{
				"L3MON4D3/LuaSnip",
				-- event = { 'BufReadPre', 'BufNewFile' },
        event = "InsertEnter",
				build = (function()
					if vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					{ "rafamadriz/friendly-snippets", event = "InsertEnter" },
				},
			},
		},
		config = function()
			-- Your config remains unchanged
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")

			local cmp_kinds = {
				Text = "  ", Method = "  ", Function = "  ", Constructor = "  ",
				Field = "  ", Variable = "  ", Class = "  ", Interface = "  ",
				Module = "  ", Property = "  ", Unit = "  ", Value = "  ",
				Enum = "  ", Keyword = "  ", Snippet = "  ", Color = "  ",
				File = "  ", Reference = "  ", Folder = "  ", EnumMember = "  ",
				Constant = "  ", Struct = "  ", Event = "  ", Operator = "  ",
				TypeParameter = "  ",
			}

			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				completion = { completeopt = "menu,menuone,noinsert" },
				snippet = {
					expand = function(args) luasnip.lsp_expand(args.body) end,
				},
				formatting = {
					format = function(_, vim_item)
						vim_item.kind = (cmp_kinds[vim_item.kind] or "") .. vim_item.kind
						return vim_item
					end,
				},
				window = {
					completion = cmp.config.window.bordered({
						border = "single",
						winhighlight = "Normal:NormalFloat,FloatBorder:BorderBG,CursorLine:PmenuSel",
					}),
					documentation = cmp.config.window.bordered({
						max_width = 80,
						max_height = 20,
						border = "single",
					}),
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp_signature_help" },
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{
						name = "path",
						option = { trailing_slash = true },
					},
				}),
				mapping = cmp.mapping.preset.insert({
					["<C-f>"] = cmp.mapping.scroll_docs(-1),
					["<C-b>"] = cmp.mapping.scroll_docs(1),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done()),
			})
      -- Load snippets
      require("config.Snippets.simple")
		end,
	},
}

