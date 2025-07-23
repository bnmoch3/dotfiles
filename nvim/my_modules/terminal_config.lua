local M = {}

local function terminal_filename()
	local bufname = vim.api.nvim_buf_get_name(0)
	local buftype = vim.bo.buftype
	if buftype == "terminal" then
		-- extract command - handle different terminal buffer name formats
		local command = bufname:match("://.-//.-:([^;]+)")
		if command then
			-- clean up the command (remove full paths, keep just the executable)
			command = command:match("([^/]+)$") or command
			if bufname:match("toggleterm") then
				local term_num = bufname:match("#toggleterm#(%d+)")
				return string.format("%s:%s", command, term_num or "?")
			else
				return command
			end
		else
			return "Terminal"
		end
	elseif bufname == "" then
		return "[No Name]"
	else
		return vim.fn.expand("%:t")
	end
end

M.terminal_filename = terminal_filename

M.toggleterm_extension = {
	sections = {
		lualine_a = { "mode" }, -- show mode in terminal
		lualine_b = { terminal_filename },
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	filetypes = { "toggleterm" },
}

function M.setup()
	-- ============================================================================
	--                              TERMINAL
	-- ============================================================================
	require("toggleterm").setup({
		shade_terminals = false,
		start_in_insert = true,
		hide_numbers = true,
		close_on_exit = true,
		-- direction = "float",
	})

	vim.api.nvim_create_autocmd("ExitPre", {
		callback = function()
			-- Stop all terminal jobs before exiting
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.bo[buf].buftype == "terminal" then
					local job_id = vim.b[buf].terminal_job_id
					if job_id then
						vim.fn.jobstop(job_id)
					end
				end
			end
		end,
		desc = "Stop all terminal jobs before exiting Neovim",
	})

	local termGroup = vim.api.nvim_create_augroup("TermGroup", { clear = true })
	vim.api.nvim_create_autocmd("BufEnter", {
		group = termGroup,
		pattern = "term://*",
		callback = function()
			if vim.bo.buftype == "terminal" then
				vim.schedule(function()
					vim.cmd("normal! G$")
					vim.cmd("startinsert!")
				end)
			end
		end,
	})

	vim.keymap.set(
		"t",
		"<C-h>",
		"<C-\\><C-n><cmd>TmuxNavigateLeft<CR>",
		{ noremap = true, silent = true, desc = "Terminal: Navigate left (tmux-aware)" }
	)
	vim.keymap.set(
		"t",
		"<C-j>",
		"<C-\\><C-n><cmd>TmuxNavigateDown<CR>",
		{ noremap = true, silent = true, desc = "Terminal: Navigate down (tmux-aware)" }
	)
	vim.keymap.set(
		"t",
		"<C-k>",
		"<C-\\><C-n><cmd>TmuxNavigateUp<CR>",
		{ noremap = true, silent = true, desc = "Terminal: Navigate up (tmux-aware)" }
	)
	vim.keymap.set(
		"t",
		"<C-l>",
		"<C-\\><C-n><cmd>TmuxNavigateRight<CR>",
		{ noremap = true, silent = true, desc = "Terminal: Navigate right (tmux-aware)" }
	)
	vim.keymap.set(
		"t",
		"<C-^>",
		"<C-\\><C-n><C-^>",
		{ noremap = true, silent = true, desc = "Terminal: Alternate file" }
	)
	vim.keymap.set(
		"t",
		"<Esc>",
		"<C-\\><C-n>",
		{ noremap = true, silent = true, desc = "Terminal: Exit to normal mode" }
	)

	vim.keymap.set(
		"n",
		"<Leader>tt",
		":ToggleTerm name=xterminal direction=horizontal<CR>",
		{ noremap = true, silent = true, desc = "Toggle horizontal terminal" }
	)

	-- toggle off shell while in terminal mode
	vim.keymap.set(
		"t",
		"<C-q>",
		"<Cmd>ToggleTerm name=xterminal direction=horizontal<CR>",
		{ noremap = true, silent = true, desc = "Toggle off terminal while in terminal mode" }
	)
	vim.keymap.set(
		"n",
		"<Leader>tf",
		":ToggleTerm name=xterminal direction=float<CR>",
		{ noremap = true, silent = true, desc = "Toggle floating terminal" }
	)
	vim.keymap.set(
		"v",
		"r",
		":ToggleTermSendVisualLines<CR>",
		{ noremap = true, silent = true, desc = "Send visual lines to terminal" }
	)
	vim.keymap.set(
		"n",
		"<Leader>r",
		":ToggleTermSendCurrentLine<CR>",
		{ noremap = true, silent = true, desc = "Send current line to terminal" }
	)

	-- ============================================================================
	--                              TOOLS - TERMINAL
	-- ============================================================================

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

	local todo = create_zoomed_toggle_term("nvim + ~/TODO.txt")
	vim.api.nvim_create_user_command("Todo", function()
		todo:toggle()
	end, { desc = "Open my TODO list" })

	local lazygit = create_zoomed_toggle_term("lazygit")
	vim.keymap.set("n", "<leader>gg", function()
		lazygit:toggle()
	end, { desc = "Lazygit (zoom-safe)" })
end

return M
