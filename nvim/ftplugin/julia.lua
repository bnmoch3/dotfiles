local fmtJuliaGroup = vim.api.nvim_create_augroup("fmtJuliaGroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		vim.cmd("JuliaFormatterFormat")
	end,
	pattern = { "*.jl" },
	group = fmtJuliaGroup,
})
