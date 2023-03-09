;;; init.el --- hakanssn's custom emacs config  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(eval-when-compile
  (require 'use-package)
  (require 'use-package-ensure)
  (setq use-package-verbose nil)
  (setq use-package-always-ensure t))

(defvar hk/config-dir (or (getenv "HK_CONFIG_DIR") "~/.config/emacs/") "Location off init.el.")
(defvar hk/data-dir (concat (or (getenv "XDG_DATA_HOME") "~/.local/share") "/emacs/") "Location for data.")
(defvar hk/cache-dir (concat (or (getenv "XDG_CACHE_DIR") "~/.cache") "/emacs/") "Location for cache.")

;; Dependencies that inject `:keywords' into `use-package' should be
;; included before all other packages.
;; For :diminish in (use-package). Hides minor modes from the status line.
(use-package diminish)

;;; Defaults
(use-package emacs
  :ensure nil ;; Not a real package, but a place to collect global settings
  :init
  (setq user-mail-address "anton@hakanssn.com"
        user-full-name "Anton Hakansson")

  ;; Auto revert buffers
  (customize-set-variable 'global-auto-revert-non-file-buffers t) ; Revert Dired and other buffers
  (global-auto-revert-mode 1) ; Revert buffers when the underlying file has changed
  (setq auto-revert-check-vc-info t)
  (setq auto-revert-verbose t)

  (setq-default indent-tabs-mode nil) ; Use spaces instead of tabs

  (electric-pair-mode 1) ; Auto-insert matching bracket
  (setq show-paren-when-point-inside-paren t)

  (setq-default delete-by-moving-to-trash t)

  (fset 'yes-or-no-p 'y-or-n-p) ; Shorter confirmation

  ;; Prefer utf-8 whenever possible
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)

  ;; Relative line numbers
  (setq display-line-numbers-type 'relative)
  (global-display-line-numbers-mode 1)

  ;; Default theme
  ;; Load dark theme later at night
  (if (> (decoded-time-hour (decode-time (current-time))) 18)
      (load-theme 'modus-vivendi)
    (load-theme 'modus-operandi))

  ;; Turn on recentf mode
  (add-hook 'after-init-hook #'recentf-mode)

  ;; Enable indentation+completion using the TAB key
  ;; completion-at-point is often bound to M-TAB
  (setq tab-always-indent 'complete)

  ;; Scrolling
  (push '(vertical-scroll-bars) default-frame-alist) ;; Remove vertical scroll bar
  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
  (setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling

  ;; Indentation
  (setq-default tab-width 2)
  (setq-default c-basic-offset 2)
  (defun hk/c-mode-hook ()
    (c-set-offset 'substatement 0)
    (c-set-offset 'substatement-open 0))
  (add-hook 'c-mode-hook 'hk/c-mode-hook)

  ;; Keybinds
  (global-set-key (kbd "C-t") 'hippie-expand) ;; orig. transpose-chars
  )

;; Better defaults that aren't defaults for some reason.
(use-package better-defaults
  ;; But don't enable ido-mode...
  :config (ido-mode nil)
  )

;; Don't litter
(use-package no-littering
  :custom
  (user-emacs-directory (expand-file-name "~/.cache/emacs/") "Don't put files into .emacs.d")
  (no-littering-etc-directory hk/data-dir)
	(no-littering-var-directory hk/cache-dir)
  :config
  ;; Don't create lockfiles
  (setq create-lockfiles nil)
  (setq custom-file (concat no-littering-etc-directory "custom.el"))
  ;; Also make sure auto-save files are saved out-of-tree
  (setq auto-save-file-name-transforms `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  )

;;; Packages
(use-package meow
  :config
  ;; (setq meow-cheatsheet-layout meow-cheatsheet-layout-colemak-dh)

  (meow-motion-overwrite-define-key
   ;; Use e to move up, n to move down.
   ;; Since special modes usually use n to move down, we only overwrite e here.
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
   '("t t" . toggle-truncate-lines)
   '("t l" . global-display-line-numbers-mode)
   '("s" . "M-s")
   '("d" . dirvish)

   ;; Files & buffer
   '("f f" . find-file)
   '("r"   . consult-recent-file)
   '("f o" . find-file-other-window)
   '("f R" . rename-file)
   '("b"   . consult-buffer)

   ;; Windows
   '("w w" . clone-frame)
   '("w /" . split-window-right)
   '("w d" . delete-window)

   ;; Project
   '("p a"	.	project-remember-projects-under)
   '("p r"	.	project-forget-projects-under)
   '("p p"	.	project-switch-project)
   '("p b"	.	consult-project-buffer)
   '("p B"	.	project-swith-buffer)
   '("p d"	.	consult-project-function)
   '("p f"	.	project-find-file)
   '("p q"	.	project-query-replace-regexp)
   '("p s"	.	consult-ripgrep)

   ;; avy
   '("n" . avy-goto-word-1)

   ;; Applications
   '("o e" . elfeed)
   '("o a" . org-agenda)

   ;; meow
   '("?" . meow-cheatsheet)
   '("e" . "H-e") ;; To execute original e in MOTION state, use SPC e.
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

  (meow-setup-indicator)
  (meow-setup-line-number)
  (meow-global-mode 1))

(use-package avy
  :bind
  (("M-n" . 'avy-goto-word-1))
  :config
  (setq avy-keys '(?a ?r ?s ?t ?n ?e ?i ?o ?d ?h)))

;; Collection of Ridiculously Useful eXtensions
(use-package crux
  :bind
  (("M-o" . 'crux-other-window-or-switch-buffer)))

(use-package smartparens
  :config
  (setq meow-paren-keymap (make-keymap))

  (meow-define-state paren
    "paren state"
    :lighter " [P]"
    :keymap meow-paren-keymap)

  (setq meow-cursor-type-paren 'hollow)

  (defun hk/sp-wrap-string () (interactive) (sp-wrap-with-pair "\""))
  (defun hk/sp-back-transpose () (interactive) (sp-transpose-sexp -1))

  (meow-define-keys 'paren
    '("<escape>" . meow-normal-mode)
    '("e" . sp-backward-sexp)
    '("n" . sp-forward-sexp)
    '("N" . sp-down-sexp)
    '("E" . sp-up-sexp)
    '("o s" . sp-wrap-square)
    '("o r" . sp-wrap-round)
    '("o c" . sp-wrap-curly)
    '("o g" . hk/sp-wrap-string)
    '("O" . sp-unwrap-sexp)
    '("i" . sp-slurp-hybrid-sexp)
    '("m" . sp-forward-barf-sexp)
    ;; '("k" . sp-backward-barf-sexp)
    ;; '("j" . sp-backward-slurp-sexp)
    ;; '("s" . sp-raise-sexp)
    ;; '("k" . sp-absorb-sexp)
    ;; '("," . sp-split-sexp)
    '("a" . sp-beginning-of-sexp)
    '("f" . sp-end-of-sexp)
    '("G" . sp-goto-top)
    '("t" . sp-transpose-sexp)
    '("T" . hk/sp-back-transpose)
    '("u" . meow-undo))

  (meow-normal-define-key
   '("P" . meow-paren-mode)))

(use-package consult
  :bind
  (
   ;; C-c bindings (mode-specific-map)
   ("C-c h" . 'consult-history)
   ("C-c m" . 'consult-mode-command)
   ("C-c k" . 'consult-kmacro)
   ;; C-x bindings (ctl-x-map)
   ("C-x M-:" . 'consult-complex-command)     ;; orig. repeat-complex-command
   ("C-x b" . 'consult-buffer)                ;; orig. switch-to-buffer
   ("C-x 4 b" . 'consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
   ("C-x 5 b" . 'consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
   ("C-x r b" . 'consult-bookmark)            ;; orig. bookmark-jump
   ("C-x p b" . 'consult-project-buffer)      ;; orig. project-switch-to-buffer
   ;; Custom M-# bindings for fast register access
   ("M-#" . 'consult-register-load)
   ("M-." . 'consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
   ("C-M-#" . 'consult-register)
   ;; Other custom bindings
   ("M-y" . 'consult-yank-pop)                ;; orig. yank-pop
   ("<help> a" . 'consult-apropos)            ;; orig. apropos-command
   ;; M-g bindings (goto-map)
   ("M-g e" . 'consult-compile-error)
   ("M-g f" . 'consult-flymake)               ;; Alternative: consult-flycheck
   ("M-g g" . 'consult-goto-line)             ;; orig. goto-line
   ("M-g M-g" . 'consult-goto-line)           ;; orig. goto-line
   ("M-g o" . 'consult-outline)               ;; Alternative: consult-org-heading
   ("M-g m" . 'consult-mark)
   ("M-g k" . 'consult-global-mark)
   ("M-g i" . 'consult-imenu)
   ("M-g I" . 'consult-imenu-multi)
   ;; M-s bindings (search-map)
   ("M-s d" . 'consult-find)
   ("M-s D" . 'consult-locate)
   ("M-s g" . 'consult-grep)
   ("M-s G" . 'consult-git-grep)
   ("M-s r" . 'consult-ripgrep)
   ("M-s l" . 'consult-line)
   ("M-s L" . 'consult-line-multi)
   ("M-s m" . 'consult-multi-occur)
   ("M-s k" . 'consult-keep-lines)
   ("M-s u" . 'consult-focus-lines)
   ;; Isearch integration
   ("M-s e" . 'consult-isearch-history)
   :map isearch-mode-map
   ("M-e" . 'consult-isearch-history)         ;; orig. isearch-edit-string
   ("M-s e" . 'consult-isearch-history)       ;; orig. isearch-edit-string
   ("M-s l" . 'consult-line)                  ;; needed by consult-line to detect isearch
   ("M-s L" . 'consult-line-multi)            ;; needed by consult-line to detect isearch
   ;; Minibuffer history
   :map minibuffer-local-map
   ("M-s" . 'consult-history)                 ;; orig. next-matching-history-element
   ("M-r" . 'consult-history)                 ;; orig. previous-matching-history-element
   ("C-r" . 'consult-history)))

(use-package dirvish
  :config
  (dirvish-override-dired-mode))

;;; Savehist
(use-package savehist
  :ensure nil ;; Not a real package, but a place to collect settings
  :custom
  (savehist-autosave-interval 60)
  :init
  (savehist-mode))

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
  :bind
  (("C-c a"   . org-agenda)
   ("C-c C-c" . org-capture))
  :config
  (setq org-directory "~/documents/org/"
        org-agenda-files '("~/documents/org/gtd/")
        org-return-follows-link t
        org-deadline-warning-days 30
        org-startup-indented t
        org-log-done 'time
        org-fold-catch-invisible-edits 'smart
        org-babel-load-languages '((awk . t)
                                   (calc . t)
                                   (clojure . t)
                                   (css . t)
                                   (dot . t)
                                   (emacs-lisp . t)
                                   (forth . t)
                                   (fortran . t)
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
                                   (sqlite . t))
        ;; Task Management
        org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n!)" "|" "DONE(d)")
          (sequence "WAIT(w@/!)" "|" "CANCELLED(c@/!)"))
        org-capture-templates
        '(("t" "Todo [inbox]" entry (file "gtd/inbox.org")
           "* TODO %?\n:PROPERTIES:\n:ENTERED_ON: %U\n:END:\n%i\n%a")
          ("T" "Tickler" entry
           (file "gtd/tickler.org")
           "* %i%? \n %U")
          ("W" "Weekly Review" plain
           (file+olp+datetree "roam/review.org")
           (file "templates/weekly-review.org")
           :immediate-finish t
           :jump-to-captured t
           :clock-in t
           ))
        org-agenda-custom-commands
        '(
          ("g" "Get Things Done (GTD)"
           ((agenda "" (;; start from yesterday
                        (org-agenda-start-day "-1d")
                        ;; show 8 days
                        (org-agenda-span 8)))
            (todo "NEXT" ((org-agenda-overriding-header "Next:")))
            (todo "WAIT" ((org-agenda-overriding-header "Waiting on:")))
            (tags-todo "inbox" ((org-agenda-overriding-header "Inbox:")))
            (tags-todo "project//TODO" ((org-agenda-overriding-header "Projects:")))
            (tags "CLOSED>=\"<today>\"" ((org-agenda-overriding-header "\nCompleted today\n")))
            ))))
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-show-habits t
        org-habit-following-days 7
        org-habit-preceding-days 21))

(use-package org-roam
  :custom
  (org-roam-directory (concat org-directory "roam/"))
  :bind
  (("C-c o n" . 'org-roam-node-find))
  :config
  (org-roam-db-autosync-mode))

(use-package org-download
  :custom
  (org-download-method 'attach))

(use-package org-appear
  :hook
  (org-mode . org-appear-mode)
  :custom
  (org-appear-autosubmarkers t)
  (org-appear-autoentities t)
  (org-appear-autolinks t)
  (org-appear-autokeywords t))

(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

(use-package org-modern
  :custom
  (org-modern-hide-stars nil)
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda))

;; (use-package org-modern-indent
;;   :hook
;;   (org-indent-mode . org-modern-indent-mode))

;; (use-package org-xournalpp)
(use-package pdf-tools)

(use-package mu4e
  :custom
  (setq sendmail-program (executable-find "msmtp")
        send-mail-function #'smtpmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail))


;;; :editor
;; String inflection
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

;; formatting
(use-package format-all)

(use-package abbrev
  :defer 2
  :init
  (add-hook 'text-mode-hook #'abbrev-mode)
  (add-hook 'prog-mode-hook #'abbrev-mode)
  :custom
  (save-abbrevs 'silently))

;; auto activating snippets
(use-package aas
  :init (add-hook 'find-file-hook #'aas-activate-for-major-mode)
  :preface
  (defmacro aas-tempel (&rest template)
    `(lambda () (tempel-insert ',template)))
  :config
  (aas-global-mode)
  (aas-set-snippets 'global
    ";--" "—"
    ";>>" "⟶"
    ";<<" "⟵"
    ";gh" "https://github.com/"
    ";gm" "https://github.com/AntonHakansson"
    ";isodate" (lambda () (interactive) (insert (format-time-string "%a, %d %b %Y %T %z")))
    ";date" (lambda () (interactive) (insert (format-time-string "%a %b %d %Y")))
    ";sdate" (lambda () (interactive) (insert (format-time-string "%d %b %Y")))
    ";d/" (lambda () (interactive) (insert (format-time-string "%D")))
    ";d-" (lambda () (interactive) (insert (format-time-string "%F")))
    ";time" (lambda () (interactive) (insert (format-time-string "%T")))
    ";filename" (lambda () (interactive) (insert (file-name-nondirectory (buffer-file-name)))))
  (aas-set-snippets 'org-mode
    ";el" "#+begin_src emacs-lisp\n\n#+end_src"
    ";py" "#+begin_src python\n\n#+end_src"
    ";co" "#+begin_src\n\n#+end_src"
    ";m" (lambda () (interactive) (insert "\\(  \\)") (backward-char 3)))
  (aas-set-snippets 'c-mode
    ";p" (lambda () (interactive) (insert "printf(\"log: %d\\n\", );") (backward-char 2))
    ";T" "// TODO(hk): "
    ";N" "// NOTE(hk): "))

(use-package laas
  :hook (LaTeX-mode . laas-mode)
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

;; Snippet
(use-package tempel
  :bind (("M-+" . #'tempel-complete)
         ("M-*" . #'tempel-insert))
  :custom
  (tempel-trigger-prefix ";") ;; Require trigger prefix before template name when completing.
  (tempel-path (concat hk/config-dir "templates"))

  :init
  (add-to-list 'completion-at-point-functions #'tempel-complete))

;;; Git
(use-package magit
  :custom
  (magit-repository-directories '(("~/repos" . 2)))
  :config
  )

;; Show TODOs (and FIXMEs, etc) in Magit status buffer
(use-package magit-todos
  :after magit)

;; Forge allows you to work with Git forges, such as Github and Gitlab, from the comfort of Magit and the rest of Emacs.
(use-package forge
  :after magit)

(use-package git-gutter
  :hook prog-mode
  :config
  (meow-leader-define-key
   '("g d" . '(git-gutter:popup-hunk :which-key "Hunk Diff"))
   '("g j" . '(git-gutter:next-hunk :which-key "Next Hunk"))
   '("g s" . '(git-gutter:stage-hunk :which-key "Stage Hunk"))
   '("g u" . '(git-gutter:revert-hunk :which-key "Unstage Hunk"))
   '("g k" . '(git-gutter:previous-hunk :which-key "Prev Hunk")))
  (git-gutter-mode))

(use-package git-gutter-fringe
  :after git-gutter)

;;; :completion
(use-package which-key
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

;; Vertical UI
;; Completion in minibuffer
(use-package vertico
  :config
  (vertico-mode))

;; Rich annotations in minibuffer
(use-package marginalia
  :config
  (marginalia-mode))

;; Advanced completion style (better fuzzy matching)
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles partial-completion)))))


;; Completion in buffer (popup ui)
(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-auto t "Enable Auto Completion")
  (corfu-cycle t "Cycle completion options")
  (corfu-auto-prefix 2 "Trigger completion early")
  :config
  (global-corfu-mode))


;; Cape for better completion-at-point support and more
(use-package cape
  :config
  ;; Add useful defaults completion sources from cape
  (add-to-list 'completion-at-point-functions #'cape-file))

;; ui
(use-package mixed-pitch
  :hook (org-mode . mixed-pitch-mode))
(use-package all-the-icons)

;; Make default `describe-*' screens more helpful
(use-package helpful
  :bind (([remap describe-command]  . #'helpful-command)
         ([remap describe-function] . #'helpful-callable)
         ([remap describe-key] .  #'helpful-key)
         ([remap describe-symbol] .  #'helpful-symbol)
         ([remap describe-variable] . #'helpful-variable)
         ("C-c C-d" . #'helpful-at-point)
         ("C-h F" . #'helpful-function)
         ("C-h K" . #'helpful-keymap)))

;; (use-package embark
;;   ;; :general
;;   ;; (:keymaps 'override
;;   ;;           "C-." #'embark-act         ;; pick some comfortable binding
;;   ;;           "C-;" #'embark-dwim        ;; good alternative: M-.
;;   ;;           "C-h B" #'embark-bindings) ;; alternative for `describe-bindings'
;;   ;; (general-define-key [remap describe-bindings] #'embark-bindings)

;;   :config
;;   (setq prefix-help-command #'embark-prefix-help-command))

;; ;; Consult users will also want the embark-consult package.
;; (use-package embark-consult)

;;; IDE
;; Using the hl-todo package, we are able to highlight keywords
;; related to the working environment, like: TODO, FIXME and some
;; more.
(use-package hl-todo
  :hook '(prog-mode)
  :init
  (setq
   hl-todo-highlight-punctuation ":"
   hl-todo-keyword-faces
   `(("TODO"       org-todo bold)
     ("FIXME"      error bold)
     ("HACK"       font-lock-constant-face bold)
     ("REVIEW"     font-lock-keyword-face bold)
     ("NOTE"       success bold)
     ("DEPRECATED" font-lock-doc-face bold))))

(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode))

;; load environment
(use-package envrc)
(use-package direnv
  :config
  (direnv-mode))

;; lsp
(use-package eglot)

(use-package fancy-compilation
  ;; compilation-mode fancy support for colors, progress bars, and scrolling
  :commands (fancy-compilation-mode))

(with-eval-after-load 'compile
  (fancy-compilation-mode))

;; c/c++
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((c++-mode c-mode) "clangd" "--clang-tidy" "--completion-style=detailed")))

;; Nix
(use-package nix-mode
  :mode "\\.nix\\'"
  :config
  (add-to-list 'eglot-server-programs '(nix-mode . ("rnix-lsp"))))

;; Web (html/css/javascript)
(use-package emmet-mode)

(use-package zig-mode)

;;; :tools
;; :web
(use-package eww
  ;; Use & to open externally if eww can't handle the page
  :config
  (setq browse-url-browser-function #'eww-browse-url)
  (setq browse-url-generic-program "firefox"))

;; :rss
(use-package elfeed
  :custom
  (elfeed-db-directory "~/documents/org/.elfeed") ;; Sync rss feeds with Syncthing
  (elfeed-sort-order 'ascending))

(use-package elfeed-goodies
  :config
  (setq elfeed-goodies/entry-pane-position 'bottom)
  (elfeed-goodies/setup))

(use-package elfeed-org
  :config
  (setq rmh-elfeed-org-files (list (concat org-directory "elfeed.org")))
  (elfeed-org)) ;; hook up elfeed-org to read the configuration when elfeed starts

(use-package elfeed-tube
  :after elfeed
  :config
  (elfeed-tube-setup))


(use-package exec-path-from-shell
  ;; This ensures Emacs has the same PATH as the rest of my system.  It is
  ;; necessary for macs (not that I ever use that), or if Emacs is started
  ;; via a systemd service, as systemd user services don't inherit the
  ;; environment of that user
  :if (or (eq system-type 'darwin)
          (and (daemonp)
               (eq system-type 'gnu/linux)))
  :config
  (exec-path-from-shell-initialize))

(use-package saveplace
  ;; Yes, please save my place when opening/closing files:
  :config
  (save-place-mode))

(use-package so-long
  ;; Performance mitigations for files with long lines.
  :config
  (global-so-long-mode))

(use-package ws-butler
  ;; Whitespace is evil.  Let's get rid of as much as possible.  But we
  ;; don't want to do this with files that already had whitespace (from
  ;; someone else's project, for example).  This mode will call
  ;; `whitespace-cleanup' before buffers are saved (but smartly)!
  :hook
  ((prog-mode ledger-mode gitconfig-mode) . ws-butler-mode)
  :custom
  (ws-butler-keep-whitespace-before-point nil))


(use-package flyspell)

(use-package flycheck
  ;; Grammar / prose lint
  :config
  ;; (flycheck-define-checker vale-global
  ;;   "A checker for prose with vale using a global configuration."
  ;;   :command ("vale" "--config=/home/hakanssn/repos/emacs-config/.vale.ini" "--output" "line" source)
  ;;   :standard-input nil
  ;;   :error-patterns
  ;;   ((error line-start (file-name) ":" line ":" column ":" (id (one-or-more (not (any ":")))) ":" (message) line-end))
  ;;   :modes (markdown-mode org-mode text-mode))
  ;; (add-to-list 'flycheck-checkers 'vale-global 'append)
  (global-flycheck-mode))

;; (load-file (concat hk/config-dir "whitebox.el"))

(provide 'init)
;;; init.el ends here

;; Local Variables:
;; outline-regexp: ".*\(use-package.*"
;; End:
