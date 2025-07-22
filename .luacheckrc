-- for working with neovim lua scripts
globals = {
	"vim",
	"pp",
}

-- Ignore unused variables starting with underscore
ignore = {
	"212/_.*", -- 212 is the "unused argument" warning code
	"213/_.*", -- 213 is the "unused loop variable" warning code
}

-- Alternative: you can also use unused_args = false and unused = false
-- unused_args = false  -- This ignores all unused arguments
-- unused = false       -- This ignores all unused variables
