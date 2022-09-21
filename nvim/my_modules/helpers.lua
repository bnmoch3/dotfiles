local M = {}

-- for debugging stuff
function M.pretty_print(obj)
	print(vim.inspect(obj))
end

function M.nnoremap(shortcut, command, bufnr)
	if bufnr == nil then
		vim.api.nvim_set_keymap("n", shortcut, command, { noremap = true, silent = true })
	else
		vim.api.nvim_buf_set_keymap(bufnr, "n", shortcut, command, { noremap = true, silent = true })
	end
end

function M.inoremap(shortcut, command)
	vim.api.nvim_set_keymap("i", shortcut, command, { noremap = true, silent = true })
end

function M.vnoremap(shortcut, command)
	vim.api.nvim_set_keymap("v", shortcut, command, { noremap = true, silent = true })
end

return M
