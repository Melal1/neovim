local home = vim.uv.os_homedir()
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local workspace_data_dir = home .. "/.local/share/nvim/workspace_data/" .. project_name

local config = {
	name = "jdtls",
	cmd = {
		"jdtls",
		"--jvm-arg=--add-modules=jdk.incubator.vector",
		"--jvm-arg=-XX:+IgnoreUnrecognizedVMOptions",
		"-data",
		workspace_data_dir,
	},
	-- This looks for your project root markers
	root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw", "build.gradle.kts" }),

	settings = {
		java = {
			signatureHelp = { enabled = true },
			contentProvider = { preferred = "fernflower" },
		},
	},
}

require("jdtls").start_or_attach(config)
