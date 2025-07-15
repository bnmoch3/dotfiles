local M = {}

-- ============================================================================
--                              LSP
-- ============================================================================

local nnoremap = require("my_modules.helpers").nnoremap

local function extend_obj(o, with_obj)
	if with_obj == nil then
		return o
	end
	for k, v in pairs(with_obj) do
		o[k] = v
	end
	return o
end

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
	-- TODO: show signature hint in statusline
	require("lsp_signature").on_attach({
		floating_window = false,
		hint_prefix = "💡 ",
		toggle_key = "<C-h>",
	}, bufnr)
end

local lspconfig = require("lspconfig")
local util = require("lspconfig.util")
local lang_servers = {
	pyright = {},
	gopls = {},
	clangd = {
		capabilities = {
			offsetEncoding = "utf-8",
		},
	},
	dockerls = {},
	ts_ls = {},
	lua_ls = {
		root_dir = util.root_pattern(".git", ".luarc.json", "init.lua"), -- <-- Add this
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				disable = { "lowercase-global" },
				workspace = {
					checkThirdParty = false, -- Add this to suppress other warnings
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
					},
				},
			},
		},
	},
	vimls = {},
	taplo = {
		capabilities = {
			offsetEncoding = { "utf-8" },
		},
	},
	yamlls = {},
	julials = {},
	elixirls = {
		cmd = { vim.fn.stdpath("data") .. "/mason/packages/elixir-ls/language_server.sh" },
	},
	zls = {
		cmd = { vim.fn.expand("~") .. "/LOCAL/pkg/zls/zig-out/bin/zls" },
	},
}

-- ============================================================================
--                              FORMATTING, LINTING
-- ============================================================================

function M.setup()
	require("mason").setup({})
	-- for autocompletion
	local capabilties = require("cmp_nvim_lsp").default_capabilities()
	for lang_server, config in pairs(lang_servers) do
		config.on_attach = custom_lsp_attach
		config.capabilities = extend_obj(capabilties, config.capabilities)
		lspconfig[lang_server].setup(config)
	end

	-- TODO use common lsp setup
	local rt = require("rust-tools")
	rt.setup({
		server = {
			on_attach = custom_lsp_attach,
		},
	})

	require("goto-preview").setup({
		default = false,
	})
	nnoremap("\\p", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>")
	nnoremap("\\i", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>")
	nnoremap("\\q", "<cmd>lua require('goto-preview').close_all_win()<CR>")
	nnoremap("\\r", "<cmd>lua require('goto-preview').goto_preview_references()<CR>")
	nnoremap("\\d", "<cmd>lua require('goto-preview').goto_preview_hover()<CR>")
end

return M
