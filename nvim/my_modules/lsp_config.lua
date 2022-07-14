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

	-- set up aerial for a code outline window
	require("aerial").on_attach(client, bufnr)
end

local lspconfig = require("lspconfig")
local lang_servers = {
	pyright = {},
	gopls = {},
	clangd = {
		capabilities = {
			offsetEncoding = "utf-8",
		},
	},
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

-- ============================================================================
--                              FORMATTING, LINTING
-- ============================================================================
local function setup_null_ls()
	local null_ls = require("null-ls")
	-- add trimwhitespace for python, lua
	-- add isort for python
	-- make sure prettier doesn't format yaml
	null_ls.setup({
		sources = {
			-- general
			null_ls.builtins.formatting.trim_whitespace.with({
				disabled_filetypes = { "markdown" },
			}),
			null_ls.builtins.formatting.trim_newlines,
			-- lua
			null_ls.builtins.formatting.stylua,
			-- bash
			null_ls.builtins.diagnostics.shellcheck,
			null_ls.builtins.formatting.shfmt,
			-- C, C++
			null_ls.builtins.formatting.clang_format.with({
				filetypes = { "c", "cpp", "cuda" },
				args = { "--style=file" },
				-- args = { '--style="{BasedOnStyle: Mozilla, IndentWidth: 8, Language: Cpp}"' },
				-- args = { "--sort-includes" },
			}),
			null_ls.builtins.formatting.google_java_format.with({
				command = "java",
				extra_args = {
					"-jar",
					vim.fn.expand("~/LOCAL/pkg/java/google-java-format-1.15.0-all-deps.jar"),
					"--aosp",
				},
			}),
			-- js, html, css
			null_ls.builtins.diagnostics.eslint,
			null_ls.builtins.formatting.prettier.with({
				filetypes = {
					"html",
					"javascript",
					"json",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"yaml",
					"css",
				},
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
					filter = function(client)
						return client.name == "null-ls"
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
end

function M.setup()
	require("nvim-lsp-installer").setup({})
	-- for autocompletion
	local capabilties = vim.lsp.protocol.make_client_capabilities()
	capabilties = require("cmp_nvim_lsp").update_capabilities(capabilties)
	for lang_server, config in pairs(lang_servers) do
		config.on_attach = custom_lsp_attach
		config.capabilities = extend_obj(capabilties, config.capabilities)
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

	-- for formatters and linters
	setup_null_ls()
end

return M
