-- MY INIT.LUA

-- ============================================================================
--                              HELPERS
-- ============================================================================
-- {{
function pp(obj)
	require("my_modules.helpers").pretty_print(obj)
end

local nnoremap = require("my_modules.helpers").nnoremap
local vnoremap = require("my_modules.helpers").vnoremap

-- bootstrap packer installation
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap = nil
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

-- ============================================================================
--                              PLUGINS
-- ============================================================================
require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	use("alvan/vim-closetag")
	use("tpope/vim-commentary") -- for commenting out lines
	use("tpope/vim-surround") -- for surround selected text with given char
	-- use("jiangmiao/auto-pairs") -- for autoclosing {},(), [], "", '', ``
	use("milkypostman/vim-togglelist")
	use("nvim-lua/plenary.nvim")
	use("nvim-treesitter/nvim-treesitter")
	use("williamboman/mason.nvim")
	use("jose-elias-alvarez/null-ls.nvim")
	use("neovim/nvim-lspconfig")
	use("simrat39/rust-tools.nvim")
	use("mfussenegger/nvim-jdtls")
	use({ "folke/trouble.nvim", requires = { "folke/lsp-colors.nvim" } })
	use("stevearc/aerial.nvim")
	use("rmagatti/goto-preview")
	use("ray-x/lsp_signature.nvim")
	use({ "yioneko/nvim-yati", requires = "nvim-treesitter/nvim-treesitter" })

	-- autocompletion
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")

	-- snippets
	use("saadparwaiz1/cmp_luasnip")
	use("L3MON4D3/LuaSnip")
	use("rafamadriz/friendly-snippets")

	-- themes, styling
	-- use("chriskempson/base16-vim")
	use("RRethy/nvim-base16")
	use("DanilaMihailov/beacon.nvim") -- temporarily highlight cursor's curr line
	use("lukas-reineke/indent-blankline.nvim") -- indentation guides

	use("preservim/tagbar")
	use("christoomey/vim-tmux-navigator") -- add tmux navigation compatibility
	vim.g.tmux_navigator_save_on_switch = true
	vim.g.tmux_navigator_disable_when_zoomed = true
	use("kshenoy/vim-signature") -- for toggling, displaying and navigating marks
	use("tpope/vim-unimpaired") -- tim-pope's, for quick navigation of lists
	use("ap/vim-buftabline") -- display buffer list on tabline
	use("kyazdani42/nvim-web-devicons")
	use({ "kyazdani42/nvim-tree.lua", requires = { "kyazdani42/nvim-web-devicons" } })
	use({ "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons" } })
	use({ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } })

	-- langs
	use("ziglang/zig.vim")
	use("dijkstracula/vim-plang")

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end
end)

-- ============================================================================
--                              GENERAL
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.o.background = "dark"
vim.o.wrap = false -- disable line wrapping
vim.o.showmode = false -- do not display mode in statusline, will be displayed by statusbar
vim.o.mouse = vim.o.mouse .. "a" -- enable mouse support
vim.o.clipboard = "unnamed"
vim.o.showmatch = true -- jump to the matching bracket briefly when a bracket is inserted
vim.o.matchtime = 3
vim.o.splitbelow = true
vim.o.splitright = true

vim.o.number = true
vim.o.numberwidth = 5
vim.o.relativenumber = true
vim.o.cmdheight = 1
vim.wo.colorcolumn = "80"

vim.o.swapfile = false -- no swapfile, no backups
vim.o.backup = false
vim.o.writebackup = false
vim.o.undofile = true
vim.o.shortmess = vim.o.shortmess .. "I" -- disable the default Vim startup message.
vim.o.shortmess = vim.o.shortmess .. "c" -- dont pass messages to |ins-completion-menu|

vim.o.grepprg = "rg --vimgrep --smart-case --follow"
vim.o.hlsearch = false
vim.o.incsearch = true

-- quickfix
vim.g.toggle_list_no_mappings = true
nnoremap("<localleader>q", "<cmd>call ToggleQuickfixList()<cr>")
nnoremap("<localleader>l", "<cmd>call ToggleLocationList()<cr>")

-- indenting
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
-- vim.o.autoindent = true
vim.o.smartindent = true

-- ignorecase makes all searches case-insensitive
-- smartcase overrides the ignorecase option if the search pattern contains
-- at least one uppercase character. That is, if there's an uppercase
-- character, the search becomes case-sensistive
-- For situations where you want to override ignorecase for an all-lowercase
-- search patter, append \C to the pattern, for example /foo\C will not match
-- Foo and FOO
vim.o.ignorecase = true
vim.o.smartcase = true

-- TODO install filetype
-- vim.g.did_load_filetypes = 1

require("base16-colorscheme").setup({
	base00 = "#262626",
	base01 = "#3a3a3a",
	base02 = "#4e4e4e",
	base03 = "#8a8a8a",
	base04 = "#949494",
	base05 = "#dab997",
	base06 = "#d5c4a1",
	base07 = "#ebdbb2",
	base08 = "#d75f5f",
	base09 = "#ff8700",
	base0A = "#ffaf00",
	base0B = "#afaf00",
	base0C = "#85ad85",
	base0D = "#83adad",
	base0E = "#d485ad",
	base0F = "#d65d0e",
})
-- vim.cmd("colorscheme base16-gruvbox-dark-pale")
vim.o.termguicolors = true

vim.g.beacon_size = 60
vim.g.beacon_timeout = 2000
vim.cmd([[highlight Beacon guibg=LightGray ctermbg=8]])
vim.g.beacon_ignore_filetypes = { "qf", "NvimTree" }

vim.g.indentLine_char = "|"
vim.g.indent_blankline_user_treesitter = true
vim.g.indent_blankline_show_first_indent_level = false

-- ============================================================================
--                              KEYMAPS
-- ============================================================================
-- for toggling visual selection
nnoremap("<localleader>v", "viw")
vnoremap("<localleader>v", "b")

-- for toggling tagbar
nnoremap("<localleader>t", ":TagbarToggle<CR>")

-- add key combos for navigating between split windows
nnoremap("<C-J>", " <C-W><C-J> ")
nnoremap("<C-K>", " <C-W><C-K> ")
nnoremap("<C-L>", " <C-W><C-L> ")
nnoremap("<C-H>", " <C-W><C-H> ")

-- for clearing highlighting after a search
nnoremap("\\", ":<C-u>nohlsearch<CR>")

-- center to line when searching
nnoremap("n", "nzz")
nnoremap("N", "Nzz")
nnoremap("*", "*zz")
-- ============================================================================
--                              NVIM-TREE
-- ============================================================================
local nvim_tree = require("nvim-tree")
local function nvim_tree_search_files(node)
	local dir = vim.fn.getcwd()
	if node.parent ~= nil then
		dir = node.parent.cwd or node.parent.absolute_path
	end
	require("telescope.builtin").find_files({ cwd = dir })
end
local nvim_tree_key_mappings = {
	-- nvim-tree
	{ key = "?", action = "toggle_help" },
	{ key = "H", action = "toggle_dotfiles" },
	{ key = "I", action = "toggle_git_ignored" },
	{ key = "R", action = "refresh" },
	{ key = "Q", action = "close" },
	{ key = "P", action = "parent_node" },
	{ key = "D", action = "close_node" },
	{ key = "W", action = "collapse_all" },
	{ key = "C", action = "cd" },
	{ key = "U", action = "dir_up" },
	{ key = "/", action = "search_files", action_cb = nvim_tree_search_files },
	-- opening files
	{ key = { "<CR>", "o", "O" }, action = "edit" },
	{ key = "<C-p>", action = "preview" },
	{ key = "<C-t>", action = "tabnew" },
	{ key = "<C-v>", action = "vsplit" },
	{ key = "<C-s>", action = "split" },
	{ key = "<C-o>", action = "system_open" },
	-- handling files
	{ key = ".", action = "run_file_command" },
	{ key = "y", action = "copy_absolute_path" },
	{ key = "i", action = "toggle_file_info" },
	{ key = "x", action = "cut" },
	{ key = "c", action = "copy" },
	{ key = "p", action = "paste" },
	{ key = "a", action = "create" },
	{ key = "r", action = "full_rename" },
	{ key = "d", action = "trash" },
}
nvim_tree.setup({
	disable_netrw = true,
	view = {
		mappings = {
			list = nvim_tree_key_mappings,
		},
	},
})
vim.g.nvim_tree_icons = {
	git = { unstaged = "", staged = "", unmerged = "", renamed = "", untracked = "", deleted = "" },
}
nnoremap("<C-n>n", ":NvimTreeToggle<CR>")
nnoremap("<C-n>f", ":NvimTreeFindFileToggle<CR>")
nnoremap("<C-n>r", ":NvimTreeRefresh<CR>")
nnoremap("<C-n>c", ":NvimTreeCollapse<CR>")

-- ============================================================================
--                              LUALINE
-- ============================================================================
local lualine = require("lualine")
lualine.setup({
	options = {
		theme = "gruvbox",
		disabled_filetypes = { "packer", "NvimTree" },
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "filename" },
		lualine_c = { "filetype" },
		lualine_x = { "aerial" },
		lualine_y = { { "diagnostics", sections = { "error", "warn" } }, "diff", "branch" },
		lualine_z = { "" },
	},
	extensions = { "quickfix" },
})

-- ============================================================================
--                              TREE-SITTER
-- ============================================================================
local nvim_treesitter_configs = require("nvim-treesitter.configs")
nvim_treesitter_configs.setup({
	ensure_installed = "all",
	sync_install = false,
	-- highlight = { enable = true, disable = { "proto" } },
	-- use external plugin for indentation until fixed
	-- yati = { enable = true },
	indent = { enable = true },
})
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.o.foldenable = true

-- ============================================================================
--                              AERIAL
-- ============================================================================
local aerial_keymaps =  {
    -- ["<CR>"]= "<cmd>lua require'aerial'.select({jump=false})<CR>", -- "Jump to the symbol under the cursor keep focus in aerial window",
    ["<CR>"] = "actions.jump", -- "Jump to the symbol under the cursor keep focus in aerial window",
	["<c-]>"] = "actions.jump", -- Jump to the symbol under the cursor
	["<C-v>"] = "actions.jump_vsplit", -- Jump to the symbol in a vertical split
	["<C-s>"] = "actions.jump_split", -- Jump to the symbol in a horizontal split
    ["{"] = "actions.prev", -- Jump to the previous symbol
	["}"]  = "actions.next", -- Jump to the next symbol
    ["[["] = "actions.prev_up", -- Jump up the tree, moving backwards
    ["]]"] = "actions.next_up", -- Jump up the tree, moving forwards
    ["q"] = "actions.close", -- Close the aerial window
    ["za"] = "actions.tree_toggle", -- Toggle the symbol under the cursor open/closed
    ["zA"] = "actions.tree_toggle_recursive", -- Recursive toggle the symbol under the cursor open/closed
    ["zo"] = "actions.tree_open", -- Expand the symbol under the cursor
    ["zO"] = "actions.tree_open_recursive", -- Recursive expand the symbol under the cursor
    ["zc"] = "actions.tree_close", -- Collapse the symbol under the cursor
    ["zC"] = "actions.tree_close_recursive", -- Recursive collapse the symbol under the cursor
    ["zR"] = "actions.tree_open_all", -- Expand all nodes in the tree
    ["zM"] = "actions.tree_close_all", -- Collapse all nodes in the tree
    ["r" ] = "actions.tree_sync_folds", -- Sync code folding to the tree (useful if they get out of sync)
}

require("aerial").setup({
	highlight_on_hover = true,
	manage_folds = true,
	link_tree_to_folds = true,
	show_guides = true,
    keymaps = aerial_keymaps,
	on_attach = function(bufnr) -- bufnr arg
		nnoremap("<Leader>t", "<cmd>AerialToggle<cr>")
	end,
})

-- ============================================================================
--                              AUTO-COMPLETION
-- ============================================================================
local cmp = require("cmp")
local luasnip = require("luasnip")

vim.opt.completeopt = { "menu", "menuone", "noselect" }

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
	}),
})

-- use buffer source for `/`
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- use cmdline & path source for ':'
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

-- set up LSP stuff
require("my_modules.lsp_config").setup()

-- ============================================================================
--                              TELESCOPE
-- ============================================================================
local telescope = require("telescope")
local telescope_mappings = {
	["<C-s>"] = require("telescope.actions").select_horizontal, -- set to <C-s> to be consistent with nvim-tree
	["<C-e>"] = require("telescope.actions").preview_scrolling_up,
	["<C-y>"] = require("telescope.actions").preview_scrolling_down,
	["<C-x>"] = false, -- disable default horizontal split
	["<C-u>"] = false, -- disable default preview scroll up
	["<C-d>"] = false, -- disable default preview scroll down
}
telescope.setup({
	defaults = {
		layout_config = {
			vertical = { width = 0.5 },
		},
		scroll_strategy = "limit",
		mappings = {
			i = telescope_mappings,
			n = telescope_mappings,
		},
	},
})
nnoremap("<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>")
nnoremap("<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
nnoremap("<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>")
nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")
nnoremap("<leader>fm", "<cmd>lua require('telescope.builtin').marks()<cr>")
nnoremap("<leader>fr", "<cmd>lua require('telescope.builtin').registers()<cr>")
nnoremap("<leader>fl", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>")
nnoremap("<leader>fd", "<cmd>lua require('telescope.builtin').diagnostics()<cr>")
nnoremap("<leader>fg", "<cmd>lua require('telescope.builtin').git_status()<cr>")

-- ============================================================================
--                              DIAGNOSTICS
-- ============================================================================
vim.o.signcolumn = "yes:1"
Toggle_diagnostics = (function()
	local diagnostics_on = true
	return function()
		if diagnostics_on then
			vim.diagnostic.disable(0)
			vim.o.signcolumn = "no"
		else
			vim.diagnostic.enable(0)
			vim.o.signcolumn = "yes:1"
		end
		diagnostics_on = not diagnostics_on
	end
end)()

local severity = { min = vim.diagnostic.severity["WARN"] }
vim.diagnostic.config({
	severity_sort = true,
	underline = { severity = severity },
	virtual_text = false,
	-- virtual_text = { severity = severity },
	signs = { severity = severity },
})

local function set_min_severity_level(opts)
	local new_severity = { min = vim.diagnostic.severity[opts.args] }
	local config = vim.diagnostic.config() -- get curr config
	for _, v in ipairs({ "signs", "underline", "virtual_text" }) do
		config[v].severity = new_severity
	end
	vim.diagnostic.config(config)
	severity = new_severity
	-- update LSP handler for publishing diagnostics
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
		vim.lsp.diagnostic.on_publish_diagnostics,
		config
	)
end

local set_min_severity_level_opts = {
	nargs = 1,
	complete = function(ArgLeader)
		local hints = {}
		local levels = { "ERROR", "WARN", "INFO", "HINT" }
		for _, level in ipairs(levels) do
			if ArgLeader and string.find(level, "^" .. string.upper(ArgLeader)) ~= nil then
				hints[#hints + 1] = level
			end
		end
		return hints
	end,
}
function Goto_diagnostics(direction)
	local opts = {
		severity = severity,
		wrap = false,
	}
	if direction == "next" then
		vim.diagnostic.goto_next(opts)
	elseif direction == "prev" then
		vim.diagnostic.goto_prev(opts)
	else
		error("Invalid direction: " .. tostring(direction))
	end
end

function Toggle_diagnostics_curr_line()
	local cursor_position = vim.api.nvim_win_get_cursor(0)
	local diagnostics = vim.diagnostic.get(0, {
		lnum = cursor_position[1] - 1,
	})
	for index, diagnostic in ipairs(diagnostics) do
		local message = diagnostic["message"]
		local ok, extensive_message = pcall(function()
			return diagnostic["user_data"]["lsp"]["data"]["rendered"]
		end)
		if ok then
			print(extensive_message)
		else
			print(message)
		end
	end
end

require("trouble").setup({
	mode = "document_diagnostics",
	group = true,
	padding = false,
	action_keys = {
		open_split = { "<C-s>" },
		hover = { "h", "l" },
	},
})

nnoremap("<Leader>dt", "<cmd>TroubleToggle<cr>")
nnoremap("<Leader>dq", "<cmd>Trouble quickfix<cr>")
nnoremap("<Leader>dg", "<cmd>Trouble document_diagnostics<cr>")
nnoremap("<Leader>dw", "<cmd>Trouble workspace_diagnostics<cr>")
nnoremap("]d", "zz<cmd>lua Goto_diagnostics('next')<cr>")
nnoremap("[d", "zz<cmd>lua Goto_diagnostics('prev')<cr>")
nnoremap("<Leader>ds", "<cmd>lua Toggle_diagnostics()<cr>")
nnoremap("<Leader>dd", "<cmd>lua Toggle_diagnostics_curr_line()<cr>")
vim.api.nvim_create_user_command("ToggleDiagnostics", Toggle_diagnostics, { nargs = 0 })
vim.api.nvim_create_user_command("SetLevel", set_min_severity_level, set_min_severity_level_opts)

-- ============================================================================
--                              AERIAL
-- ============================================================================
require("aerial.bindings").keys = {
	{
		"<CR>",
		"<cmd>lua require'aerial'.select({jump=false})<CR>",
		"Jump to the symbol under the cursor keep focus in aerial window",
	},
	{ "<c-]>", "<cmd>lua require'aerial'.select()<CR>", "Jump to the symbol under the cursor" },
	{ "<C-v>", "<cmd>lua require'aerial'.select({split='v'})<CR>", "Jump to the symbol in a vertical split" },
	{ "<C-s>", "<cmd>lua require'aerial'.select({split='h'})<CR>", "Jump to the symbol in a horizontal split" },
	{ "{", "<cmd>AerialPrev<CR>", "Jump to the previous symbol" },
	{ "}", "<cmd>AerialNext<CR>", "Jump to the next symbol" },
	{ "[[", "<cmd>AerialPrevUp<CR>", "Jump up the tree, moving backwards" },
	{ "]]", "<cmd>AerialNextUp<CR>", "Jump up the tree, moving forwards" },
	{ "q", "<cmd>AerialClose<CR>", "Close the aerial window" },
	{ "za", "<cmd>AerialTreeToggle<CR>", "Toggle the symbol under the cursor open/closed" },
	{ "zA", "<cmd>AerialTreeToggle!<CR>", "Recursive toggle the symbol under the cursor open/closed" },
	{ "zo", "<cmd>AerialTreeOpen<CR>", "Expand the symbol under the cursor" },
	{ "zO", "<cmd>AerialTreeOpen!<CR>", "Recursive expand the symbol under the cursor" },
	{ "zc", "<cmd>AerialTreeClose<CR>", "Collapse the symbol under the cursor" },
	{ "zC", "<cmd>AerialTreeClose!<CR>", "Recursive collapse the symbol under the cursor" },
	{ "zR", "<cmd>AerialTreeOpenAll<CR>", "Expand all nodes in the tree" },
	{ "zM", "<cmd>AerialTreeCloseAll<CR>", "Collapse all nodes in the tree" },
	{ "r", "<cmd>AerialTreeSyncFolds<CR>", "Sync code folding to the tree (useful if they get out of sync)" },
}

require("aerial").setup({
	highlight_on_hover = true,
	link_tree_to_folds = true,
	manage_folds = true,
	show_guides = true,
	default_bindings = true,
	on_attach = function(_) -- bufnr arg
		nnoremap("<Leader>t", "<cmd>AerialToggle<cr>")
	end,
})

-- ============================================================================
--                              AUTO-COMPLETION
-- ============================================================================
local cmp = require("cmp")
local luasnip = require("luasnip")

vim.opt.completeopt = { "menu", "menuone", "noselect" }

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
	}),
})

-- use buffer source for `/`
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- use cmdline & path source for ':'
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

-- set up LSP stuff
require("my_modules.lsp_config").setup()
