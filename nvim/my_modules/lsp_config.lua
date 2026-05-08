local M = {}

-- ============================================================================
--                              LSP
-- ============================================================================

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

--[[
- stop all clients, then reload the buffer:
    :lua vim.lsp.stop_client(vim.lsp.get_clients())

- list active clients:
    :lua print(vim.inspect(vim.lsp.get_clients()))
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
	{ -- jumps to the def of symbols under the cursor
		cmd = "definition",
		keybinding = { "<Leader>gs", "<C-]>" },
		action = vim.lsp.buf.definition,
	},
	{ -- displays information about the symbol under the cursor
		cmd = { "hover", "doc" },
		keybinding = "<Leader>gd",
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

local custom_lsp_attach = function(_client, bufnr)
	-- set up keyboard shortcuts
	for _, v in ipairs(lsp_actions) do
		flatten_apply(v.keybinding, function(keybinding)
			if keybinding ~= nil and keybinding ~= "" then
				local cmd = listify(v.cmd)[1]
				vim.keymap.set(
					"n",
					keybinding,
					"<cmd>Lsp " .. cmd .. "<cr>",
					{ noremap = true, silent = true, desc = "LSP: " .. cmd }
				)
			end
		end)
	end

	-- tab complete for Lsp command
	local function complete_lsp_command(ArgLeader)
		local cmds = {}
		for _, v in ipairs(lsp_actions) do
			flatten_apply(v.cmd, function(cmd)
				if string.find(cmd, "^" .. ArgLeader) ~= nil then
					cmds[#cmds + 1] = cmd
				end
			end)
		end
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

	-- for showing signature as virtual text
	require("lsp_signature").on_attach({
		floating_window = false,
		hint_prefix = "💡 ",
		toggle_key = "<C-h>",
	}, bufnr)
end

-- ============================================================================
--                              RUSTACEANVIM
-- ============================================================================
vim.g.rustaceanvim = {
	server = {
		on_attach = custom_lsp_attach,
		capabilities = require("cmp_nvim_lsp").default_capabilities(),
	},
}

-- ============================================================================
--                              SERVER CONFIGS
-- ============================================================================
-- Servers that need non-default configuration.
-- Servers with no extra config don't need an entry here at all; just add them
-- to the enable list in M.setup().
local server_configs = {
	clangd = {
		capabilities = { offsetEncoding = "utf-8" },
	},
	lua_ls = {
		root_markers = { ".git", ".luarc.json", "init.lua" },
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim", "pp" },
					unusedLocalExclude = { "_*" },
					disable = {
						"lowercase-global",
						"unused-local",
						"unused-function",
						"unused-vararg",
					},
				},
				workspace = {
					checkThirdParty = false,
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
					},
				},
			},
		},
	},
	taplo = {
		capabilities = { offsetEncoding = { "utf-8" } },
	},
}

function M.setup()
	require("mason").setup({})

	local capabilities = require("cmp_nvim_lsp").default_capabilities()

	-- Global defaults: on_attach and capabilities for every server.
	-- Individual vim.lsp.config() calls below override/extend these per-server.
	vim.lsp.config("*", {
		on_attach = custom_lsp_attach,
		capabilities = capabilities,
	})

	-- Apply per-server overrides
	for server, config in pairs(server_configs) do
		-- Merge capabilities if the server provides extras (e.g. clangd offsetEncoding)
		if config.capabilities then
			config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities)
		end
		vim.lsp.config(server, config)
	end

	-- Enable servers. rust_analyzer is intentionally absent: rustaceanvim
	-- manages it and will error if you also call vim.lsp.enable for it.
	vim.lsp.enable({
		"pyright",
		"gopls",
		"clangd",
		"ts_ls",
		"buf_ls",
		"lua_ls",
		"vimls",
		"taplo",
		"yamlls",
	})

	-- goto-preview
	require("goto-preview").setup({
		default = false,
	})
	vim.keymap.set(
		"n",
		"\\p",
		require("goto-preview").goto_preview_definition,
		{ noremap = true, silent = true, desc = "Preview definition" }
	)
	vim.keymap.set(
		"n",
		"\\i",
		require("goto-preview").goto_preview_implementation,
		{ noremap = true, silent = true, desc = "Preview implementation" }
	)
	vim.keymap.set(
		"n",
		"\\q",
		require("goto-preview").close_all_win,
		{ noremap = true, silent = true, desc = "Close all preview windows" }
	)
	vim.keymap.set(
		"n",
		"\\r",
		require("goto-preview").goto_preview_references,
		{ noremap = true, silent = true, desc = "Preview references" }
	)
	vim.keymap.set(
		"n",
		"\\d",
		require("goto-preview").goto_preview_hover,
		{ noremap = true, silent = true, desc = "Preview hover" }
	)
end

return M
