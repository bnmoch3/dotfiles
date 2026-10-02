local M = {}

local arranger = nil

local function listed_buffers()
	return vim.fn.getbufinfo({ buflisted = 1 })
end

local function normalize_path(path)
	return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

local function basename_counts(buffers)
	local counts = {}

	for _, buf in ipairs(buffers) do
		if buf.name ~= "" then
			local basename = vim.fn.fnamemodify(buf.name, ":t")
			counts[basename] = (counts[basename] or 0) + 1
		end
	end

	return counts
end

local function display_names(buffers)
	local counts = basename_counts(buffers)
	local names = {}

	for _, buf in ipairs(buffers) do
		if buf.name == "" then
			names[buf.bufnr] = "[No Name]"
		else
			local basename = vim.fn.fnamemodify(buf.name, ":t")

			if counts[basename] > 1 then
				names[buf.bufnr] = vim.fn.fnamemodify(buf.name, ":~:.")
			else
				names[buf.bufnr] = basename
			end
		end
	end

	return names
end

function M.buffer_path_display()
	local counts = basename_counts(listed_buffers())

	return function(_, path)
		local basename = vim.fn.fnamemodify(path, ":t")

		if counts[basename] and counts[basename] > 1 then
			return vim.fn.fnamemodify(path, ":~:.")
		end

		return basename
	end
end

local function insert_paths(scratch, paths)
	if not vim.api.nvim_buf_is_valid(scratch) then
		return
	end

	local existing_paths = {}

	for _, line in ipairs(vim.api.nvim_buf_get_lines(scratch, 0, -1, false)) do
		line = vim.trim(line)

		if line ~= "" and not line:match("^#") and not line:match("@%d+%s*$") then
			existing_paths[normalize_path(line)] = true
		end
	end

	local additions = {}

	for _, path in ipairs(paths) do
		path = normalize_path(path)

		if not existing_paths[path] then
			table.insert(additions, path)
			existing_paths[path] = true
		end
	end

	if #additions > 0 then
		vim.api.nvim_buf_set_lines(scratch, -1, -1, false, additions)
	end
end

local function add_files(state)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	require("telescope.builtin").find_files({
		layout_strategy = "vertical",
		layout_config = {
			width = 0.65,
			height = 0.55,
			anchor = "N",
			anchor_padding = 1,
			prompt_position = "top",
		},
		sorting_strategy = "ascending",
		previewer = false,

		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local picker = action_state.get_current_picker(prompt_bufnr)
				local selections = picker:get_multi_selection()

				if #selections == 0 then
					local selected = action_state.get_selected_entry()

					if selected then
						selections = { selected }
					end
				end

				local paths = {}

				for _, entry in ipairs(selections) do
					local path = entry.path or entry.filename or entry.value

					if path then
						path = normalize_path(path)

						if not state.open_paths[path] then
							table.insert(paths, path)
						end
					end
				end

				actions.close(prompt_bufnr)

				if #paths == 0 then
					vim.notify("Selected file is already open", vim.log.levels.INFO)
					return
				end

				insert_paths(state.scratch, paths)
			end)

			return true
		end,
	})
end

local function apply_state(state)
	if state.applying then
		return true
	end

	if not vim.api.nvim_buf_is_valid(state.scratch) then
		return true
	end

	state.applying = true

	local edited = vim.api.nvim_buf_get_lines(state.scratch, 0, -1, false)
	local keep = {}
	local seen_buffers = {}
	local new_paths = {}
	local seen_paths = {}

	for _, line in ipairs(edited) do
		line = vim.trim(line)

		if line ~= "" and not line:match("^#") then
			local bufnr = tonumber(line:match("@(%d+)%s*$"))

			if bufnr then
				if not state.original[bufnr] then
					state.applying = false
					vim.notify("Unknown buffer id: @" .. bufnr, vim.log.levels.ERROR)
					return false
				end

				if seen_buffers[bufnr] then
					state.applying = false
					vim.notify("Duplicate buffer id: @" .. bufnr, vim.log.levels.ERROR)
					return false
				end

				seen_buffers[bufnr] = true
				keep[bufnr] = true
			else
				local path = normalize_path(line)

				if vim.fn.filereadable(path) ~= 1 then
					state.applying = false
					vim.notify("File does not exist: " .. line, vim.log.levels.ERROR)
					return false
				end

				if not state.open_paths[path] and not seen_paths[path] then
					seen_paths[path] = true
					table.insert(new_paths, path)
				end
			end
		end
	end

	local removed = {}

	for _, bufnr in ipairs(state.original_order) do
		if not keep[bufnr] and vim.api.nvim_buf_is_valid(bufnr) then
			table.insert(removed, bufnr)
		end
	end

	for _, bufnr in ipairs(removed) do
		if vim.bo[bufnr].modified then
			state.applying = false
			vim.notify("Cannot delete modified buffer: " .. state.names[bufnr], vim.log.levels.ERROR)
			return false
		end
	end

	for _, bufnr in ipairs(removed) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, {})
		end
	end

	for _, path in ipairs(new_paths) do
		local bufnr = vim.fn.bufadd(path)

		if bufnr ~= 0 then
			vim.bo[bufnr].buflisted = true
			vim.fn.bufload(bufnr)
			state.open_paths[path] = bufnr
		end
	end

	state.applying = false

	if vim.api.nvim_buf_is_valid(state.scratch) then
		vim.bo[state.scratch].modified = false
	end

	return true
end

local function close_arranger(state, target_bufnr, already_applied)
	if state.closing then
		return
	end

	if not already_applied and not apply_state(state) then
		return
	end

	state.closing = true

	if vim.api.nvim_win_is_valid(state.source_win) then
		vim.api.nvim_set_current_win(state.source_win)
	end

	if vim.api.nvim_win_is_valid(state.scratch_win) then
		vim.api.nvim_win_close(state.scratch_win, true)
	end

	if vim.api.nvim_buf_is_valid(state.scratch) then
		vim.api.nvim_buf_delete(state.scratch, { force = true })
	end

	arranger = nil

	if target_bufnr and vim.api.nvim_buf_is_valid(target_bufnr) then
		vim.api.nvim_set_current_buf(target_bufnr)
	end
end

local function jump_from_arranger(state)
	local line = vim.trim(vim.api.nvim_get_current_line())

	if line == "" or line:match("^#") then
		return
	end

	local existing_bufnr = tonumber(line:match("@(%d+)%s*$"))

	if existing_bufnr then
		if not state.original[existing_bufnr] then
			vim.notify("Unknown buffer id: @" .. existing_bufnr, vim.log.levels.ERROR)
			return
		end

		close_arranger(state, existing_bufnr)
		return
	end

	local path = normalize_path(line)

	if vim.fn.filereadable(path) ~= 1 then
		vim.notify("File does not exist: " .. line, vim.log.levels.ERROR)
		return
	end

	if not apply_state(state) then
		return
	end

	local bufnr = state.open_paths[path]

	if not bufnr then
		vim.notify("Could not open file: " .. path, vim.log.levels.ERROR)
		return
	end

	close_arranger(state, bufnr, true)
end

local function open_arranger()
	local buffers = listed_buffers()

	if #buffers == 0 then
		vim.notify("No listed buffers", vim.log.levels.INFO)
		return
	end

	local names = display_names(buffers)
	local original = {}
	local original_order = {}
	local open_paths = {}

	for _, buf in ipairs(buffers) do
		original[buf.bufnr] = true
		table.insert(original_order, buf.bufnr)

		if buf.name ~= "" then
			open_paths[normalize_path(buf.name)] = buf.bufnr
		end
	end

	local lines = {
		"# do not edit existing @buffer_id values",
		"# <leader>fn to add files, <leader>fj to jump to the buffer/file, delete a line to close that buffer, :w, :q, :wq, or <leader>fa to apply and close",
		"",
	}

	for _, bufnr in ipairs(original_order) do
		table.insert(lines, string.format("%s @%d", names[bufnr], bufnr))
	end

	local source_win = vim.api.nvim_get_current_win()
	local scratch = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_name(scratch, "Buffer Arrange")
	vim.api.nvim_buf_set_lines(scratch, 0, -1, false, lines)

	vim.bo[scratch].buftype = "acwrite"
	vim.bo[scratch].bufhidden = "wipe"
	vim.bo[scratch].swapfile = false
	vim.bo[scratch].filetype = "buffer-arrange"

	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.5)

	local row = math.floor((vim.o.lines - height) * 0.2)
	local col = math.floor((vim.o.columns - width) / 2)

	local scratch_win = vim.api.nvim_open_win(scratch, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Buffer Arrange ",
		title_pos = "center",
	})

	vim.wo[scratch_win].number = true
	vim.wo[scratch_win].relativenumber = false
	vim.wo[scratch_win].cursorline = true

	local state = {
		scratch = scratch,
		scratch_win = scratch_win,
		source_win = source_win,
		original = original,
		original_order = original_order,
		open_paths = open_paths,
		names = names,
		applying = false,
		closing = false,
	}

	arranger = state

	-- This is UI state rather than a real file, so allow :q even after
	-- changing the contents. Changes are applied explicitly on exit.
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = scratch,
		callback = function()
			if vim.api.nvim_buf_is_valid(scratch) then
				vim.bo[scratch].modified = false
			end
		end,
	})

	vim.keymap.set("n", "<leader>fn", function()
		add_files(state)
	end, {
		buffer = scratch,
		silent = true,
		desc = "Add files",
	})

	vim.keymap.set("n", "<leader>fj", function()
		jump_from_arranger(state)
	end, {
		buffer = scratch,
		silent = true,
		desc = "Jump to buffer",
	})

	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = scratch,
		callback = function()
			close_arranger(state)
		end,
	})

	vim.api.nvim_create_autocmd("QuitPre", {
		buffer = scratch,
		callback = function()
			if state.closing then
				return
			end

			if not apply_state(state) then
				error("Buffer arrange changes could not be applied")
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = scratch,
		once = true,
		callback = function()
			if arranger == state then
				arranger = nil
			end
		end,
	})
end

function M.toggle_arrange_buffers()
	if arranger and vim.api.nvim_win_is_valid(arranger.scratch_win) then
		close_arranger(arranger)
	else
		open_arranger()
	end
end

return M
