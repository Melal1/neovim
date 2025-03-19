return {

	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")

			lspconfig.lua_ls.setup({
				capabilities = capabilities, -- Add this for consistency
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})

			lspconfig.clangd.setup({
				capabilities = capabilities, -- Add this for consistency
			})

			lspconfig.bashls.setup({

				capabilities = capabilities, -- Add this for consistency
			})
			lspconfig.nil_ls.setup({

				capabilities = capabilities, -- add this for consistency
			})

			vim.keymap.set("n", "<leader>lmk", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<C-Space>", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
			vim.keymap.set("n", "gD", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "K", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, {})
		end,
	},
}
