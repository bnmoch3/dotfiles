local function format_markdown()
	vim.lsp.buf.format()
	vim.cmd("normal ze")
end

local fmtMarkdownGroup = vim.api.nvim_create_augroup("FmtMarkdownGroup", { clear = true })
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = format_markdown,
	pattern = { "*.md" },
	group = fmtMarkdownGroup,
})
