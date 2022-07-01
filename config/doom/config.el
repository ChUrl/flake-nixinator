;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq! user-full-name "Christoph Urlacher"
       user-mail-address "tobi@urpost.de")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq! doom-font (font-spec :family "Victor Mono" :weight 'semi-bold :size 17) ;; Victor Mono
       doom-big-font (font-spec :family "Victor Mono" :weight 'semi-bold :size 21) ;; Victor Mono
       doom-variable-pitch-font (font-spec :family "Noto Sans CJK SC" :size 17) ;; Overpass, Source Han Sans CN
       doom-unicode-font (font-spec :family "Noto Sans CJK SC" :size 17) ;; Use this for chinese characters 汉字
       ;; doom-serif-font (font-spec :family "IBM Plex Mono" :weight 'light)
       )

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; 'doom-one-light
;; 'doom-vibrant ist noch nett
;; 'doom-one default
(setq! doom-theme 'doom-one-light)
(delq! t custom-theme-load-path)        ;; we don't need defaults

(custom-set-faces!
  '(doom-modeline-buffer-modified :foreground "orange")) ;; no red color in modeline



;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq! org-directory "~/Notes/Org")
(setq! org-roam-directory "~/Notes/Org")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq! display-line-numbers-type 'relative)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; set variables
(setq! undo-limit 80000000 ;; 80Mb
       gc-cons-threshold 100000000 ;; 100Mb
       ;; evil-want-fine-undo t ;; may too fine as single character strokes are recognized
       create-lockfiles nil
       vc-follow-symlinks t
       auto-save-default t ;; restore with M-x recover-file
       ;; mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil))
       ;; mouse-wheel-progressive-speed nil ;; don't increase amount on faster scroll
       ;; pixel-scroll-precision-large-scroll-height 40.0
       ;; pixel-scroll-precision-interpolation-factor 30
       mouse-wheel-follow-mouse t ;; scroll window where the mouse is over
       doom-fallback-buffer-name "Doom"
       +doom-dashboard-name "Doom"
       +workspaces-on-switch-project-behavior t
       confirm-kill-processes nil ;; dont ask to kill procs
       bidi-paragraph-direction 'left-to-right ;; no lang direction scan for speed
       bidi-inhibit-bpa t ;; speed with long nested lines
       tab-width 4
       indent-tabs-mode nil ;; use spaces
       tab-always-indent t ;; don't toggle completion just indentation
       fast-but-imprecise-scrolling t
       redisplay-skip-fontification-on-input t
       frame-resize-pixelwise t
       frame-inhibit-implied-resize t
       idle-update-delay 1.0 ;; don't update as often to speed things up
       scroll-margin 10 ;; don't scroll to last line
       evil-vsplit-window-right t ;; switch to new windows
       evil-split-window-below t
       evil-kill-on-visual-paste nil ;; don't copy overwritten selection
       ;; history-delete-duplicates t
       )


(setq-default tab-width 4
              indent-tabs-mode nil ;; use spaces
              display-line-numbers-width 4
              line-spacing 0.1 ;; slightly more space
              tab-always-indent t
              major-mode 'org-mode
              delete-by-moving-to-trash t
              window-combination-resize t ;; take space from all windows, not current
              x-stretch-cursor t
              history-length 1000
              use-short-answers t
              confirm-nonexistent-file-or-buffer nil
              select-enable-clipboard t
              )


;; modes, functions
;; (delete-selection-mode -1) ;; TODO: not sure how it works with evil
(global-subword-mode 1)          ;; iterate through CamelCase
(delete-selection-mode 1)        ;; replace selection
(display-time-mode -1) ;; no clock
(scroll-bar-mode -1) ;; no scroll bar
(set-fringe-mode 5)              ;; left hand side change marker width
;; (save-place-mode 1) ;; save buffer cursor position ;; agenda can't jump to right heading anymore
(semantic-mode 1)
(tooltip-mode -1) ;; no hover button tooltips
(global-auto-revert-mode 1) ;; refrashe buffer if changed on disk
(keychain-refresh-environment) ;; keychain ssh
;; (global-tree-sitter-mode) ;; faster syntax highlighting for all buffers that support tree-sitter
;; (pixel-scroll-precision-mode) ;; better mouse scroll

;; clean starup screen
;; (remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
;; (add-hook! '+doom-dashboard-mode-hook (hide-mode-line-mode 1) (hl-line-mode -1))
;; (setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))

;; doom modeline (not needed for +light)
(after! doom-modeline
  (setq! doom-modeline-major-mode-icon t
         doom-modeline-major-mode-color-icon t
         doom-modeline-checker-simple-format t
         doom-modeline-bar-width 3
         doom-modeline-height 35
         doom-modeline-indent-info t
         doom-modeline-github t
         doom-modeline-minor-modes nil
         doom-modeline-window-width-limit 80
         doom-modeline-lsp t
         doom-modeline-enable-word-count t
         doom-modeline-buffer-file-name-style 'truncate-with-project
         ))

;; theme, fonts
(after! doom-theme
  (setq! doom-themes-enable-bold t
         doom-themes-enable-italic t
         doom-themes-padded-modeline t
         ))
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic)
  )
(custom-set-faces!
  '(org-document-title :height 1.2)
  )
(custom-set-faces!
  '(outline-1 :weight extra-bold :height 1.25)
  '(outline-2 :weight bold :height 1.15)
  '(outline-3 :weight bold :height 1.12)
  '(outline-4 :weight semi-bold :height 1.09)
  '(outline-5 :weight semi-bold :height 1.06)
  '(outline-6 :weight semi-bold :height 1.03)
  '(outline-8 :weight semi-bold)
  '(outline-9 :weight semi-bold)
  )

(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

;; remove text properties from kill ring when closing emacs
(defun unpropertize-kill-ring ()
  (setq kill-ring (mapcar 'substring-no-properties kill-ring)))
(add-hook! 'kill-emacs-hook 'unpropertize-kill-ring)

;; which-key
(after! which-key
  (setq! which-key-idle-delay 0.5 ;; faster key help
         which-key-sort-order 'which-key-key-order)) ;; sort by keys but separate upper and lowercase

(after! evil
  (setq! evil-ex-substitute-global t
         evil-move-cursor-back nil ;; don't move cursor back when leaving insert mode
         evil-kill-on-visual-paste nil ;; don't copy replaced text to kill ring ;; TODO: This is duplicated, where does it belong?
         ;; evil-backspace-join-lines nil ;; can't backspace but C-<backspace> still fucked
         ))

;; smartparens
(use-package! smartparens
  :init (add-hook! 'smartparens-enabled-hook #'evil-smartparens-mode)
  :hook (
         ;; Enable strict smartparens in lisps
         (clojure-mode . smartparens-strict-mode)
         (lisp-mode . smartparens-strict-mode)
         (emacs-lisp-mode . smartparens-strict-mode)
         ))

;; use this to load before evil-snipe, as <s> and <S> conflict
(use-package! evil-smartparens)

;; bindings
(map! :map global-map
      "M-l" nil ;; downcase word
      "M-h" nil
      )

(map! :after evil-org-agenda
      :map evil-org-agenda-mode-map
      :m "j" #'org-agenda-next-item
      :m "k" #'org-agenda-previous-item
      :m "h" #'org-agenda-todo
      :m "l" #'org-agenda-goto
      )

(map! :after company
      :map company-active-map
      "TAB" #'indent-for-tab-command
      )

(map! :after evil
      :map evil-normal-state-map
      "M-j" #'drag-stuff-down
      "M-k" #'drag-stuff-up
      "C-<backspace>" #'subword-backward-kill
      "M-m" #'evil-multiedit-match-and-next
      "M-h" #'rotate-text-backward
      "M-l" #'rotate-text

;;      "C-<tab>" #'centaur-tabs-forward
;;      "C-<iso-lefttab>" #'centaur-tabs-backward

      "<tab>" #'doom/dumb-indent
      "<backtab>" #'doom/dumb-dedent
      "M-L" #'dumb-jump-go
      "M-H" #'dumb-jump-back

      ;; window bindings
      "C-<left>" #'evil-window-decrease-width
      "C-<right>" #'evil-window-increase-width
      "C-<up>" #'evil-window-decrease-height
      "C-<down>" #'evil-window-increase-height
      )

(map! :after evil
      :map evil-insert-state-map
      "M-j" #'drag-stuff-down
      "M-k" #'drag-stuff-up

      "M-h" #'rotate-text-backward
      "M-l" #'rotate-text
      )

(map! :after smartparens
      :map smartparens-mode-map
      "M-r" #'sp-raise-sexp
      "M-d" #'sp-kill-hybrid-sexp
      "M-s" #'sp-splice-sexp

      "C-M-j" #'sp-backward-slurp-sexp
      "M-K" #'sp-forward-slurp-sexp
      "C-M-k" #'sp-backward-barf-sexp
      "M-J" #'sp-forward-barf-sexp

      "M-S" #'sp-split-sexp
      "C-S" #'sp-join-sexp

      "C-(" #'sp-wrap-round
      ;; "C-[" #'sp-wrap-square ;; C-[ can't be rebound
      "C-{" #'sp-wrap-curly
      )

;; other binding is leader o p
(map! :desc "Toggle Treemacs"
      :leader
      "0" #'treemacs)

(map! :desc "Insert Snippet"
      "M-/" #'yas-expand)

;; rotate text
(after! rotate-text
  (pushnew! rotate-text-words'("true" "false"))
  )

;; cider
(setq! cider-overlays-use-font-lock t
       cider-show-error-buffer nil
       cider-eval-result-prefix "⟹ "
       )
(setq! eros-eval-result-prefix "⟹ ")

;; Always display workspaces
(after! persp-mode
  (defun display-workspaces-in-minibuffer ()
    (with-current-buffer " *Minibuf-0*"
      (erase-buffer)
      (insert (+workspace--tabline))))
  (run-with-idle-timer 1 t #'display-workspaces-in-minibuffer)
  (+workspace/display))

(after! minimap
  (setq! minimap-always-recenter nil
         minimap-update-delay 0.25
         minimap-hide-fringes t
         ))

;; projectile
(after! projectile
  (setq! projectile-track-known-projects-automatically t
         projectile-indexing-method 'alien ;; alien is faster than hybrid but doesn't recognize .projectile markers
         projectile-sort-order 'recentf
         projectile-ignored-projects '("/home/christoph/.emacs.d" "/tmp" "/home/christoph/" "/home/christoph/.emacs.d/.local/straight/repos/")
         ;; projectile-project-root-files #'(".projectile") ;; only recognize .projectile projects
         ;; projectile-project-root-functions #'(projectile-root-top-down
         ;;                                      projectile-root-top-down-recurring
         ;;                                      projectile-root-bottom-up
         ;;                                      projectile-root-local)
         ))

;; marginalia
(after! marginalia
  (setq marginalia-censor-variables nil)
  (defadvice! +marginalia--anotate-local-file-colorful (cand)
    "Just a more colourful version of ` marginalia--anotate-local-file'."
    :override #'marginalia--annotate-local-file
    (when-let (attrs (file-attributes (substitute-in-file-name
                                       (marginalia--full-candidate cand))
                                      'integer))
      (marginalia--fields
       ((marginalia--file-owner attrs)
        :width 12 :face 'marginalia-file-owner)
       ((marginalia--file-modes attrs))
       ((+marginalia-file-size-colorful (file-attribute-size attrs))
        :width 7)
       ((+marginalia--time-colorful (file-attribute-modification-time attrs))
        :width 12))))
  (defun +marginalia--time-colorful (time)
    (let* ((seconds (float-time (time-subtract (current-time) time)))
           (color (doom-blend
                   (face-attribute 'marginalia-date :foreground nil t)
                   (face-attribute 'marginalia-documentation :foreground nil t)
                   (/ 1.0 (log (+ 3 (/ (+ 1 seconds) 345600.0)))))))
      ;; 1 - log(3 + 1/(days + 1)) % grey
      (propertize (marginalia--time time) 'face (list :foreground color))))
  (defun +marginalia-file-size-colorful (size)
    (let* ((size-index (/ (log10 (+ 1 size)) 7.0))
           (color (if (< size-index 10000000) ; 10m
                      (doom-blend 'orange 'green size-index)
                    (doom-blend 'red 'orange (- size-index 1)))))
      (propertize (file-size-human-readable size) 'face (list :foreground color)))))

;; tabs
;; (after! centaur-tabs
;;   (centaur-tabs-group-by-projectile-project)
;;   (setq centaur-tabs-height 36
;;         centaur-tabs-set-icons t
;;         centaur-tabs-style "rounded"
;;         centaur-tabs-modified-marker "o"
;;         centaur-tabs-close-button "×"
;;         centaur-tabs-set-bar 'above
;;         centaur-tabs-gray-out-icons 'buffer
;;         )
;;   (push "Doom" centaur-tabs-excluded-prefixes)
;;   )
;; (add-hook! 'org-mode-hook 'centaur-tabs-local-mode) ;; disable tabs in selected buffers
;; (add-hook! 'latex-mode-hook 'centaur-tabs-local-mode)

;; workspaces
(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override "main"))

;; latex
(setq! +latex-viewers '(pdf-tools)
       TeX-command-extra-options "-shell-escape" ;; for package minted
       TeX-auto-save t ;; parse on save
       TeX-parse-self t ;; parse on load
       LaTeX-indent-level 4
       TeX-source-correlate-method 'synctex
       )
(add-hook! 'LaTeX-mode-hook 'turn-on-auto-fill 'LaTeX-math-mode)

;; page break character as line
(use-package! page-break-lines
  :commands page-break-lines-mode
  :init
  (autoload 'turn-on-page-break-lines-mode "page-break-lines"))

(after! elcord
  (setq elcord-use-major-mode-as-main-icon t
        elcord-display-elapsed nil))

;; org ===================================================================================================================================================================================================

;; (use-package! org-pretty-table
;;   :after org
;;   :config (org-pretty-table-mode global-org-pretty-table-mode))

(global-org-modern-mode)
(after! org-modern
  (setq
   ;; Edit settings
   org-auto-align-tags nil
   org-tags-column 0
   org-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t

   ;; Org styling, hide markup etc.
   org-hide-emphasis-markers t
   org-pretty-entities t
   org-ellipsis "…"

   ;; Agenda styling
   org-agenda-block-separator ?─
   org-agenda-time-grid
   '((daily today require-timed)
     (800 1000 1200 1400 1600 1800 2000)
     " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
   org-agenda-current-time-string
   "⭠ now ─────────────────────────────────────────────────"))

(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autosubmarkers t
        org-appear-autolinks nil)
  ;; for proper first-time setup, `org-appear--set-elements'
  ;; needs to be run after other hooks have acted.
  (run-at-time nil nil #'org-appear--set-elements))

(use-package! org-super-agenda
  :after org-agenda
  :init
  (setq! org-super-agenda-groups '((:name "Lectures"
                                    :tag "class"
                                    :tag "session")
                                   (:name "Renesas"
                                    :tag "workhours"
                                    :tag "worktask"
                                    :tag "meeting")
                                   (:name "Sheets"
                                    :category "sheet"
                                    :tag "sheet")
                                   (:name "Organization"
                                    :tag "orga")
                                   (:name "Computer"
                                    :tag "computer")
                                   (:name "Today"
                                    :scheduled today
                                    :deadline today)
                                   (:name "Overdue"
                                    :deadline past)
                                   (:name "Upcoming Tasks"
                                    :scheduled future)
                                   (:name "Upcoming Deadlines"
                                    :deadline future)
                                   (:name "Projects"
                                    :tag "project"))
         org-super-agenda-header-map nil)
  :commands
  (org-super-agenda-mode))

(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam ;; or :after org
  ;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
  ;;         a hookable mode anymore, you're advised to pick something yourself
  ;;         if you don't care about startup time, use
  ;; :hook (after-init . org-roam-ui-mode) ;; emacs-startup-hook?
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(after! org
  (setq! org-default-notes-file (expand-file-name "notes-personal.org" org-directory)
         org-attach-id-dir "/home/christoph/Notes/Org/Attach/"

         org-attach-method 'cp ;; copy to be able to sync with nextcloud, hope the duplicates don't matter as much
         org-link-file-path-type 'noabbrev ;; don't abbreviate home dir and use absolute path
         ;; org-ellipsis " ⮟ " ;; collapsed headline character ( ▼, ⮟, ⌄ ) ;; not always displayed properly (no idea why)
         org-startup-folded 'fold
         org-startup-numerated nil
         org-startup-indented t
         org-startup-with-inline-images t
         org-display-remote-inline-images 'download
         org-startup-with-latex-preview nil ;; has long loading times if preview isn't cached yet, also use texfrag
         org-startup-truncated t
         org-list-allow-alphabetical t
         org-hide-emphasis-markers nil ;; org-pretty-mode does that
         org-hide-leading-stars nil    ;; org-superstar does that
         org-log-done 'time
         org-use-property-inheritance t
         org-cycle-separator-lines 2 ;; keep empty line between collapsed trees (1) org not (2)
         org-confirm-babel-evaluate nil ;; shut up
         org-export-babel-evaluate t
         ;; org-export-in-background t
         org-fontify-quote-and-verse-blocks t

         org-superstar-remove-leading-stars t
         org-superstar-item-bullet-alist '((?* . ?•) ;; Old dash: –
                                           (?+ . ?➤)
                                           (?- . ?•))


         org-todo-keywords '((sequence "TODO(t)" "IN-PROGRESS(p)" "HALT(h)" "WAITING(w)" "OPTIONAL(o)" "|" "DONE(d)" "CANCELED(c)"))
         org-todo-keyword-faces '(("TODO" . org-todo)
                                  ("IN-PROGRESS" . (:foreground "green" :weight bold))
                                  ("HALT" . (:foreground "orange" :weight bold))
                                  ("WAITING" . (:foreground "yellow" :weight bold))
                                  ("DONE" . org-done)
                                  ("CANCELED" . org-warning)
                                  )

         org-tag-alist '((:startgrouptag)
                         ("@work" . ?w) ;; the letter is for quick selection
                         (:grouptags)
                         ("workhours")
                         ("meeting" . ?m)
                         ("worktask" . ?t)
                         (:endgrouptag)

                         (:startgrouptag)
                         ("@uni" . ?u)
                         (:grouptags)
                         ("class" . ?l)
                         ("session" . ?e)
                         ("sheet" . ?s)
                         ("reflect" . ?r)
                         ("orga" . ?o)
                         (:endgrouptag)

                         (:startgrouptag)
                         ("@home" . ?h)
                         (:grouptags)
                         ("guitar")
                         ("appointment" . ?a)
                         ("project" . ?p)
                         ("computer" . ?c)
                         (:endgrouptag)

                         ;; ungrouped tags
                         )

         org-capture-templates '(("t" "Personal Todo" entry (file+headline "~/Notes/Org/todo_private.org" "Allgemeine Tasks")
                                  "* TODO %^{Title} :@home:%^g\n%?" :empty-lines 1)
                                 ("s" "Personal Scheduled Todo" entry (file+headline "~/Notes/Org/todo_private.org" "Allgemeine Tasks")
                                  "* TODO %^{Title} :@home:%^g\nSCHEDULED: %^{Scheduled to Begin}t\n%?" :empty-lines 1)
                                 ("d" "Personal Scheduled Todo with Deadline" entry (file+headline "~/Notes/Org/todo_private.org" "Allgemeine Tasks")
                                  "* TODO %^{Title} :@home:%^g\nSCHEDULED: %^{Scheduled to Begin}t DEADLINE: %^{Deadline}T\n%?" :empty-lines 1)
                                 ("a" "Personal Appointment" entry (file+headline "~/Notes/Org/todo_private.org" "Termine")
                                  "* %^{Title} :@home:appointment:\nSCHEDULED: %^{Appointment Date/Time}T\n%?" :empty-lines 1)
                                 ("p" "Project" entry (file+headline "~/Notes/Org/Projects/coding_projects.org" "Projects")
                                  "* TODO %^{Title} :@home:project:\n%?" :empty-lines 1)
                                 ("T" "Uni Todo" entry (file+headline "~/Notes/Org/todo_ss_2022.org" "Allgemeine Tasks")
                                  "* TODO %^{Title} :@uni:%^g\n%?" :empty-lines 1)
                                 ("S" "Uni Sheduled Todo" entry (file+headline "~/Notes/Org/todo_ss_2022.org" "Allgemeine Tasks")
                                  "* TODO %^{Title} :@uni:%^g\nSCHEDULED: %^{Scheduled to Begin}t\n%?" :empty-lines 1)
                                 ("D" "Uni Scheduled Todo with Deadline" entry (file+headline "~/Notes/Org/todo_ss_2022.org" "Allgemeine Tasks")
                                  "* TODO %^{Title} :@uni:%^g\nSCHEDULED: %^{Scheduled to Begin}t DEADLINE: %^{Deadline}T\n%?" :empty-lines 1)
                                 ("A" "Uni Appointment" entry (file+headline "~/Notes/Org/todo_ss_2022.org" "Termine")
                                  "* %^{Title} :@uni:appointment:\nSCHEDULED: %^{Appointment Date/Time}T\n%?" :empty-lines 1)
                                 ("E" "Uni Exercise" entry (file+headline "~/Notes/Org/todo_ss_2022.org" "Übungsblätter")
                                  "* TODO %^{Title} :@uni:sheet:%^g\n%?" :empty-lines 1)
                                 ("F" "Uni Follow Up" entry (file+headline "~/Notes/Org/todo_ss_2022.org" "Nachbereiten")
                                  "* TODO %^{Title} :@uni:reflect:%^g\nSCHEDULED: %^{Scheduled for}t\n%?" :empty-lines 1)
                                 )

         ;; agenda
         org-agenda-show-all-dates nil
         org-agenda-block-separator 9472 ;; this: ─ Character
         org-agenda-show-current-time-in-grid nil
         org-agenda-use-time-grid nil
         org-agenda-skip-scheduled-if-done t
         org-agenda-skip-deadline-if-done t
         org-agenda-skip-timestamp-if-done t
         org-agenda-include-deadlines t
         org-deadline-warning-days 7
         org-agenda-tags-column 90
         org-agenda-start-on-weekday nil ;; start today
         org-agenda-start-day nil        ;; start today
         org-agenda-span 7
         org-agenda-skip-scheduled-if-deadline-is-shown nil
         org-agenda-skip-deadline-prewarning-if-scheduled t
         org-agenda-prefix-format '((agenda . " %i %-20:c%?-12t% s") ;; mehr platz für category
                                    (todo . " %i %-15:c")
                                    (tags . " %i %-15:c")
                                    (search . " %i %-15:c"))
         org-agenda-compact-blocks nil
         org-agenda-format-date (lambda (date) (concat "\n"
                                                       (make-string (window-width) 9472)
                                                       "\n"
                                                       (org-agenda-format-date-aligned date))) ;; add separators between agenda days

         ;; latex
         org-highlight-latex-and-related '(native script entities) ;; don't highlight latex
         org-latex-listings 'minted
         org-latex-minted-options '(("frame" "lines")
                                    ("linenos=true"))
         ;; org-latex-image-default-width nil ;; to avoid resizing
         org-format-latex-options (plist-put org-format-latex-options :scale 1.2) ;; bigger inline latex
         org-format-latex-options (plist-put org-format-latex-options :background "Transparent")
         org-preview-latex-default-process 'dvisvgm ;; Funktioniert mit Tikz
         org-latex-default-class "koma-article"
         ;; for latex preview, not export
         org-latex-packages-alist '(
                                    ("" "minted") ;; use org src block instead
                                    ("" "tikz" t) ;; use org graphviz block instead
                                    ("" "mathtools" t)
                                    ("" "beton" t)
                                    ("" "eulerpx" t)
                                    ("" "centernot" t)
                                    ("" "ellipsis" t)
                                    ;; ("" "christex" t) ;; way too slow for preview generation
                                    )
         org-latex-compiler "lualatex" ;; sets the -%latex option for latexmk
         org-latex-pdf-process '("latexmk -shell-escape -f -pdf -%latex -interaction=nonstopmode -output-directory=%o %f")
         ;; org-latex-pdf-process '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f") ;; Old process

         org-latex-tables-booktabs t
         )
  (add-to-list 'org-src-lang-modes '("dot" . graphviz-dot))
  (add-to-list 'org-src-block-faces '("latex" (:inherit default :extend t))) ;; don't use org-block faces

  )

(setq org-agenda-deadline-faces
      '((1.001 . error)
        (1.0 . org-warning)
        (0.5 . org-upcoming-deadline)
        (0.0 . org-upcoming-distant-deadline)))

;; Org-LaTeX-Export
(after! ox-latex
  (add-to-list 'org-latex-classes
               '("koma-article"
                 "\\documentclass[12pt,a4paper,ngerman,parskip=full]{scrartcl}
\\usepackage{christex}
                   [NO-DEFAULT-PACKAGES]
                   [NO-PACKAGES]
                   [NO-EXTRA]"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")
                 )))

;; TODO: Investigate how texfrag works, I want it to use lualatex and christex
;; better inline latex preview
(use-package! texfrag
  :after org
  :hook (org-mode . texfrag-mode)
  :config
  (setq! texfrag-scale 1.3
         texfrag-preview-buffer-at-start t
         texfrag-header-default "\\documentclass{article}
\\usepackage{amsmath,amsfonts}
\\usepackage[utf8]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{beton}
\\usepackage{eulerpx}
\let\\openbox\\relax
\\usepackage{mathtools}
\\usepackage{ellipsis}
\\usepackage{centernot}"
         ))
;; texfrag again on font size change
(add-hook 'writeroom-mode-hook (lambda () (when texfrag-mode (run-with-timer 0.1 nil 'texfrag-document))))
;; texfrag org detect starred envs \begin{align*}
(add-hook 'org-mode-hook (lambda () (setq! texfrag-frag-alist
                                           '((("\\\\(" texfrag-org-latex-p) "\\\\)" "$" "$") ;; usual inline math \( ... \)
                                             (("\\\\\\[" texfrag-org-latex-p) "\\\\\\]" "\\\\[" "\\\\]" :display t) ;; usual display math \[ ... \]
                                             (("\\\\begin{\\([a-z*]+\\)}" texfrag-org-latex-p) "\\\\end{\\1}" "\\\\begin{\\2}" "\\\\end{\\2}" :display t) ;; enumerated environments
                                             ;; TODO: (("\\\\begin{\\([a-z*]+\\)}" texfrag-org-latex-p) "\\\\end{\\1}" "\\\\begin{\\2}" "\\\\end{\\2}" :display t) ;; unenumerated environments
                                             ))))
;; TODO: texfrag regenerate preview at point after editing latex
;; (define-advice org-edit-src-exit (:before (&rest _) regenerate-preview-at-point)
;;   (when (eq major-mode 'latex-mode)
;;     (message "Regenerating LaTeX preview...")
;;     (preview-at-point)))

(after! org-agenda
  (org-super-agenda-mode))

(after! org-noter
  (setq! org-noter-notes-search-path '("~/Notes/Org")
         org-noter-always-create-frame nil
         org-noter-notes-window-behavior '(start scroll)
         org-noter-notes-window-location 'horizontal-split))

(after! org-roam
  (setq! org-roam-index-file "index.org"))
(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.33)
               (window-height . fit-window-to-buffer)))

;; (add-hook 'org-mode-hook 'org-fragtog-mode) ;; toggle inline previews (slow)
(add-hook! 'org-mode-hook #'+org-pretty-mode) ;; removed #'mixed-pitch-mode
;; (remove-hook 'text-mode-hook #'visual-line-mode)
;; (add-hook 'text-mode-hook #'auto-fill-mode)
;; (add-hook 'writeroom-mode-hook #'visual-line-mode)

;; For font-lock lag
(defun locally-defer-font-lock ()
  "Set jit-lock defer and stealth, when buffer is over a certain size."
  (when (> (buffer-size) 50000)
    (setq-local jit-lock-defer-time 0.05
                jit-lock-stealth-time 1)))
(add-hook 'org-mode-hook #'locally-defer-font-lock)


;; end org =============================================================================================================================================================================================

;; info-colors
(use-package! info-colors
  :commands (info-colors-fontify-node))
(add-hook 'Info-selection-hook 'info-colors-fontify-node)
(add-hook 'Info-mode-hook #'mixed-pitch-mode)

;; calc
(setq calc-angle-mode 'rad              ; radians are rad
      calc-symbolic-mode t)

;; emojify
(setq emojify-emoji-set "twemoji-v2")

;; zen
(after! writeroom-mode
  (setq! writeroom-fullscreen-effect 'maximized
         writeroom-global-effects (remove 'writeroom-set-alpha writeroom-global-effects)
         writeroom-maximize-window t))
;; disable lsp/flycheck overlays during zen mode
(add-hook! 'writeroom-mode-enable-hook (flycheck-posframe-mode -1) (lsp-ui-mode -1))
(add-hook! 'writeroom-mode-disable-hook (flycheck-posframe-mode 1) (lsp-ui-mode 1))

;; cpp
(after! cc-mode
  (setq! c-default-style "stroustrup"
         c-basic-offset 4)
  ;; (set-docsets! 'cc-mode "C" "C++" "CMake")
  (add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
  )
(setq lsp-clients-clangd-args '(
                                "-j=3" ;; Number of async workers (also used by background index)
                                "--background-index" ;; Index in background and persist on disk
                                "--clang-tidy"
                                "--completion-style=detailed"
                                "--header-insertion=never"
                                "--header-insertion-decorators=0"
                                ))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))
(after! flycheck
  (setq! flycheck-clang-args '("--checks='*'")
         flycheck-clang-pedantic t))

;; python
(after! python
  (set-popup-rule! "^\\*Python" :side 'bottom :size 0.3 :quit nil) ;; keep python repl open
  (set-popup-rule! "^\\*lsp-help\\*" :side 'right :size 0.3 :quit t)
  (setq! python-shell-completion-native-enable nil))
(after! lsp-python-ms
  (set-lsp-priority! 'pyright 1))

;; haskell
(after! haskell-mode
  (set-popup-rule! "^\\*haskell repl\\*" :ignore t :quit nil))

;; lsp
(after! lsp-mode
  (setq! read-process-output-max (* 1024 1024)
         lsp-auto-guess-root t
         lsp-signature-auto-activate nil
         lsp-enable-file-watchers nil
         lsp-enable-suggest-server-download nil
         lsp-lens-enable nil
         lsp-enable-symbol-highlighting nil))
(after! lsp-ui
  (setq lsp-ui-doc-enable nil)) ;; disable bc slow

;; company
(after! company
  (setq! company-minimum-prefix-length 1
         company-show-numbers t
         company-idle-delay 0.3 ;; disable automatic completion
         company-global-modes '(not erc-mode message-mode help-mode gud-mode))
  )


;; flycheck
(after! flycheck
  (setq! flycheck-global-modes '(not latex-mode LaTeX-mode org-mode)))

;; magit
(setq! magit-repository-directories '(("~/Notes/HHU" . 3)
                                      ("~/Notes/Org" . 0)
                                      ("~/Arch" . 0)
                                      ("~/NixFlake" . 0)
                                      ("~/Documents" . 1)
                                      ("~/Projects" . 2)
                                      ("~/NoSync" . 1))
       magit-repolist-columns '(("Name" 25 magit-repolist-column-ident nil)
                                ("Version" 25 magit-repolist-column-version nil)
                                ("N/U/S" 5 magit-repolist-column-flag
                                 ((:right-align t)
                                  (:help-echo "N: Untracked, U: Unstaged, S: Staged")))
                                ("Br<Up" 5 magit-repolist-column-unpulled-from-upstream
                                 ((:right-align t)
                                  (:help-echo "Upstream changes not in branch")))
                                ("Br>Up" 5 magit-repolist-column-unpushed-to-upstream
                                 ((:right-align t)
                                  (:help-echo "Local changes not in upstream")))
                                ("Path" 99 magit-repolist-column-path nil)))

;; treemacs
(after! treemacs
  (setq! treemacs-follow-after-init t
         treemacs-project-follow-mode t
         treemacs-follow-mode t
         treemacs-filewatch-mode t
         ;; treemacs-git-mode 'extended ;; always prompts?
         ;; treemacs-git-integration t
         treemacs-collapse-dirs 0
         treemacs-silent-refresh t
         treemacs-change-root-without-asking t
         treemacs-sorting 'alphabetic-case-insensitive-desc
         treemacs-show-hidden-files nil
         treemacs-never-persist nil
         treemacs-is-never-other-window nil
         treemacs-displacurrent-project-exclusively t
         ))
(add-hook! 'treemacs-mode-hook 'treemacs-follow-mode)
(add-hook! 'treemacs-mode-hook 'treemacs-project-follow-mode)
;; (add-hook! 'treemacs-mode-hook 'treemacs-fringe-indicator-mode)
