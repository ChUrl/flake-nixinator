;;; Compiled snippets and support files for `org-mode'
;;; Snippet definitions:
;;;
(yas-define-snippets 'org-mode
                     '(("cdot" "·" "multiplication sign" nil nil nil "/home/christoph/.config/doom/snippets/org-mode/multiplication_sign.yasnippet" nil nil)
                       ("im" "\\\\( $0 \\\\)" "inline math" nil nil
                        ((yas-after-exit-snippet-hook #'org-edit-special))
                        "/home/christoph/.config/doom/snippets/org-mode/inline_math.yasnippet" nil nil)
                       ("latexp" "#+OPTIONS: tags:nil date:nil num:nil toc:nil tags:nil\n#+TAGS: $0\n" "latex export preamble" nil nil nil "/home/christoph/.config/doom/snippets/org-mode/export.yasnippet" nil nil)
                       ("lrarr" "⇔" "equivalent sign" nil nil nil "/home/christoph/.config/doom/snippets/org-mode/equivalent_sign.yasnippet" nil nil)
                       ("begin" "\\\\begin{$1}\n    $0\n\\\\end{$1}" "new environment" nil nil nil "/home/christoph/.config/doom/snippets/org-mode/environment.yasnippet" nil nil)
                       ("dm" "\\\\[ $1 \\\\]$0" "display math" nil nil nil "/home/christoph/.config/doom/snippets/org-mode/display_math.yasnippet" nil nil)
                       ("dfa" "#+BEGIN_SRC dot :file $1.png :cmdline -Kdot -Tpng\ndigraph {\n    rankdir = LR;\n    splines = true;\n    node [shape = doublecircle]; Z1;\n    node [shape = circle];\n    Z0 -> Z1 [label = \"\"];\n    $0\n}\n#+END_SRC\n" "graphviz deterministic finite automaton" nil nil nil "/home/christoph/.config/doom/snippets/org-mode/dfa.yasnippet" nil nil)
                       ("delta" "Δ" "Delta" nil nil nil "/home/christoph/.config/doom/snippets/org-mode/big_delta.yasnippet" nil nil)
                       ("srcR" "#+begin_src R :session *R* :tangle yes :exports both\n\n#+end_src\n" "R source block" nil nil nil "/home/christoph/.config/doom/snippets/org-mode/R_source_block" nil nil)))


;;; Do not edit! File generated at Wed Apr 13 20:49:27 2022
