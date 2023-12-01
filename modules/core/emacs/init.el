;;; init.el --- hakanssn's custom emacs config  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(when (< emacs-major-version 29)
  (error (format "Emacs config only works with Emacs 29 and newer; you have version ~a" emacs-major-version)))

(defvar hk/config-dir (or (getenv "HK_CONFIG_DIR") "~/.config/emacs/") "Location off init.el.")
(defvar hk/data-dir (concat (or (getenv "XDG_DATA_HOME") "~/.local/share") "/emacs/") "Location for data.")
(defvar hk/cache-dir (concat (or (getenv "XDG_CACHE_DIR") "~/.cache") "/emacs/") "Location for cache.")

(use-package emacs
  :ensure nil ;; Not a real package, but a place to collect global settings
  :init
  (setq user-mail-address "anton@hakanssn.com"
        user-full-name    "Anton Hakansson")

  ;; Hide menu bars and scroll for clean ui
  (unless (memq window-system '(mac ns))
    (menu-bar-mode -1))
  (when (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))
  (when (fboundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1))

  ;; Automatically reread from disk if the underlying file changes
  (setopt auto-revert-avoid-polling t)
  ;; Some systems don't do file notifications well; see
  ;; https://todo.sr.ht/~ashton314/emacs-bedrock/11
  (setopt auto-revert-interval 5)
  (setopt auto-revert-check-vc-info t)
  (setopt auto-revert-verbose t)
  (setopt global-auto-revert-non-file-buffers t) ; Revert Dired and other buffers
  (global-auto-revert-mode)

  ;; Save history of minibuffer
  (savehist-mode)

  ;; Fix archaic defaults
  (setopt sentence-end-double-space nil)

  ;; Prefer utf-8 whenever possible
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)

  ;; Scrolling & cursor
  (pixel-scroll-precision-mode)                       ; Smooth scrolling
  (blink-cursor-mode -1)                              ; Steady cursor
  (push '(vertical-scroll-bars) default-frame-alist)  ; Remove vertical scroll bar
  (setopt mouse-wheel-progressive-speed nil)          ; don't accelerate scrolling

  ;; Buffers, Lines, and indentation
  (setopt display-line-numbers-type 'relative)  ; Relative line numbers
  (setopt indent-tabs-mode nil)                 ; Use spaces instead of tabs
  (setopt tab-width 2)
  (setopt x-underline-at-descent-line nil)   ; Prettier underlines
  (setopt show-trailing-whitespace nil)      ; By default, don't underline trailing spaces
  (setopt indicate-buffer-boundaries 'left)  ; Show buffer top and bottom in the margin
  (setopt switch-to-buffer-obey-display-actions t)   ; Make switching buffers more consistent

  (add-hook 'after-init-hook #'recentf-mode)  ; Turn on recentf mode

  ;; Misc. Emacs tweaks
  (fset 'yes-or-no-p 'y-or-n-p) ; Shorter confirmation
  (setopt isearch-lazy-count t)
  (setopt delete-by-moving-to-trash t)
  (setopt set-mark-command-repeat-pop t) ;; after =C-u C-SPC=, keep ctrl down and press space to cycle mark ring
  (setopt bookmark-save-flag 1)  ; Write bookmark file when bookmark list is modified

  ;; Keybinds
  (global-set-key (kbd "<f1>") 'shell)
  (global-set-key (kbd "<f5>") 'recompile)
  (global-set-key (kbd "<f7>") 'scroll-lock-mode)
  (global-set-key (kbd "C-t") 'hippie-expand) ;; orig. transpose-chars
  (global-set-key (kbd "M-p") 'backward-paragraph)
  (global-set-key (kbd "M-n") 'forward-paragraph)
  (keymap-set global-map "<remap> <list-buffers>" 'ibuffer) ;; C-x C-b

  ;; C-w terminal behavior
  (defun backward-kill-word-or-region (&optional arg)
    (interactive "p")
    (if (region-active-p)
        (call-interactively #'kill-region)
      (backward-kill-word arg)))
  (global-set-key (kbd "C-w")  'backward-kill-word-or-region)

  ;; ediff
  (setopt ediff-make-buffers-readonly-at-startup nil)
  (setopt ediff-split-window-function 'split-window-horizontally)
  (setopt ediff-window-setup-function 'ediff-setup-windows-plain)

  ;; Fleeting notes in Scratch Buffer
  (setq initial-major-mode 'org-mode
        initial-scratch-message "#+title: Scratch Buffer\n\nFor random thoughts.\n\n")

  ;; Tab bar
  (setopt tab-bar-show 1)

  ;; Theme - modus operandi
  (setopt modus-themes-mixed-fonts t)
  (setopt modus-themes-headings
      '((1 . (variable-pitch 1.3))
        (2 . (1.1))
        (agenda-date . (1.1))
        (agenda-structure . (variable-pitch light 1.3))
        (t . (1.1))))
  (setopt modus-operandi-tinted-palette-overrides
        '((bg-main "#f4e6cd"))) ; Sepia backround color. Original too harsh for my poor eyes.
  )

(use-package diminish
  ;; Dependencies that inject `:keywords' into `use-package' should be
  ;; included before all other packages.
  ;; For :diminish in (use-package). Hides minor modes from the status line.
  )

(use-package no-littering
  ;; Put emacs files in ~/.cache/emacs/
  :custom
  (user-emacs-directory (expand-file-name "~/.cache/emacs/") "Don't put files into .emacs.d")
  (no-littering-etc-directory hk/data-dir)
  (no-littering-var-directory hk/cache-dir)
  :config
  ;; Don't create lockfiles
  (setq create-lockfiles nil) ;; #readme.txt#
  (setq make-backup-files nil) ;; readme.txt~
  (setq custom-file (concat no-littering-etc-directory "custom.el"))
  ;; Also make sure auto-save files are saved out-of-tree
  (setq auto-save-file-name-transforms `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Discovery aids
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package which-key
  :diminish
  :config
  (which-key-mode))

(use-package helpful
  ;; Make default `describe-*' screens more helpful
  :bind (([remap describe-command]  . #'helpful-command)
         ([remap describe-function] . #'helpful-callable)
         ([remap describe-key]      . #'helpful-key)
         ([remap describe-symbol]   . #'helpful-symbol)
         ([remap describe-variable] . #'helpful-variable)
         ("C-c C-d" . #'helpful-at-point)
         ("C-h F"   . #'helpful-function)
         ("C-h K"   . #'helpful-keymap)))

(use-package consult
  :bind
  (
   ;; C-c bindings (mode-specific-map)
   ("C-c h" . 'consult-history)
   ("C-c m" . 'consult-mode-command)
   ("C-c k" . 'consult-kmacro)
   ;; C-x bindings (ctl-x-map)
   ("C-x M-:" . 'consult-complex-command)     ; orig. repeat-complex-command
   ("C-x b"   . 'consult-buffer)              ; orig. switch-to-buffer
   ("C-x r b" . 'consult-bookmark)            ; orig. bookmark-jump
   ("C-x p b" . 'consult-project-buffer)      ; orig. project-switch-to-buffer
   ;; Other custom bindings
   ("M-y" . 'consult-yank-pop)                ; orig. yank-pop
   ;; M-g bindings (goto-map)
   ("M-g e" . 'consult-compile-error)
   ("M-g f" . 'consult-flymake)               ; Alternative: consult-flycheck
   ("M-g g" . 'consult-goto-line)             ; orig. goto-line
   ("M-g M-g" . 'consult-goto-line)           ; orig. goto-line
   ("M-g o" . 'consult-outline)               ; Alternative: consult-org-heading
   ("M-g k" . 'consult-global-mark)
   ("M-g i" . 'consult-imenu)
   ("M-g I" . 'consult-imenu-multi)
   ;; M-s bindings (search-map)
   ("M-s d" . 'consult-find)
   ("M-s g" . 'consult-grep)
   ("M-s G" . 'consult-git-grep)
   ("M-s r" . 'consult-ripgrep)
   ("M-s l" . 'consult-line)
   ("M-s L" . 'consult-line-multi)
   ("M-s k" . 'consult-keep-lines)
   ;; Isearch integration
   ("M-s e" . 'consult-isearch-history)
   :map isearch-mode-map
  ("M-e" . 'consult-isearch-history)         ; orig. isearch-edit-string
   ("M-s e" . 'consult-isearch-history)       ; orig. isearch-edit-string
   ("M-s l" . 'consult-line)                  ; needed by consult-line to detect isearch
   ("M-s L" . 'consult-line-multi)            ; needed by consult-line to detect isearch
   ;; Minibuffer history
   :map minibuffer-local-map
   ("M-s" . 'consult-history)                 ;; orig. next-matching-history-element
   ("M-r" . 'consult-history)                 ;; orig. previous-matching-history-element
   ("C-r" . 'consult-history))
  :init
  (require 'consult-imenu)
  (require 'consult-org)
  (require 'consult-flymake)
  (require 'consult-compile)
  (require 'consult-kmacro))

(use-package embark
  :after avy
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  (defun bedrock/avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  ;; After invoking avy-goto-char-timer, hit "." to run embark at the next
  ;; candidate you select
  (setf (alist-get ?. avy-dispatch-alist) 'bedrock/avy-action-embark)
  )

(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Motion aids
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package avy
  :bind
  (("C-c n" . avy-goto-word-1))
  :config
  (setq avy-keys '(?a ?r ?s ?t ?n ?e ?i ?o ?d ?h))
  (global-set-key (kbd "C-,") 'avy-goto-char-timer))

(use-package crux
  ;; Collection of Ridiculously Useful eXtensions
  :bind
  (("M-o" . 'crux-other-window-or-switch-buffer)
   ("C-a" . 'crux-move-beginning-of-line)))

(use-package meow
  ;; Modal editing
  :custom
  (meow-use-clipboard 't)
  (meow-use-enhanced-selection-effect 't "i don't know what this does - let's try it out")
  (meow-goto-line-function #'consult-goto-line)
  (meow-replace-state-name-list '((normal . "N")
                            (motion . "M")
                            (keypad . "K")
                            (insert . "I")
                            (beacon . "B")))
  :config
  ;; (setq meow-cheatsheet-layout meow-cheatsheet-layout-colemak-dh)

  (meow-motion-overwrite-define-key
   ;; Use e to move up, n to move down.
   ;; Since special modes usually use n to move down, we only overwrite e here (Colemak-Dh).
   '("e" . meow-prev)
   '("<escape>" . ignore))

  ;; Expansion
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("1" . meow-expand-1)
   '("2" . meow-expand-2)
   '("3" . meow-expand-3)
   '("4" . meow-expand-4)
   '("5" . meow-expand-5)
   '("6" . meow-expand-6)
   '("7" . meow-expand-7)
   '("8" . meow-expand-8)
   '("9" . meow-expand-9))

  ;; Movement
  ;; REVIEW: have a keyboard layer for navigating horizontally by character (mi on colemak-dh) and rebind keys for something useful
  (meow-normal-define-key
   '("n" . meow-next)
   '("N" . meow-next-expand)
   '("e" . meow-prev)
   '("E" . meow-prev-expand)
   '("m" . meow-left)
   '("M" . meow-left-expand)
   '("i" . meow-right)
   '("I" . meow-right-expand)
   '("w" . meow-next-word)
   '("W" . meow-next-symbol)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("/" . meow-visit)
   '("!" . shell-command)
   '("$" . jinx-correct)
   '("M-$" . jinx-next)
   '("%" . meow-query-replace)
   '("(" . previous-buffer)
   '(")" . next-buffer)
   '("f" . meow-find)
   '("F" . meow-find-expand)
   '("t" . meow-till)
   '("T" . meow-till-expand)
   '("L" . meow-goto-line))

  (meow-normal-define-key
   '("-" . negative-argument)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("j" . meow-join)
   '("k" . meow-kill)
   '("l" . meow-line)
   '("h" . meow-mark-word)
   '("H" . meow-mark-symbol)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-insert)
   '("S" . meow-open-above)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-search)
   '("x" . meow-delete)
   '("X" . meow-backward-delete)
   '("y" . meow-save)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore))

  (meow-leader-define-key
   ;; m -> M-
   ;; g -> C-M-
   ;; x / h / c -> C-x / C-h / C-c

   ;; Emacs general
   '("SPC" . execute-extended-command)
   '("t t" . visual-line-mode)
   '("t l" . global-display-line-numbers-mode)
   '("t k" . kill-this-buffer)
   '("s" . "M-s")
   '("d" . dirvish)

   ;; Files & buffer
   '("f f" . find-file)
   '("r"   . consult-recent-file)
   '("f o" . find-file-other-window)
   '("f R" . rename-file)
   '("b"   . consult-buffer)
   '("TAB" . previous-buffer)

   ;; Windows
   '("w w" . clone-frame)
   '("w /" . split-window-right)
   '("w d" . delete-window)

   ;; Project
   '("P"    . "C-x p")
   '("p p"	.	project-switch-project)
   '("p b"	.	consult-project-buffer)
   '("p c"	.	project-compile)
   '("p b"	.	project-swith-buffer)
   '("p f"	.	project-find-file)
   '("p q"	.	project-query-replace-regexp)
   '("p s"	.	consult-ripgrep)

   ;; Applications
   '("o e" . elfeed)
   '("o a" . org-agenda)
   '("A" . consult-org-agenda)

   ;; meow
   '("?" . meow-cheatsheet)
   '("e" . "H-e") ;; To execute original e in MOTION state, use SPC e.
   '("'" . (lambda () (interactive) (if (meow-normal-mode-p) (meow-motion-mode +1) (meow-normal-mode +1))))
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument))

  ; Register HTML tag as a meow object/thing
  (meow-thing-register 'angle '(regexp "<" ">") '(regexp "<" ">"))
  (add-to-list 'meow-char-thing-table '(?a . angle))

  (meow-global-mode 1))

(use-package hydra)

(use-package dumb-jump
  :bind
  (("C-c j" . hk/dumb-jump-hydra/body))
  :commands dumb-jumb-go
  :config
  (defhydra hk/dumb-jump-hydra (:color blue :columns 3)
    "Dumb Jump"
    ("j" dumb-jump-go "Go")
    ("o" dumb-jump-go-other-window "Other window")
    ("e" dumb-jump-go-prefer-external "Go external")
    ("x" dumb-jump-go-prefer-external-other-window "Go external other window")
    ("i" dumb-jump-go-prompt "Prompt")
    ("l" dumb-jump-quick-look "Quick look")
    ("b" dumb-jump-back "Back"))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer/completion settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vertico
  ;; Vertical UI
  ;; Completion in minibuffer
  :config
  (vertico-mode))

(use-package marginalia
  ;; Rich annotations in minibuffer
  :config
  (marginalia-mode))

(use-package orderless
  ;; Advanced completion style (better fuzzy matching)
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package corfu
  ;; Completion in buffer (popup ui)
  :custom
  (corfu-auto t "Enable Auto Completion")
  (corfu-auto-delay 0 "Disable completion suggestion delay")
  (corfu-auto-prefix 1 "Trigger completion early")
  :bind
  (:map corfu-map
        ("RET" . nil) ;; return should insert a newline - not complete the sugggestion.
        ("<escape>" . (lambda ()
                        (interactive)
                        (corfu-quit)
                        (meow-normal-mode))))
  :config
  (require 'corfu-info)

  ;; Don't auto-complete in shell modes
  (add-hook 'shell-mode-hook
          (lambda ()
            (setq-local corfu-auto nil)
            (corfu-mode)))

  (global-corfu-mode))

(use-package cape
  ;; Cape for better completion-at-point support and more
  :config
  (setq cape-dabbrev-check-other-buffers t
        dabbrev-ignored-buffer-regexps
        '("\\.\\(?:pdf\\|jpe?g\\|png\\|svg\\|eps\\)\\'"
          "^ "
          "\\(TAGS\\|tags\\|ETAGS\\|etags\\|GTAGS\\|GRTAGS\\|GPATH\\)\\(<[0-9]+>\\)?")
        dabbrev-upcase-means-case-search t)

  ;; Add useful defaults completion sources from cape
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block) ;; Complete in org, markdown code block
  (defalias 'cape-dabbrev-min-3 (cape-capf-prefix-length #'cape-dabbrev 3))
  (add-to-list 'completion-at-point-functions #'cape-dabbrev-min-3)
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Notes (org-mode, etc)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(use-package denote
  :custom
  (denote-directory (concat org-directory "denote/"))
  (denote-known-keywords '("emacs" "philosophy" "pol" "compsci" "cc"))
  :bind
  (("C-c C-n" . denote)
   ("C-c o n" . denote-open-or-create)
   ("C-c o N" . hk/diary))
  :config
  (defun hk/diary ()
    "Create an entry tagged 'diary' with the date as its title.
If a diary for the current day exists, visit it.  If multiple
entries exist, prompt with completion for a choice between them.
Else create a new file."
    (interactive)
    (let* ((today (format-time-string "%A %e %B %Y"))
           (string (denote-sluggify today))
           (files (denote-directory-files-matching-regexp string)))
      (cond
       ((> (length files) 1)
        (find-file (completing-read "Select file: " files nil :require-match)))
       (files
        (find-file (car files)))
       (t
        (denote
         today
         '("diary"))))))
  )

(use-package htmlize)
(use-package gnuplot)
(require 'gnuplot-context) ; org mode error: run-hooks: Symbol’s function definition is void: gnuplot-context-sensitive-mode

(use-package org
  :init
  (defun hk/org-syntax-convert-keyword-case-to-lower ()
    "Convert all #+KEYWORDS to #+keywords."
    (interactive)
    (save-excursion
      (goto-char (point-min))
      (let ((count 0)
            (case-fold-search nil))
        (while (re-search-forward "^[ \t]*#\\+[A-Z_]+" nil t)
          (unless (s-matches-p "RESULTS" (match-string 0))
            (replace-match (downcase (match-string 0)) t)
            (setq count (1+ count))))
        (message "Replaced %d occurances" count))))

  (defun hk/insert-org-from-html-clipboard ()
    "Insert html from clipboard and convert into org-mode using pandoc."
    ;; credits to u/jsled
    (interactive)
    (let* ((not-nil-and-not-a-buffer-means-current-buffer 1)
           (dst-buffer not-nil-and-not-a-buffer-means-current-buffer)
           (command "wl-paste | pandoc -f html -t org"))
      (shell-command command dst-buffer)))

  (defun hk/insert-org-from-leetcode ()
    "Insert org-mode formatted leetcode problem from url."
    (interactive)
    (let* ((not-nil-and-not-a-buffer-means-current-buffer 1)
           (dst-buffer not-nil-and-not-a-buffer-means-current-buffer)
           (leetcode-url (read-from-minibuffer "Leetcode slug: "))
           (command (concat "leetcode-to-org-mode.py " leetcode-url)))
      (shell-command command dst-buffer)))
  :bind
  (("C-c a"  . org-agenda)
   ("C-c c"  . org-capture)
   ("C-c l"  . org-store-link))
  :custom
  (org-babel-load-languages '((awk . t)
                              (calc . t)
                              (C . t)
                              (clojure . t)
                              (css . t)
                              (dot . t)
                              (emacs-lisp . t)
                              (forth . t)
                              (fortran . t)
                              (gnuplot . t)
                              (haskell . t)
                              (js . t)
                              (latex . t)
                              (lisp . t)
                              (makefile . t)
                              (org . t)
                              (perl . t)
                              (plantuml . t)
                              (python . t)
                              (ruby . t)
                              (sass . t)
                              (scheme . t)
                              (shell . t)
                              (sql . t)
                              (sqlite . t)))
  (calendar-date-style 'european)
  (org-use-speed-commands
   (lambda () (and (looking-at org-outline-regexp) (looking-back "^\\**")))) ;  when point is on any star at the beginning of the headline
  (org-babel-results-keyword "results" "Make babel results blocks lowercase")
  (org-log-into-drawer 't "instert state changes into a drawer LOGBOOK")
  (org-refile-targets '((nil :maxlevel . 9)
                        (org-agenda-files :maxlevel . 3)))
  (org-refile-use-outline-path 't "Show full outline of target")
  :config
  (setq org-directory "~/documents/org/"
        org-agenda-files '("~/documents/org/gtd/")
        org-return-follows-link t
        org-deadline-warning-days 30
        org-startup-indented t
        org-agenda-window-setup 'current-window
        org-log-done 'time
        org-fold-catch-invisible-edits 'smart
        org-confirm-babel-evaluate nil
        ;; Task Management
        org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n!)" "|" "DONE(d)")
          (sequence "WAIT(w@/!)" "|" "CANCELLED(c@/!)"))
        org-capture-templates
        '(("t" "Todo [inbox]" entry (file "gtd/inbox.org")
           "* TODO %?\n:PROPERTIES:\n:ENTERED_ON: %U\n:END:\n%i\n")
          ("T" "Tickler" entry
           (file "gtd/repeaters.org")
           "* %i%? \n %U")
          ("a" "Anki Basic" entry (file+headline "anki.org" "Scratch")
           "* %<%H:%M>\n:PROPERTIES:\n:ANKI_NOTE_TYPE: Basic\n:ANKI_DECK: Mega\n:END:\n** Front\n%?\n** Back\n")
          ("w" "Web" entry (file "gtd/inbox.org")
           "* TODO %? [[%:link][%:description]] :ref:\n:PROPERTIES:\n:ENTERED_ON: %U\n:END:\n\n#+begin_quote\n%i\n#+end_quote\n")
          )
        org-agenda-custom-commands
        '(("g" "Get Things Done (GTD)"
           ((agenda "" (;; Show today
                        (org-agenda-span 1)
                        ))
            (todo "NEXT" ((org-agenda-overriding-header "Next:")))
            (todo "WAIT" ((org-agenda-overriding-header "Waiting on:")))
            (tags-todo "inbox" ((org-agenda-overriding-header "Inbox:")))
            (tags-todo "project//TODO" ((org-agenda-overriding-header "Projects:")))
            (tags "CLOSED>=\"<today>\"" ((org-agenda-overriding-header "Completed today:")))
            ))))
  (define-key org-src-mode-map "\C-c\C-v" 'org-src-do-key-sequence-at-code-block)

  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.8)) ;; increase scale of latex fragments
  )

(use-package org-protocol
  :ensure nil)

(use-package org-habit
  :ensure nil
  :after org
  :config
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-show-habits t
        org-habit-following-days 7
        org-habit-preceding-days 21))

(use-package anki-editor
  :defer 5
  :bind (:map org-mode-map
              ("<f12>" . anki-editor-cloze-region-dont-incr)
              ("<f11>" . anki-editor-cloze-region-auto-incr)
              ("<f10>" . anki-editor-reset-cloze-number)
              ("<f9>"  . anki-editor-push-tree))
  :hook (org-capture-after-finalize . anki-editor-reset-cloze-number) ; Reset cloze-number after each capture.
  :preface
  (defun anki-editor-cloze-region-auto-incr (&optional arg)
    "Cloze region without hint and increase card number."
    (interactive)
    (anki-editor-cloze-region my-anki-editor-cloze-number "")
    (setq my-anki-editor-cloze-number (1+ my-anki-editor-cloze-number))
    (forward-sexp))
  (defun anki-editor-cloze-region-dont-incr (&optional arg)
    "Cloze region without hint using the previous card number."
    (interactive)
    (anki-editor-cloze-region (1- my-anki-editor-cloze-number) "")
    (forward-sexp))
  (defun anki-editor-reset-cloze-number (&optional arg)
    "Reset cloze number to ARG or 1"
    (interactive)
    (setq my-anki-editor-cloze-number (or arg 1)))
  (defun anki-editor-push-tree ()
    "Push all notes under a tree."
    (interactive)
    (anki-editor-push-notes '(4))
    (anki-editor-reset-cloze-number))

  :config
  (setq anki-editor-create-decks t
        anki-editor-org-tags-as-anki-tags t)

  ;; Org-capture templates
  (setq hk/org-anki-file "~/documents/org/anki.org")
  (add-to-list 'org-capture-templates
               '("a" "Anki basic"
                 entry
                 (file+headline hk/org-anki-file "Scratch")
                 "* %<%H:%M>   %^g\n:PROPERTIES:\n:ANKI_NOTE_TYPE: Basic\n:ANKI_DECK: Mega\n:END:\n** Front\n%?\n** Back\n%x\n"))
  (add-to-list 'org-capture-templates
               '("A" "Anki cloze"
                 entry
                 (file+headline hk/org-anki-file "Scratch")
                 "* %<%H:%M>   %^g\n:PROPERTIES:\n:ANKI_NOTE_TYPE: Cloze\n:ANKI_DECK: Mega\n:END:\n** Text\n%x\n** Extra\n"))
  ;; Initialize
  (anki-editor-reset-cloze-number))

(use-package org-download)

(use-package org-web-tools)

(use-package org-appear
  :custom
  (org-appear-autosubmarkers t)
  (org-appear-autoentities t)
  (org-appear-autolinks t)
  (org-appear-autokeywords t))

(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode)
  :custom (org-startup-with-latex-preview t))

(use-package org-modern
  :hook
  (org-mode . global-org-modern-mode)
  :custom
  (org-modern-table nil))

(use-package laas
  :hook (LaTeX-mode . laas-mode)
  :hook (org-mode . laas-mode)
  :config
  (aas-set-snippets 'laas-mode
    ";m" (lambda () (interactive) (insert "\\(  \\)") (backward-char 3))
    ";M" (lambda () (interactive) (insert "\\[  \\]") (backward-char 3))
    :cond #'texmathp ; expand only while in math
    "O1" "O(1)"
    "On" "O(n)"
    "Olog" "O(\\log n)"
    "Olon" "O(n \\log n)"
    ;; add accent snippets
    :cond #'laas-object-on-left-condition
    "qq" (lambda () (interactive) (laas-wrap-previous-object "sqrt"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Misc. editing enhancements
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package tempel
  ;; Snippet
  :bind (("M-+" . #'tempel-complete)
         ("M-*" . #'tempel-insert))
  :custom
  (tempel-path "~/documents/org/tempel"))

(use-package embrace
  ;; Add/Change/Delete pairs based on expand-region.
  :bind (("M-)" . 'embrace-commander)) ;; orig. move-past-close-and-reindent
  :config
  (add-hook 'LaTeX-mode-hook 'embrace-LaTeX-mode-hook)
  (add-hook 'org-mode-hook 'embrace-org-mode-hook))

(use-package string-edit-at-point
  ;; Edit strings normally and get it escaped automatically
  )

(use-package poporg
  ;; Edit code comments in org-mode.
  :bind (("C-c /" . poporg-dwim)))

(use-package string-inflection
  :commands
  string-inflection-all-cycle
  string-inflection-toggle
  string-inflection-camelcase
  string-inflection-lower-camelcase
  string-inflection-kebab-case
  string-inflection-underscore
  string-inflection-capital-underscore
  string-inflection-upcase)

(use-package so-long
  ;; Performance mitigations for files with long lines.
  :config
  (global-so-long-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Version Control
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package magit
  :custom
  (magit-repository-directories '(("~/repos" . 2)))
  :bind
  (("C-c o m" . 'magit)))

(use-package magit-todos
  ;; Show TODOs (and FIXMEs, etc) in Magit status buffer
  :after magit
  :hook (magit-mode . magit-todos-mode))

(use-package forge
  ;; Forge allows you to work with Git forges, such as Github and Gitlab, from the comfort of Magit and the rest of Emacs.
  :after magit)

(use-package git-gutter
  :diminish
  :bind
  (("C-c g n" . #'git-gutter:next-hunk)
   ("C-c g p" . #'git-gutter:previous-hunk)
   ("C-c g d" . #'git-gutter:popup-hunk)
   ("C-c g s" . #'git-gutter:stage-hunk)
   ("C-c g k" . #'git-gutter:revert-hunk))
  :custom
  ;; Only show color to indicate hunks
  (git-gutter:added-sign " ")
  (git-gutter:deleted-sign " ")
  (git-gutter:modified-sign " ")
  :config
  (global-git-gutter-mode +1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Developer and IDE config
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package ws-butler
  ;; Whitespace is evil.  Let's get rid of as much as possible.  But we
  ;; don't want to do this with files that already had whitespace (from
  ;; someone else's project, for example).  This mode will call
  ;; `whitespace-cleanup' before buffers are saved (but smartly)!
  :diminish
  :hook
  ((text-mode prog-mode) . ws-butler-mode)
  :custom
  (ws-butler-keep-whitespace-before-point nil))

(use-package editorconfig
  :after ws-butler
  :config
  (setq editorconfig-trim-whitespaces-mode 'ws-butler-mode))


(use-package emacs
  ;; Prefer Treesitter
  :config
  (setq major-mode-remap-alist
        '((bash-mode . bash-ts-mode)
          (python-mode . python-ts-mode)
          (json-mode . json-ts-mode)
          (c-mode . c-ts-mode)
          )))

(use-package eglot
  :hook
  (nix-mode . eglot)
  (c-mode-common . eglot)
  :bind
  (:map eglot-mode-map
        ("C-c C" . eglot)
        ("C-c A" . eglot-code-actions)
        ("C-c R" . eglot-rename)
        ("M-r"   . eglot-rename)
        ("C-c F" . eglot-format))
  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)              ; activate Eglot in referenced non-project files
  :config
  (fset #'jsonrpc--log-event #'ignore)  ; massive perf boost---don't log every event

  ;; Eglot sometimes needs to know where to find language servers
  (add-to-list
   'eglot-server-programs
   '((c-mode c-ts-mode c++-mode c++-ts-mode) "clangd" "--clang-tidy" "--completion-style=detailed"))
  (add-to-list
   'eglot-server-programs '(nix-mode . ("nil")))
  )

(use-package citre
  ;; ctags - useful if lsp is not available
  :custom
  (citre-default-create-tags-file-location 'global-cache)
  (citre-use-project-root-when-creating-tags t)
  (citre-tags-completion-case-sensitive nil)
  )

(use-package envrc
  :config
  (envrc-global-mode))

(use-package nix-mode :mode (("\\.nix\\'" . nix-mode)))

(use-package emacs
  ;; c-mode config
  :config
  (setopt c-basic-offset 2)
  (defun hk/c-mode-hook ()
    (c-set-offset 'substatement 0)
    (c-set-offset 'substatement-open 0)
    (setq-local outline-regexp " *//\\(-+\\)")
    )
  (add-hook 'c-mode-hook 'hk/c-mode-hook)
  (add-hook 'c-ts-mode-hook 'hk/c-mode-hook)
  )

(use-package zig-mode)

(use-package web-mode
  ;; Web (html/css/javascript)
  :mode (("\\.html?\\'" . web-mode))
  :custom
  (web-mode-attr-indent-offset 2)
  (web-mode-block-padding 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2)
  (web-mode-comment-style 2)
  (web-mode-enable-current-element-highlight t)
  (web-mode-markup-indent-offset 2))

(use-package emmet-mode
  ;; Expand html templates
  :hook ((web-mode . emmet-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Applications and tools
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package dirvish
  ;; File manager
  :custom
  (dirvish-quick-access-entries
   '(("h" "~/"                          "Home")
     ("d" "~/downloads/"                "Downloads")
     ("m" "~/mpv/"                      "Mpv")
     ("t" "~/.local/share/Trash/files/" "TrashCan")
     ("r" "~/repos/"                    "Repos")
     ("b" "~/documents/books/"          "Books")
     ("a" "~/documents/books/audio"     "Audio Books")
     ("o" "~/documents/org/"            "Org Notes")))
  (dirvish-default-layout nil "disable preview pane by default")
  (dired-dwim-target t "copy/move operations based on other Dired window")
  (delete-by-moving-to-trash t)
  (dired-mouse-drag-files t "enable drag-and-drop")
  (mouse-drag-and-drop-region-cross-program t)
  (dired-listing-switches
        "-l --almost-all --human-readable --group-directories-first --no-group")
  :bind
  (:map dirvish-mode-map
        ("a"   . 'dirvish-quick-access)
        ("TAB" . 'dirvish-subtree-toggle)
        ("T"   . 'dirvish-layout-toggle)) ; Orig. dired-do-touch
  :config
  (setq dirvish-mode-line-format
        '(:left (sort symlink) :right (omit yank index)))
  (setq dirvish-attributes
        '(nerd-icons file-time file-size collapse subtree-state vc-state git-msg))
  (setq dirvish-preview-dispatchers (delete 'pdf dirvish-preview-dispatchers)) ; Remove pdf preview. It is too slow.
  (dirvish-override-dired-mode)
  (require 'dirvish-quick-access)
  (require 'dirvish-extras)
  )

(use-package eww
  ;; Web browser
  :ensure nil
  :bind
  (:map eww-mode-map
        ("M-n" . nil)
        ("M-p" . nil)
        ("I" . #'hk/eww-toggle-images))
  :config
  ;; Use & to open externally if eww can't handle the page
  (setq browse-url-browser-function #'eww-browse-url)
  (setq browse-url-generic-program "firefox")

  (defun hk/eww-toggle-images ()
    "Toggle whether images are loaded and reload the current page."
    (interactive)
    (setq-local shr-inhibit-images (not shr-inhibit-images))
    (eww-reload t)
    (message "Images are now %s"
             (if shr-inhibit-images "off" "on")))
  )

(use-package pdf-tools)

(use-package devdocs
  :bind (("C-c D" . 'devdocs-lookup))
  :custom
  (devdocs-data-dir (concat hk/cache-dir "devdocs/")))

(use-package elfeed
  ;; rss reader
  :custom
  (elfeed-sort-order 'ascending)
  :config
  (setq-default elfeed-search-filter "@6-months-ago +unread +mustread"))

(use-package elfeed-org
  ;; Load rss feeds from org file
  :after elfeed
  :config
  (setq rmh-elfeed-org-files (list (concat org-directory "elfeed.org")))
  (elfeed-org)) ;; hook up elfeed-org to read the configuration when elfeed starts

(use-package elfeed-tube
  :after elfeed
  :preface
  (defun hk/mpv-play-url-at-point ()
    "Open the URL at point in mpv."
    (interactive)
    (let ((url (thing-at-point-url-at-point)))
      (when url
        (async-shell-command (concat "umpv \"" url "\"") nil nil))))
  :bind
  (:map elfeed-show-mode-map
        ("F" . elfeed-tube-fetch)
        ([remap save-buffer] . elfeed-tube-save)
        ("C-o" . elfeed-tube-mpv)
        :map elfeed-search-mode-map
        ("F" . elfeed-tube-fetch)
        ([remap save-buffer] . elfeed-tube-save))
  :config
  (elfeed-tube-setup))

(use-package elfeed-tube-mpv
  :bind
  (:map elfeed-show-mode-map
        ("C-c C-f" . elfeed-tube-mpv-follow-mode)
        ("C-c C-w" . elfeed-tube-mpv-where)))

(use-package mu4e
  :ensure nil
  :custom
  (mu4e-change-filenames-when-moving t "Avoid sync issues with mbsync")
  (mu4e-maildir "~/mail/" "Root of the maildir hierarchy")
  (mu4e-attachment-dir "~/downloads/" "Save attachments to downloads folder")
  (mu4e-compose-dont-reply-to-self t "Don't reply to myself on reply to all")
  (mu4e-change-filenames-when-moving t "Avoid sync issues with mbsync")
  (message-send-mail-function 'message-send-mail-with-sendmail)
  (sendmail-program "msmtp" "Use msmtp to send mail")
  (message-cite-reply-position 'below "Put reply below quoted text")
  :config
  (setq mail-user-agent 'mu4e-user-agent)
  (setq mu4e-contexts `(,(make-mu4e-context :name "Personal"
                                            :match-func (lambda (msg)
                                                          (when msg
                                                            (string-prefix-p "/personal" (mu4e-message-field msg :maildir))))
                                            :vars '((user-mail-address . "anton@hakanssn.com")
                                                    (user-full-name . "Anton Hakansson")
                                                    (mu4e-trash-folder . "/personal/Trash")
                                                    (mu4e-sent-folder . "/personal/Sent")
                                                    (mu4e-drafts-folder . "/personal/Drafts")
                                                    (mu4e-refile-folder . "/personal/Trash")
                                                    (message-sendmail-extra-arguments . ("--read-envelope-from" "--account" "personal"))))
                        ,(make-mu4e-context :name "Gmail"
                                            :match-func (lambda (msg)
                                                          (when msg
                                                            (string-prefix-p "/gmail" (mu4e-message-field msg :maildir))))
                                            :vars '((user-mail-address . "anton.hakansson98@gmail.com")
                                                    (user-full-name . "Anton Hakansson")
                                                    (mu4e-trash-folder . "/gmail/[Gmail]/Trash")
                                                    (mu4e-sent-folder . "/gmail/[Gmail]/Sent Mail")
                                                    (mu4e-drafts-folder . "/gmail/[Gmail]/Drafts")
                                                    (mu4e-refile-folder . "/gmail/[Gmail]/All Mail")
                                                    (message-sendmail-extra-arguments . ("--read-envelope-from" "--account" "gmail")))))))


(defun hk/run-tgpt ()
  "Open shell and run the program 'tgpt' in interactive mode."
  (interactive)
  (shell "tgpt")
  (insert "tgpt -i")
  (comint-send-input))

(use-package jinx
  ;; Enchaned Spell Checker
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Appearance
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 20)
  (doom-modeline-minor-modes t)
  (doom-modeline-percent-position nil)
  (doom-modeline-battery nil)
  (doom-modeline-time nil))

(use-package popper
  ;; Pop-up window management
  :commands (popper-mode)
  :hook (emacs-startup . popper-mode)
  :bind (("C-'"   . popper-toggle)
         ("M-'"   . popper-cycle)         ;; Orig. abbrev-prefix-mark
         ("C-M-'" . popper-toggle-type))
  :custom (popper-mode-line nil "hide modeline in popup windows")
  :config
  (setq popper-reference-buffers
        '(
          ;; help modes
          help-mode
          helpful-mode
          eldoc-mode
          "\\*eldoc\\*"
          Man-mode
          woman-mode
          ;; repl modes
          eshell-mode
          shell-mode
          ;; grep modes
          occur-mode
          grep-mode
          xref--xref-buffer-mode
          rg-mode
          ;; message modes
          compilation-mode
          "\\*Messages\\*"
          "[Oo]utput\\*"
          "\\*Async Shell Command\\*"))
  (setq popper-group-function 'popper-group-by-project)
  (popper-mode +1)
  (require 'popper-echo)
  (popper-echo-mode +1))

(use-package mixed-pitch
  :hook (org-mode . mixed-pitch-mode))

(use-package nerd-icons)

(use-package ef-themes
  :custom
  (custom-safe-themes
   '("14ba61945401e42d91bb8eef15ab6a03a96ff323dd150694ab8eb3bb86c0c580"
     "ccb2ff53e9794d059ff941fabcf265b67c8418da664db8c4d6a3d656962b7135"
     default))
  (ef-themes-mixed-fonts t)
  (ef-themes-headings
   '((1 . (variable-pitch 1.3))
     (2 . (1.1))
     (agenda-date . (1.1))
     (agenda-structure . (variable-pitch light 1.3))
     (t . (1.1))))
  :config
  (load-theme 'ef-light))

(use-package spacious-padding
  :config
  (spacious-padding-mode +1))

(use-package olivetti
  ;; Center text for nicer writing and reading
  :defer 3
  :bind (("C-c t z" . olivetti-mode))
  :config
  (setq-default olivetti-body-width 120
                fill-column 90))

(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode)
  :diminish)

(use-package fancy-compilation
  ;; Support color, progress bars in compilation-mode buffer
  :commands (fancy-compilation-mode)
  :custom (fancy-compilation-override-colors nil)
  :config
  (with-eval-after-load 'compile
    (fancy-compilation-mode)))

(provide 'init)
;;; init.el ends here

;; Local Variables:
;; outline-regexp: "\(use-package.*"
;; End:
