local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

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
		{ trig = "beg", name = "begin/end", descr = "begin/end environment (generic)" },
		fmta(
			[[
		        \begin{<>}
		          <>
		        \end{<>}
	        ]],
			{ i(1), i(0), rep(1) }
		)
	),
	s(
		{ trig = "item", name = "itemize", dscr = "bullet points (itemize)" },
		fmta(
			[[
				\begin{itemize}
				\item <>
				\end{itemize}
			]],
			{ i(0) }
		)
	),
	s(
		{ trig = "enum", name = "enumerate", dscr = "bullet points (enumerate)" },
		fmta(
			[[
				\begin{enumerate}
				\item <>
				\end{enumerate}
			]],
			{ i(0) }
		)
	),
}, {
	-- The second list contains autosnippets
}
