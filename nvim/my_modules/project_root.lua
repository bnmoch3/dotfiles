local M = {}

local uv = vim.loop

local _opts = {}
local filetype_patterns = {
	c = { ".clang-format" },
	java = { "mvnw", "gradlew", "pom.xml" },
	python = { ".venv", "pyproject.toml" },
	go = { "go.mod" },
}
local _default_patterns = { ".git" }
for k, patterns in pairs(filetype_patterns) do
	for i = 1, #_default_patterns do
		patterns[#patterns + 1] = _default_patterns[i]
	end
end
_opts.patterns = filetype_patterns
_opts.stop_at = vim.fn.expand("~")

function M.find_project_root(bufname)
	local patterns = _opts.patterns[vim.bo.filetype] or _default_patterns
	local buf = bufname or vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
	local home_dir = vim.fn.expand("~")
	local get_parent = function(path)
		return vim.fn.fnamemodify(path, ":h")
	end
	local curr_dir = get_parent(buf)
	local sep = "/" -- for unix paths only
	-- stop just before home_dir
	while curr_dir ~= _opts.stop_at do
		for _, pattern in ipairs(patterns) do
			local pattern_path = table.concat({ curr_dir, pattern }, sep)
			local stat = uv.fs_stat(pattern_path)
			if stat ~= nil then
				return curr_dir, pattern
			end
		end
		curr_dir = get_parent(curr_dir)
	end
	return nil
end

vim.g.setup_project_root_plugin = false
function M.setup()
	if vim.g.setup_project_root_plugin == true then
		return
	end
	if vim.fn.has("unix") == 0 then
		error("project_root only compatible with unix")
	end

	vim.api.nvim_create_user_command("ProjectRoot", function()
		local project_root, pattern = M.find_project_root()
		if project_root == nil then
			print("No project root detected or configured for filetype")
		else
			print(string.format("[%s] %s", pattern, project_root))
		end
	end, {
		nargs = 0,
	})
	vim.g.setup_project_root_plugin = true
end

return M
