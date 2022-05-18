-- MY INIT.LUA

-- ============================================================================
--                              HELPERS
-- ============================================================================
-- {{
local inspect = require("inspect")
function pp(obj)
	print(inspect(obj))
end

local function nnoremap(shortcut, command, bufnr)
	if bufnr == nil then
		vim.api.nvim_set_keymap("n", shortcut, command, { noremap = true, silent = true })
	else
		vim.api.nvim_buf_set_keymap(bufnr, "n", shortcut, command, { noremap = true, silent = true })
	end
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
	use("milkypostman/vim-togglelist")
	use("nvim-lua/plenary.nvim")
	use("nvim-treesitter/nvim-treesitter")
	use("williamboman/nvim-lsp-installer")
	use("jose-elias-alvarez/null-ls.nvim")
	use("neovim/nvim-lspconfig")
	use({ "folke/trouble.nvim", requires = { "folke/lsp-colors.nvim" } })
	use("stevearc/aerial.nvim")
	use("rmagatti/goto-preview")
	use("ray-x/lsp_signature.nvim")

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
	use("ellisonleao/gruvbox.nvim")
	use("chriskempson/base16-vim")
	use("DanilaMihailov/beacon.nvim") -- temporarily highlight cursor's curr line
	use("lukas-reineke/indent-blankline.nvim") -- indentation guides

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
	use({ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } })

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

-- quickfix
vim.g.toggle_list_no_mappings = true
nnoremap("<localleader>q", "<cmd>call ToggleQuickfixList()<cr>")
nnoremap("<localleader>l", "<cmd>call ToggleLocationList()<cr>")

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

-- TODO install filetype
-- vim.g.did_load_filetypes = 1

vim.cmd([[colorscheme base16-gruvbox-dark-pale]])
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
	open_on_setup = true,
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
	highlight = { enable = true },
	indent = { enable = true },
})
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false
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
nnoremap("<leader>fd", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>")

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
	virtual_text = { severity = severity },
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
	local opts = { severity = severity }
	if direction == "next" then
		vim.diagnostic.goto_next(opts)
	elseif direction == "prev" then
		vim.diagnostic.goto_prev(opts)
	else
		error("Invalid direction: " .. tostring(direction))
	end
end

require("trouble").setup({
	mode = "document_diagnostics",
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
nnoremap("<Leader>dd", "<cmd>lua Toggle_diagnostics()<cr>")
vim.api.nvim_create_user_command("ToggleDiagnostics", Toggle_diagnostics, { nargs = 0 })
vim.api.nvim_create_user_command("SetMinLevel", set_min_severity_level, set_min_severity_level_opts)

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
	on_attach = function(bufnr)
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

-- ============================================================================
--                              LSP
-- ============================================================================
--[[
- stop all clients, then reload the buffer
    :lua vim.lsp.stop_client(vim.lsp.get_active_clients())

- default handlers used when creating a new client:
    :lua print(vim.inspect(vim.tbl_keys(vim.lsp.handlers)))
--]]
local lsp_actions = {
	{ -- resolve document highlights for current text document pos.
		cmd = "document_highlight",
		keybinding = nil,
		action = vim.lsp.buf.document_highlight,
	},
	{ -- lists all symbols in the current buffer
		cmd = "document_symbol",
		keybinding = nil,
		action = vim.lsp.buf.document_symbol,
	},
	{ -- retrieves completion items at curr cursor pos, can only be used in insert mode
		cmd = "complete",
		keybinding = nil,
		action = vim.lsp.buf.completion,
	},
	{ -- jumps to the def of symbols under the cursor
		cmd = "definition",
		keybinding = { "<Leader>gd", "<C-]>" },
		action = vim.lsp.buf.definition,
	},
	{ -- displays information about the symbol under the cursor
		cmd = { "hover", "doc" },
		keybinding = "<Leader>gh",
		action = vim.lsp.buf.hover,
	},
	{ -- lists all the implementations for the symbol under the cursor
		cmd = "implementation",
		keybinding = nil,
		action = vim.lsp.buf.implementation,
	},
	{ -- lists all the call sites of the sym under the cursor
		cmd = { "called_by", "incoming" },
		keybinding = nil,
		action = vim.lsp.buf.incoming_calls,
	},
	{ -- list all items that are called by the symbol under the cursor
		cmd = { "calls", "outgoing" },
		keybinding = nil,
		action = vim.lsp.buf.outgoing_calls,
	},
	{ -- lists all the references to the symbol under the cursor in the quickfix window
		cmd = "references",
		keybinding = nil,
		action = vim.lsp.buf.references,
	},
	{ -- renames all the references to the symbol under the cursor
		cmd = "rename",
		keybinding = nil,
		action = vim.lsp.buf.rename,
	},
	{ -- displays signature information for sym under the cursor
		cmd = "signature_help",
		keybinding = nil,
		action = vim.lsp.buf.signature_help,
	},
	{ -- jumps to the definition of the type of sym under the cursor
		cmd = "type_definition",
		keybinding = "<Leader>gt",
		action = vim.lsp.buf.type_definition,
	},
	{ -- removes document highlights from current buffer
		cmd = "clear_references",
		keybinding = nil,
		action = vim.lsp.buf.clear_references,
	},
}

local function listify(val)
	if type(val) ~= "table" then
		return { val }
	else
		return val
	end
end

local function flatten_apply(val, fn)
	if val == nil then
		return
	end
	if type(val) == "table" then
		for _, v in ipairs(val) do
			fn(v)
		end
		return
	end
	fn(val)
end

local custom_lsp_attach = function(client, bufnr)
	-- set up keyboard shortcuts
	for _, v in ipairs(lsp_actions) do
		flatten_apply(v.keybinding, function(keybinding)
			if keybinding ~= nil and keybinding ~= "" then
				local cmd = listify(v.cmd)[1]
				nnoremap(keybinding, "<cmd>Lsp " .. cmd .. "<cr>")
			end
		end)
	end

	-- tab complete for Lsp command
	function complete_lsp_command(ArgLeader)
		local cmds = {}
		for _, v in ipairs(lsp_actions) do
			flatten_apply(v.cmd, function(cmd)
				if string.find(cmd, "^" .. ArgLeader) ~= nil then
					cmds[#cmds + 1] = cmd
				end
			end)
		end
		pp(cmds)
		return cmds
	end

	-- set up Lsp command
	vim.api.nvim_create_user_command(
		"Lsp",
		(function()
			-- build reverse map from cmd to actions
			local cmds_to_actions = {}
			for _, v in ipairs(lsp_actions) do
				flatten_apply(v.cmd, function(cmd)
					cmds_to_actions[cmd] = v.action
				end)
			end
			-- return closure to access reverse map
			return function(opts)
				local sub_cmd = opts.args
				local action_fn = cmds_to_actions[sub_cmd]
				if action_fn == nil then
					error("Invalid cmd: " .. sub_cmd)
					return
				end
				action_fn()
			end
		end)(),
		{
			nargs = 1,
			complete = complete_lsp_command,
		}
	)

	-- set up aerial for a code outline window
	require("aerial").on_attach(client, bufnr)
end

require("nvim-lsp-installer").setup({})
local lspconfig = require("lspconfig")
local lang_servers = {
	pyright = {},
	gopls = {},
	clangd = {},
	dockerls = {},
	tsserver = {},
	sumneko_lua = {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
				disable = { "lowercase-global" },
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
					},
				},
			},
		},
	},
	vimls = {},
	taplo = {},
	yamlls = {},
}

-- for autocompletion
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

for lang_server, config in pairs(lang_servers) do
	config.on_attach = custom_lsp_attach
	config.capabilities = capabilities
	lspconfig[lang_server].setup(config)
end

require("goto-preview").setup({})
nnoremap("\\d", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>")
nnoremap("\\i", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>")
nnoremap("\\q", "<cmd>lua require('goto-preview').close_all_win()<CR>")
nnoremap("\\p", "<cmd>lua require('goto-preview').goto_preview_references()<CR>")
nnoremap("\\d", "<cmd>lua vim.lsp.buf.hover()<CR>") -- for docs

-- for showing signature as virtual text
require("lsp_signature").setup({})

-- ============================================================================
--                              FORMATTING, LINTING
-- ============================================================================
local null_ls = require("null-ls")
-- add trimwhitespace for python, lua
-- add isort for python
-- make sure prettier doesn't format yaml
null_ls.setup({
	sources = {
		-- general
		null_ls.builtins.formatting.trim_whitespace,
		null_ls.builtins.formatting.trim_newlines,
		-- lua
		null_ls.builtins.formatting.stylua,
		-- bash
		null_ls.builtins.diagnostics.shellcheck,
		null_ls.builtins.formatting.shfmt,
		-- js, html, css
		null_ls.builtins.diagnostics.eslint,
		null_ls.builtins.formatting.prettier.with({
			filetypes = { "html", "javascript", "json", "javascriptreact", "typescript", "typescriptreact", "yaml" },
		}),
		-- docker
		null_ls.builtins.diagnostics.hadolint,
		-- go
		null_ls.builtins.formatting.gofmt,
		null_ls.builtins.formatting.goimports,
		-- toml
		null_ls.builtins.formatting.taplo,
		-- python
		null_ls.builtins.formatting.black.with({
			prefer_local = ".venv/bin",
		}),
	},
	-- format on write
	on_attach = (function()
		-- only use null-ls for formatting
		local lsp_formatting = function(bufnr)
			vim.lsp.buf.format({
				filter = function(clients)
					return vim.tbl_filter(function(client)
						return client.name == "null-ls"
					end, clients)
				end,
				bufnr = bufnr,
			})
		end

		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		return function(client, bufnr)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = augroup,
					buffer = bufnr,
					callback = function()
						lsp_formatting(bufnr)
					end,
				})
			end
		end
	end)(),
})
