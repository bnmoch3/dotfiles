local severity_map = {
	error = vim.diagnostic.severity.ERROR,
	warning = vim.diagnostic.severity.WARN,
	information = vim.diagnostic.severity.INFO,
	hint = vim.diagnostic.severity.HINT,
}

local M = {
	cmd = function()
		local binary_name = "biome"
		-- TODO: add usage of project's biome if present i.e. ./node_modules/.bin/biome
		return binary_name
	end,
	args = { "lint", "--reporter=json" },
	stdin = false,
	append_fname = true,
	ignore_exitcode = true,
	stream = "stdout",
	parser = function(output, bufnr, _linter_cwd)
		local diagnostics = {}
		if output == "" then
			return diagnostics
		end

		-- parse JSON output
		local ok, decoded = pcall(vim.json.decode, output)
		if not ok or not decoded.diagnostics then
			return diagnostics
		end

		local bufpath = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))

		for _, d in ipairs(decoded.diagnostics) do
			local diag_file = d.location and d.location.path and d.location.path.file
			if diag_file then
				local diag_path = vim.fs.normalize(vim.fn.fnamemodify(diag_file, ":p"))
				if diag_path == bufpath then
					local lnum, col, end_lnum, end_col = 0, 0, nil, nil

					-- Prefer structured range if Biome ever provides it
					local range = d.location and d.location.range
					if range and range["start"] and range["end"] then
						lnum = (range["start"].line or 1) - 1
						col = (range["start"].column or 1) - 1
						end_lnum = (range["end"].line or 1) - 1
						end_col = (range["end"].column or 1) - 1
					else
						-- Fallback: compute from byte span against provided sourceCode
						local source = d.location.sourceCode
						local span = d.location.span
						if source and span and span[1] then
							local s_byte, e_byte = span[1], span[2] or span[1]
							local lines = vim.split(source, "\n", { plain = true })

							local function byte_to_pos(byte)
								local off = 0
								for i, line in ipairs(lines) do
									local len = #line + 1 -- + newline
									if off + len > byte then
										return i - 1, byte - off
									end
									off = off + len
								end
								return (#lines - 1), 0
							end

							lnum, col = byte_to_pos(s_byte)
							end_lnum, end_col = byte_to_pos(e_byte)
						end
					end

					-- Build message
					local msg = d.description or ""
					if d.message and #d.message > 0 then
						local parts = {}
						for _, part in ipairs(d.message) do
							parts[#parts + 1] = part.content or ""
						end
						msg = table.concat(parts, "")
					end

					diagnostics[#diagnostics + 1] = {
						source = "biome",
						lnum = lnum,
						col = col,
						end_lnum = end_lnum,
						end_col = end_col,
						message = msg,
						code = d.category,
						severity = severity_map[d.severity] or vim.diagnostic.severity.ERROR,
					}
				end
			end
		end

		return diagnostics
	end,
}

return M
