return {
	-- The first list contains manually expanded snippts
	--
	-- The fmta function accepts a string ([[]] denote multiline strings) and node table.
	-- The node table entry order corresponds to the delimiters,
	-- the indices denote the jumping order, 0 is jumped to last.
	--
	-- Example:
	-- s("beg", fmta([[
	-- 	   \begin{<>}
	-- 	     <>
	-- 	   \end{<>}]],
	-- 	   { i(1), i(0), rep(1) }
	-- )),
	--
	-- The first jumping position (1) fills the \begin{<>} (and \end{<>} because of the repeat).
	-- The last jumping position (0) fills the body.

	-- \begin{environment}
	s(
		"beg",
		fmta(
			[[
		        \begin{<>}
		          <>
		        \end{<>}
	        ]],
			{ i(1), i(0), rep(1) }
		)
	),
}, {
	-- The second list contains autosnippets
}
