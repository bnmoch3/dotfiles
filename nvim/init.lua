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
local tnoremap = require("my_modules.helpers").tnoremap

-- bootstrap packer installation
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap = nil
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	packer_bootstrap = vim.fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

vim.api.nvim_create_user_command("Todo", "e ~/TODO.txt", {})

-- ============================================================================
--                              PLUGINS
-- ============================================================================
require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	use("alvan/vim-closetag")
	use("tpope/vim-commentary") -- for commenting out lines
	use("tpope/vim-surround") -- for surround selected text with given char
	use("milkypostman/vim-togglelist")
	use("nvim-lua/plenary.nvim")
	use("nvim-treesitter/nvim-treesitter")
	use("williamboman/mason.nvim")
	use("neovim/nvim-lspconfig")
	use("simrat39/rust-tools.nvim")
	use("mfussenegger/nvim-jdtls")
	use({ "folke/trouble.nvim", requires = { "folke/lsp-colors.nvim" } })
	use("bnmoch3/nvim-goto-preview")
	use("ray-x/lsp_signature.nvim")
	use("akinsho/toggleterm.nvim")

	-- autocompletion
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")

	-- snippets
	use("L3MON4D3/LuaSnip")
	use("saadparwaiz1/cmp_luasnip")
	-- use("rafamadriz/friendly-snippets")

	-- themes, styling
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
	use("nvim-tree/nvim-web-devicons")
	use("onsails/lspkind.nvim")
	use("nvim-tree/nvim-tree.lua")
	use("nvim-lualine/lualine.nvim")
	use({ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } })
	-- for fuzzy search in telescope
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

	-- langs
	use("ziglang/zig.vim")
	use("dijkstracula/vim-plang")

	use("mfussenegger/nvim-lint")
	use("stevearc/conform.nvim")
	use("j-hui/fidget.nvim")

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
vim.o.clipboard = "unnamedplus"
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

local colorscheme = (function()
	local white = "#f8f8f8" -- alacritty: white
	local black_pale = "#212121" -- alacritty: black
	local black_bright = "#1d1d1d"
	local grey_light = "#c0c0c0"
	local grey_comments = "#666666"
	local grey_highlight = "#333333"
	local grey_dark = "#212121"
	local red_pale = "#d75f5f" --alacritty: red
	local red_bright = "#fa4a43" -- alacritty: ?magenta?
	local green_pale = "#a1b56c" -- alacritty: green
	local green_bright = "#89b482" -- alacritty: ?cyan?: alt "#afaf00"
	local yellow_orange_pale = "#dab997" -- alacritty: yellow
	local yellow_orange_bright = "#e78a4e"
	local blue_pale = "#83adad" -- alacritty: blue
	local blue_bright = "#7cafc2"

	local red = "#ff0000" -- for debugging

	return {
		base00 = black_bright, -- background
		base01 = grey_dark,
		base02 = grey_highlight, -- visual highlight
		base03 = grey_comments, -- comments
		base04 = grey_comments, -- line number
		base05 = grey_light, -- text: remainder: haystack
		base06 = "#ff0000",
		base07 = "#ff0000",
		base08 = grey_light, -- some text: keywords such as local, struct names
		base09 = yellow_orange_pale, -- some text
		base0A = blue_pale, -- some text
		base0B = yellow_orange_pale, -- some text: inside quotes, green
		base0C = yellow_orange_pale,
		base0D = blue_pale, -- some text: method calls
		base0E = yellow_orange_pale, -- some text main
		base0F = grey_light, -- some text: symbols
	}
end)()

require("base16-colorscheme").setup(colorscheme)
vim.o.termguicolors = true

vim.g.beacon_size = 60
vim.g.beacon_timeout = 2000
vim.cmd([[highlight Beacon guibg=LightGray ctermbg=8]])
vim.g.beacon_ignore_filetypes = { "qf", "NvimTree" }

vim.g.indentLine_char = "|"
vim.g.indent_blankline_user_treesitter = true
vim.g.indent_blankline_show_first_indent_level = false

-- Disable concealment and ensure all folds are open when editing:
-- JSON, JSONC,Markdown files.
-- This helps to always see raw syntax (e.g. backticks, quotes, Unicode
-- escapes) and avoids starting with folded sections.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "jsonc", "markdown" },
	callback = function()
		vim.wo.conceallevel = 0
		vim.wo.foldlevel = 99
	end,
})

-- ============================================================================
--                              KEYMAPS
-- ============================================================================
-- for toggling visual selection
nnoremap("<localleader>v", "viw")
vnoremap("<localleader>v", "b")

-- for toggling tagbar
nnoremap("<localleader>t", ":TagbarToggle<CR>")

-- add key combos for navigating between split windows
nnoremap("<c-h>", "<cmd>TmuxNavigateLeft<CR>")
nnoremap("<c-j>", "<cmd>TmuxNavigateDown<CR>")
nnoremap("<c-k>", "<cmd>TmuxNavigateUp<CR>")
nnoremap("<c-l>", "<cmd>TmuxNavigateRight<CR>")

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

local function nvim_tree_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- general
	vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
	vim.keymap.set("n", "q", api.tree.close, opts("Close"))

	-- view
	vim.keymap.set("n", "i", api.tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
	vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
	vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
	vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
	vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
	vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))

	-- file manipulation
	vim.keymap.set("n", "fx", api.fs.cut, opts("Cut File"))
	vim.keymap.set("n", "fc", api.fs.copy.node, opts("Copy File"))
	vim.keymap.set("n", "fp", api.fs.paste, opts("Paste File"))
	vim.keymap.set("n", "fy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
	vim.keymap.set("n", "fY", api.fs.copy.relative_path, opts("Copy Absolute Path"))
	vim.keymap.set("n", "fa", api.fs.create, opts("Create File Or Directory"))
	vim.keymap.set("n", "fr", api.fs.rename_sub, opts("Rename: Omit Filename"))
	vim.keymap.set("n", "fR", api.fs.rename, opts("Rename"))
	vim.keymap.set("n", "fd", api.fs.trash, opts("Trash"))
	vim.keymap.set("n", "fD", api.fs.remove, opts("Delete"))

	-- open
	vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))
	vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "<C-p>", api.node.open.preview, opts("Open Preview"))
	vim.keymap.set("n", "<C-i>", api.node.show_info_popup, opts("Info"))
	vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
	vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
	vim.keymap.set("n", "<C-s>", api.node.open.horizontal, opts("Open: Horizontal Split"))
	vim.keymap.set("n", "<C-o>", api.node.run.system, opts("System open"))
	vim.keymap.set("n", "<C-r>", api.node.run.cmd, opts("Run Command"))

	-- navigation
	vim.keymap.set("n", "K", api.node.navigate.sibling.prev, opts("Go to Previous Sibling"))
	vim.keymap.set("n", "J", api.node.navigate.sibling.next, opts("Go to Next Sibling"))
	vim.keymap.set("n", "H", api.node.navigate.sibling.first, opts("Go to First Sibling"))
	vim.keymap.set("n", "L", api.node.navigate.sibling.last, opts("Go to Last Sibling"))
	vim.keymap.set("n", "P", api.node.navigate.parent, opts("Go to Parent Directory"))
	vim.keymap.set("n", "]d", api.node.navigate.diagnostics.next, opts("Go to Next Diagnostic"))
	vim.keymap.set("n", "[d", api.node.navigate.diagnostics.prev, opts("Go to Prev Diagnostic"))
	vim.keymap.set("n", "[g", api.node.navigate.git.prev, opts("Go to Prev Git"))
	vim.keymap.set("n", "]g", api.node.navigate.git.next, opts("Go to Next Git"))
	vim.keymap.set("n", "cd", api.tree.change_root_to_node, opts("Change dir to curr"))
	vim.keymap.set("n", "..", api.tree.change_root_to_parent, opts("Change dir to up"))

	vim.keymap.set("n", "/", api.tree.search_node, opts("Search"))
end

nvim_tree.setup({
	disable_netrw = true,
	on_attach = nvim_tree_on_attach,
})
nnoremap("<C-n>n", ":NvimTreeToggle<CR>")

-- ============================================================================
--                              TREE-SITTER
-- ============================================================================
local nvim_treesitter_configs = require("nvim-treesitter.configs")
require("nvim-treesitter.install").prefer_git = true
--
nvim_treesitter_configs.setup({
	ensure_installed = "all",
	ignore_install = { "ipkg" }, -- repository deleted: https://github.com/srghma/tree-sitter-ipkg
	auto_install = false,
	sync_install = false,
	highlight = { enable = true, disable = { "proto" } },
	-- use external plugin for indentation until fixed
	yati = { enable = true },
	indent = { enable = true },
})
vim.o.foldmethod = "indent"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = true

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
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
	},
})
telescope.load_extension("fzf")
nnoremap("<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>")
nnoremap("<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
nnoremap("<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>")
nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")
nnoremap("<leader>fm", "<cmd>lua require('telescope.builtin').marks()<cr>")
nnoremap("<leader>fr", "<cmd>lua require('telescope.builtin').registers()<cr>")
nnoremap("<leader>fl", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find({})<cr>")
nnoremap("<leader>fd", "<cmd>lua require('telescope.builtin').diagnostics()<cr>")
nnoremap("<leader>fs", "<cmd>lua require('telescope.builtin').git_status()<cr>")
-- ============================================================================
--                              FIDGET NOTIFY
-- ============================================================================
require("fidget").setup()
-- ============================================================================
--                              DIAGNOSTICS
-- ============================================================================
vim.o.signcolumn = "yes:1"
local _default_severity = { min = vim.diagnostic.severity.WARN } -- default min severity
vim.g._diagnostic_min_severity = _default_severity

vim.diagnostic.config({
	float = { source = "if_many" },
	severity_sort = true,
	underline = { severity = _default_severity },
	virtual_text = false,
	signs = { severity = _default_severity },
	severity_sort = true,
})

local function toggle_diagnostics()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.diagnostic.is_enabled({ bufnr = bufnr }) then
		vim.diagnostic.enable(false, { bufnr = bufnr })
	else
		vim.diagnostic.enable(true, { bufnr = bufnr })
	end
end

vim.g._diagnostic_virtual_text_enabled = false
local function toggle_virtual_text_diagnostics()
	vim.g._diagnostic_virtual_text_enabled = not vim.g._diagnostic_virtual_text_enabled

	local vt_config = vim.g._diagnostic_virtual_text_enabled and { severity = vim.g._diagnostic_min_severity } or false
	vim.diagnostic.config({ virtual_text = vt_config })
	-- vim.notify("virtual_text " .. (vim.g._diagnostic_virtual_text_enabled and "enabled" or "disabled"))

	local fidget_notify = require("fidget.notification").notify
	fidget_notify(
		"virtual_text diagnostics: " .. (vim.g._diagnostic_virtual_text_enabled and "enabled" or "disabled"),
		vim.log.levels.INFO,
		{ title = "Diagnostics" }
	)
end

local function set_min_severity_level(opts)
	local level_name = string.upper(opts.args)
	local severity_val = vim.diagnostic.severity[level_name]
	if not severity_val then
		error("Invalid severity level: " .. opts.args .. ". Use one of: ERROR, WARN, INFO, HINT")
	end
	local new_severity = { min = severity_val }
	vim.g._diagnostic_min_severity = new_severity

	-- Update existing diagnostic config to respect the new severity
	local curr_config = vim.diagnostic.config()
	for _, field in ipairs({ "signs", "underline", "virtual_text" }) do
		if type(curr_config[field]) == "table" then
			curr_config[field].severity = new_severity
		end
	end
	vim.diagnostic.config(curr_config)
end

-- completion for severity levels when configuring as Command
local opts_set_min_severity_level = {
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

-- jump to next/prev diagnostic matching current min severity
local function goto_diagnostics(direction)
	local count = ({ next = 1, prev = -1 })[direction]
	if not count then
		error("Invalid direction: " .. tostring(direction))
	end

	return function()
		local severity = vim.g._diagnostic_min_severity or _default_severity
		vim.diagnostic.jump({
			count = count,
			float = true,
			wrap = false,
			severity = severity,
		})
	end
end

local function toggle_diagnostics_curr_line()
	if vim.b.diagnostic_float_win and vim.api.nvim_win_is_valid(vim.b.diagnostic_float_win) then
		vim.api.nvim_win_close(vim.b.diagnostic_float_win, true)
		vim.b.diagnostic_float_win = nil
	else
		local opts = { scope = "line", source = true }
		local _, winid = vim.diagnostic.open_float(opts)
		vim.b.diagnostic_float_win = winid
	end
end

vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		if not vim.b.diagnostic_float_win or not vim.api.nvim_win_is_valid(vim.b.diagnostic_float_win) then
			local _, winid = vim.diagnostic.open_float({ scope = "line", source = true })
			vim.b.diagnostic_float_win = winid
		end
	end,
})

local trouble = require("trouble")
trouble.setup({
	keys = {
		["p"] = "toggle_preview", -- 'p' to toggle preview
		["<cr>"] = "jump", -- enter for jumping
	},
	modes = {
		symbols = {
			auto_preview = false, -- disable auto to make toggle meaningful
		},
	},
	mode = "document_diagnostics",
	group = true,
	padding = false,
	action_keys = {
		open_split = { "<C-s>" },
		hover = { "h", "l" },
	},
	multiline = true,
})

vim.keymap.set("n", "<Leader>dt", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set("n", "<Leader>dq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
vim.keymap.set(
	"n",
	"<Leader>dd",
	"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	{ desc = "Document Diagnostics (Trouble)" }
)
vim.keymap.set("n", "<Leader>dw", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Workspace Diagnostics (Trouble)" })

vim.keymap.set("n", "]d", goto_diagnostics("next"), { silent = true, desc = "Next diagnostic" })

vim.keymap.set("n", "[d", goto_diagnostics("prev"), { silent = true, desc = "Previous diagnostic" })

vim.keymap.set("n", "<Leader>ds", toggle_diagnostics, {
	silent = true,
	desc = "Toggle diagnostics per buffer",
})

vim.keymap.set("n", "<Leader>dl", toggle_diagnostics_curr_line, {
	silent = true,
	desc = "Toggle diagnostics on current line",
})
vim.keymap.set("n", "<Leader>dv", toggle_virtual_text_diagnostics, {
	desc = "Toggle virtual_text diagnostics",
	silent = true,
})
vim.keymap.set("n", "<Leader>da", function()
	trouble.toggle("symbols", {
		pinned = true,
		win = {
			relative = "win",
			position = "right",
		},
	})
end, {
	desc = "Toggle virtual_text diagnostics",
	silent = true,
})

vim.api.nvim_create_user_command("ToggleDiagnostics", toggle_diagnostics, { nargs = 0 })
vim.api.nvim_create_user_command("SetDiagnosticsLevel", set_min_severity_level, opts_set_min_severity_level)

-- ============================================================================
--                              LUALINE
-- ============================================================================
local lualine = require("lualine")

local symbols = trouble.statusline({
	mode = "lsp_document_symbols",
	groups = {},
	title = false,
	filter = { range = true }, -- this makes it update based on cursor position
	format = "{kind_icon}{symbol.name:Normal}", -- change format to reduce verbosity
	hl_group = "lualine_c_normal",
})

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
		lualine_c = { "filetype", { symbols.get, cond = symbols.has } },
		lualine_y = { { "diagnostics", sections = { "error", "warn" } }, "diff", "branch" },
		lualine_z = { "" },
	},
	extensions = { "quickfix", "toggleterm" },
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
cmp.setup.cmdline({ "/", "?" }, {
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
--                              TERMINAL
-- ============================================================================
tnoremap("<C-h>", "<C-\\><C-n><C-w>h")
tnoremap("<C-j>", "<C-\\><C-n><C-w>j")
tnoremap("<C-k>", "<C-\\><C-n><C-w>k")
tnoremap("<C-l>", "<C-\\><C-n><C-w>l")
tnoremap("<C-^>", "<C-\\><C-n><C-^>")
tnoremap("", "<C-\\><C-n>")
require("toggleterm").setup({
	shade_terminals = false,
	start_in_insert = true,
	hide_numbers = true,
	-- direction = "float",
})

nnoremap("<Leader>tt", ":ToggleTerm name=xterminal direction=horizontal<CR>")
nnoremap("<Leader>tf", ":ToggleTerm name=xterminal direction=float<CR>")
vnoremap("r", ":ToggleTermSendVisualLines<CR>")
nnoremap("<Leader>r", ":ToggleTermSendCurrentLine<CR>")

local termGroup = vim.api.nvim_create_augroup("TermGroup", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	callback = function()
		vim.cmd("startinsert")
	end,
	pattern = { "term://*" },
	group = termGroup,
})

local Terminal = require("toggleterm.terminal").Terminal
local function create_zoomed_toggle_term(cmd)
	local did_zoom = false

	local function is_tmux_zoomed()
		local output = vim.fn.system("tmux display-message -p '#{window_zoomed_flag}'")
		return vim.fn.trim(output) == "1"
	end

	return Terminal:new({
		cmd = cmd,
		direction = "float",
		hidden = true,
		start_in_insert = true,
		on_open = function(term)
			if os.getenv("TMUX") then
				if not is_tmux_zoomed() then
					vim.fn.system("tmux resize-pane -Z")
					did_zoom = true
				else
					did_zoom = false
				end
			end
			vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
		end,
		on_close = function()
			if os.getenv("TMUX") and did_zoom then
				vim.fn.system("tmux resize-pane -Z")
			end
		end,
	})
end

local function create_zoomed_toggle_term(cmd)
	local did_zoom = false

	local function is_tmux_zoomed()
		local output = vim.fn.system("tmux display-message -p '#{window_zoomed_flag}'")
		return vim.fn.trim(output) == "1"
	end

	return Terminal:new({
		cmd = cmd,
		direction = "float",
		hidden = true,
		start_in_insert = true,
		on_open = function(term)
			if os.getenv("TMUX") then
				if not is_tmux_zoomed() then
					vim.fn.system("tmux resize-pane -Z")
					did_zoom = true
				else
					did_zoom = false
				end
			end
			vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
		end,
		on_close = function()
			if os.getenv("TMUX") and did_zoom then
				vim.fn.system("tmux resize-pane -Z")
			end
		end,
	})
end

local lazygit = create_zoomed_toggle_term("lazygit")
vim.keymap.set("n", "<leader>gg", function()
	lazygit:toggle()
end, { desc = "Lazygit (zoom-safe)" })

-- ============================================================================
--                              FORMATTING
-- ============================================================================
vim.keymap.set({ "n", "v" }, "<leader>c", function()
	require("conform").format({
		lsp_format = "fallback",
		async = false,
		timeout_ms = 1000,
	})
end, { desc = "Format buffer with Conform" })

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

require("conform").setup({
	lsp_fallback = false,
	formatters_by_ft = {
		lua = { "stylua", lsp_format = "fallback" },
		proto = { "buf" },
		markdown = { "deno_fmt" },
		python = { "ruff_organize_imports", "ruff_fix", "ruff_format" },
		toml = { "taplo" },
		yaml = { "yamlfmt" },
		sql = { "sqlfmt" },
		sh = { "shfmt" },
		javascript = { "biome" },
		go = function(bufnr)
			if require("conform").get_formatter_info("gofumpt", bufnr).available then
				return { "goimports", "gofumpt" }
			else
				return { "goimports" }
			end
		end,
		["*"] = { "trim_whitespace", "trim_newlines" },
	},
})
-- ============================================================================
--                              LINTING
-- ============================================================================
require("lint").linters_by_ft = {
	python = { "ruff" },
	lua = { "luacheck" },
	make = { "checkmake" },
	sh = { "shellchec" },
	dockerfile = { "hadolint" },
	go = { "golangcilint" },
}

vim.api.nvim_create_user_command("Linters", function()
	local lint = require("lint")
	local ft = vim.bo.filetype
	local configured = lint.linters_by_ft[ft]

	if configured == nil or vim.tbl_isempty(configured) then
		print("No linters configured for filetype: " .. ft)
	else
		print("Linters for " .. ft .. ": " .. table.concat(configured, ", "))
	end
end, {})

vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
	callback = function()
		-- try_lint without arguments runs the linters defined in `linters_by_ft`
		-- for the current filetype
		require("lint").try_lint()
	end,
})

-- ============================================================================
-- ============================================================================
--
