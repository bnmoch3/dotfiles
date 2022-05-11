-- MY INIT.LUA

-- ============================================================================
--                              HELPERS
-- ============================================================================
-- {{
local inspect = require("inspect")
function pp(obj)
	print(inspect(obj))
end

local function nnoremap(shortcut, command)
	vim.api.nvim_set_keymap("n", shortcut, command, { noremap = true, silent = true })
end

local function inoremap(shortcut, command)
	vim.api.nvim_set_keymap("i", shortcut, command, { noremap = true, silent = true })
end

local function vnoremap(shortcut, command)
	vim.api.nvim_set_keymap("v", shortcut, command, { noremap = true, silent = true })
end

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
local my_augroup_id = vim.api.nvim_create_augroup("my_augroup", { clear = true })
require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	use("tpope/vim-commentary") -- for commenting out lines
	use("tpope/vim-surround") -- for surround selected text with given char
	use("jiangmiao/auto-pairs") -- for autoclosing {},(), [], "", '', ``

	-- themes
	use("joshdick/onedark.vim")
	use("fxn/vim-monochrome")
	use("altercation/vim-colors-solarized")
	vim.g.solarized_termcolors = 256

	use("preservim/tagbar")
	use("christoomey/vim-tmux-navigator") -- add tmux navigation compatibility
	vim.api.tmux_navigator_save_on_switch = true
	vim.api.tmux_navigator_disable_when_zoomed = true
	use("kshenoy/vim-signature") -- for toggling, displaying and navigating marks
	use("tpope/vim-unimpaired") -- tim-pope's, for quick navigation of lists
	use("ap/vim-buftabline") -- display buffer list on tabline
	use("kyazdani42/nvim-web-devicons")
	use({ "kyazdani42/nvim-tree.lua", requires = { "kyazdani42/nvim-web-devicons" } })
	use({ "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons" } })

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

vim.o.swapfile = false -- no swapfile, no backups
vim.o.backup = false
vim.o.writebackup = false
vim.o.undofile = true
vim.o.shortmess = vim.o.shortmess .. "I" -- disable the default Vim startup message.
vim.o.shortmess = vim.o.shortmess .. "c" -- dont pass messages to |ins-completion-menu|

vim.o.grepprg = "rg --vimgrep --smart-case --follow"
vim.o.hlsearch = true
vim.o.incsearch = true

vim.o.foldmethod = "indent"
vim.o.foldlevel = 99

-- indenting
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true

-- ignorecase makes all searches case-insensitive
-- smartcase overrides the ignorecase option if the search pattern contains
-- at least one uppercase character. That is, if there's an uppercase
-- character, the search becomes case-sensistive
-- For situations where you want to override ignorecase for an all-lowercase
-- search patter, append \C to the pattern, for example /foo\C will not match
-- Foo and FOO
vim.o.ignorecase = true
vim.o.smartcase = true

-- disable LSP features in ALE before plugins are loaded
-- vim.g.ale_disable_lsp = 1

-- TODO install filetype
-- vim.g.did_load_filetypes = 1

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
	open_on_setup = true,
	view = {
		mappings = {
			list = nvim_tree_key_mappings,
		},
	},
})
nnoremap("<C-n>n", ":NvimTreeToggle<CR>")
nnoremap("<C-n>f", ":NvimTreeFindFileToggle<CR>")
nnoremap("<C-n>r", ":NvimTreeRefresh<CR>")
nnoremap("<C-n>c", ":NvimTreeCollapse<CR>")
--close tab/vim if no other window open and only nvim-tree is left
vim.cmd([[autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif ]])

-- ============================================================================
--                              LUALINE
-- ============================================================================
local lualine = require("lualine")
lualine.setup({
	options = {
		theme = "auto",
		disabled_filetypes = { "packer", "NvimTree" },
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "filename" },
		lualine_c = { "filetype" },
		lualine_x = { "" },
		lualine_y = { "diagnostics", "diff", "branch" },
		lualine_z = { "" },
	},
	extensions = { "quickfix" },
})
