local home_dir = vim.fn.expand("~")

-- config workspace and root dir
local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml" })
local workspaces_dir = home_dir .. "/LOCAL/dev/jdtls_workspaces/"
local workspace_dir = nil
if root_dir == nil then
	local cwd = vim.fn.getcwd()
	local project_name = string.gsub(cwd, "/", ".")
	root_dir = cwd
	workspace_dir = workspaces_dir .. project_name
else
	workspace_dir = workspaces_dir .. string.gsub(root_dir, "/", ".")
end

local config = {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xms1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",

		"-jar",
		home_dir .. "/LOCAL/pkg/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",

		"-configuration",
		home_dir .. "/LOCAL/pkg/jdtls/config_linux",

		"-data",
		workspace_dir,
	},

	root_dir = root_dir,

	settings = {
		java = {},
	},
}

-- start new client & server, or attach to existing depending on the `root_dir`
-- currently only configured for linux
if vim.fn.has("linux") == 1 then
	require("jdtls").start_or_attach(config)
end

vim.o.foldmethod = "indent"
