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

local function run_in_tmux(cmd_str)
	if not os.getenv("TMUX") then
		vim.notify("This command must be used inside tmux", vim.log.levels.WARN)
		return
	end
	local shell_cmd = string.format("clear; %s; echo -e '\\n[Finished] Press Enter to close...'; read", cmd_str)
	vim.system({ "tmux", "split-window", "-v", "-l", "15", shell_cmd }, { detach = true })
end

local function get_project_build_file()
	local file_path = vim.fn.expand("%:p")
	local search_path = file_path ~= "" and vim.fs.dirname(file_path) or vim.fn.getcwd()
	local gradle_files = vim.fs.find({ "build.gradle", "settings.gradle", "build.gradle.kts" }, {
		upward = true,
		limit = 1,
		path = search_path,
		stop = vim.uv.os_homedir(),
	})
	return #gradle_files > 0 and gradle_files[1] or nil
end

local function get_smart_run_cmd(extra_args)
	local build_file = get_project_build_file()
	local file_path = vim.fn.expand("%:p")
	extra_args = extra_args and (" " .. extra_args) or ""

	if build_file then
		return string.format("gradle run%s", extra_args):gsub("%s+$", "")
	elseif vim.bo.filetype == "java" and file_path ~= "" then
		return string.format("java %s%s", file_path, extra_args):gsub("%s+$", "")
	else
		vim.notify("Not in a Gradle project and not a Java file.", vim.log.levels.WARN)
		return nil
	end
end

local setup_handlers = {
	["in"] = function()
		local build_file = get_project_build_file()
		if not build_file or not build_file:match("build%.gradle%.kts$") then
			vim.notify("No build.gradle.kts found! Did init finish?", vim.log.levels.ERROR)
			return
		end

		local content = vim.fn.readfile(build_file)
		for _, line in ipairs(content) do
			if line:match("standardInput") then
				vim.notify("Interactive mode is already enabled.", vim.log.levels.INFO)
				return
			end
		end

		local append_block = {
			"",
			'tasks.named<JavaExec>("run") {',
			"    standardInput = System.`in`",
			"}",
		}
		vim.fn.writefile(append_block, build_file, "a")
		vim.notify("Appended interactive mode to " .. vim.fs.basename(build_file), vim.log.levels.INFO)
	end,

	-- Future Example:
	-- ["guava"] = function()
	--     -- logic to append guava dependency to dependencies block
	-- end,
}

vim.api.nvim_create_user_command("Runner", function(opts)
	local args = opts.fargs
	if #args == 0 then
		vim.notify("Requires an argument: run, init, or set", vim.log.levels.ERROR)
		return
	end

	local cmd_type = args[1]

	if cmd_type == "run" then
		local extra_args = table.concat(args, " ", 2)
		local run_cmd = get_smart_run_cmd(extra_args)
		if run_cmd then
			run_in_tmux(run_cmd)
		end
	elseif cmd_type == "init" then
		local extra_args = {}
		local settings_to_apply = {}

		for i = 2, #args do
			if setup_handlers[args[i]] then
				table.insert(settings_to_apply, args[i])
			else
				table.insert(extra_args, args[i])
			end
		end

		local gradle_args_str = table.concat(extra_args, " ")
		local shell_cmd = string.format("gradle init %s", gradle_args_str):gsub("%s+$", "")

		if #settings_to_apply > 0 then
			local server = vim.v.servername
			for _, setting in ipairs(settings_to_apply) do
				local nvim_callback =
					string.format("nvim --server %s --remote-send '<Cmd>Runner set %s<CR>'", server, setting)
				shell_cmd = shell_cmd .. " && " .. nvim_callback
			end
		end
		run_in_tmux(shell_cmd)
	elseif cmd_type == "set" then
		local setting = args[2]

		if setting and setup_handlers[setting] then
			setup_handlers[setting]()
		else
			local available = table.concat(vim.tbl_keys(setup_handlers), ", ")
			vim.notify(string.format("Invalid setting. Available options: %s", available), vim.log.levels.ERROR)
		end
	else
		vim.notify("Invalid argument. Use 'run', 'init', or 'set'.", vim.log.levels.ERROR)
	end
end, {
	nargs = "+",
	complete = function(ArgLead, CmdLine)
		local parts = vim.split(CmdLine, "%s+", { trimempty = true })

		if #parts == 1 or (#parts == 2 and not CmdLine:match("%s$")) then
			return vim.tbl_filter(function(v)
				return v:match("^" .. ArgLead)
			end, { "run", "init", "set" })
		end

		if parts[2] == "set" or parts[2] == "init" then
			local available_settings = vim.tbl_keys(setup_handlers)
			return vim.tbl_filter(function(v)
				return v:match("^" .. ArgLead)
			end, available_settings)
		end
	end,
	desc = "Generic Project Runner (run, init, set)",
})

vim.keymap.set("n", "<leader>rf", function()
	if vim.bo.filetype ~= "java" then
		return
	end
	local run_cmd = get_smart_run_cmd("")
	if run_cmd then
		run_in_tmux(run_cmd)
	end
end, { desc = "Run Java (Gradle or Single File) in tmux" })
