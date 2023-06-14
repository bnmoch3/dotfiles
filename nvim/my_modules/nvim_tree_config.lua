-- Please see https://github.com/nvim-tree/nvim-tree.lua/wiki/Migrating-To-on_attach
-- for assistance in migrating.
local M = {}

local function nvim_tree_search_files(node)
	local dir = vim.fn.getcwd()
	if node.parent ~= nil then
		dir = node.parent.cwd or node.parent.absolute_path
	end
	require("telescope.builtin").find_files({ cwd = dir })
end

function M.on_attach(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- nvim    tree
    vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
    vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
    vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
    vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
    vim.keymap.set('n', 'Q', api.tree.close, opts('Close'))
    vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
    vim.keymap.set('n', 'D', api.node.navigate.parent_close, opts('Close Directory'))
    vim.keymap.set('n', 'W', api.tree.collapse_all, opts('Collapse'))
    vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD'))
    vim.keymap.set('n', 'U', api.tree.change_root_to_parent, opts('Up'))
    vim.keymap.set('n', '/', function()
        local node = api.tree.get_node_under_cursor()
        nvim_tree_search_files(node)
    end, opts('search_files'))

    -- open files
    vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'O', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', '<C-p>', api.node.open.preview, opts('Open Preview'))
    vim.keymap.set('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
    vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
    vim.keymap.set('n', '<C-s>', api.node.open.horizontal, opts('Open: Horizontal Split'))
    vim.keymap.set('n', '<C-o>', api.node.run.system, opts('Run System')) -- system open

    -- handling files
    vim.keymap.set('n', '.', api.node.run.cmd, opts('Run Command')) -- run file command
    vim.keymap.set('n', 'y', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
    vim.keymap.set('n', 'i', api.node.show_info_popup, opts('Info')) -- toggle info
    vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
    vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
    vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
    vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
    vim.keymap.set('n', 'r', api.fs.rename_sub, opts('Rename: Omit Filename')) -- full rename
    vim.keymap.set('n', 'd', api.fs.trash, opts('Trash'))
end

return M
