vim.opt_local.number = false
vim.opt_local.relativenumber = false

vim.keymap.set("n", "<C-d>", "<cmd>qa!<CR>", {
	buffer = true,
	silent = true,
})
