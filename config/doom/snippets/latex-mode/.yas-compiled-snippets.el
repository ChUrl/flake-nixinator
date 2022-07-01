;;; Compiled snippets and support files for `latex-mode'
;;; Snippet definitions:
;;;
(yas-define-snippets 'latex-mode
                     '(("theorem" "\\begin{theorem}{$1}\n  $0\n\\end{theorem}" "theorem" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/theorem.yasnippet" nil nil)
                       ("sum" "\\sum\\limits${1:$(when (> (length yas-text) 0) \"_\")\n}${1:$(when (> (length yas-text) 1) \"{\")\n}${1:i=0}${1:$(when (> (length yas-text) 1) \"}\")\n}${2:$(when (> (length yas-text) 0) \"^\")\n}${2:$(when (> (length yas-text) 1) \"{\")\n}${2:n}${2:$(when (> (length yas-text) 1) \"}\")} $0" "sum" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/sum.yasnippet" nil nil)
                       ("subfile" "\\documentclass[main.tex]{subfiles}\n\n\\begin{document}\n\n\\section{$1}\n\n$0\n\n\\end{document}" "subfile" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/subfile.yasnippet" nil nil)
                       ("remark" "\\begin{remark}{$1}\n  $0\n\\end{remark}" "remark" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/remark.yasnippet" nil nil)
                       ("proof" "\\begin{proof}{$1}\n  $0\n\\end{proof}\n" "proof" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/proof.yasnippet" nil nil)
                       ("mainfile" "\\input{../pre.tex}\n\n\\begin{document}\n\n\\title{$1} \\subtitle{$2} \\author{Christoph Urlacher} \\date{\\today}\n\n\\maketitle\n\\newpage\n\\tableofcontents\n\\newpage\n\n$0\n\n\\end{document}" "main file" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/main_file.yasnippet" nil nil)
                       ("lemma" "\\begin{lemma}{$1}\n  $0\n\\end{lemma}\n" "lemma" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/lemma.yasnippet" nil nil)
                       ("int" "\\int\\limits${1:$(when (> (length yas-text) 0) \"_\")\n}${1:$(when (> (length yas-text) 1) \"{\")\n}${1:left}${1:$(when (> (length yas-text) 1) \"}\")\n}${2:$(when (> (length yas-text) 0) \"^\")\n}${2:$(when (> (length yas-text) 1) \"{\")\n}${2:right}${2:$(when (> (length yas-text) 1) \"}\")} $0\n" "int" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/int.yasnippet" nil nil)
                       ("im" "\\\\( $1 \\\\)$0" "inline math" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/inline_math.yasnippet" nil nil)
                       ("dm" "\\\\[ $1 \\\\]$0" "display math" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/display_math.yasnippet" nil nil)
                       ("definition" "\\begin{definition}{$1}\n  $0\n\\end{definition}" "definition" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/definition.yasnippet" nil nil)
                       ("corollary" "\\begin{corollary}{$1}\n  $0\n\\end{corollary}\n" "corollary" nil nil nil "/home/christoph/.config/doom/snippets/latex-mode/corollary.yasnippet" nil nil)))


;;; Do not edit! File generated at Wed Apr 13 20:49:27 2022
