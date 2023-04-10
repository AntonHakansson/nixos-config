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

(use-package diminish
  ;; Dependencies that inject `:keywords' into `use-package' should be
  ;; included before all other packages.
  ;; For :diminish in (use-package). Hides minor modes from the status line.
  )

(use-package emacs
  :ensure nil ;; Not a real package, but a place to collect global settings
  :init
  (setq user-mail-address "anton@hakanssn.com"
        user-full-name "Anton Hakansson")

  ;; Hide menu bars and scroll for clean ui
  (unless (memq window-system '(mac ns))
    (menu-bar-mode -1))
  (when (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))
  (when (fboundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1))

  ;; Auto revert buffers
  (customize-set-variable 'global-auto-revert-non-file-buffers t) ; Revert Dired and other buffers
  (global-auto-revert-mode 1) ; Revert buffers when the underlying file has changed
  (setq auto-revert-check-vc-info t)
  (setq auto-revert-verbose t)

  (setq-default indent-tabs-mode nil) ; Use spaces instead of tabs

  (setq-default delete-by-moving-to-trash t)

  (fset 'yes-or-no-p 'y-or-n-p) ; Shorter confirmation

  ;; Prefer utf-8 whenever possible
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)

  ;; Relative line numbers
  (setq display-line-numbers-type 'relative)
  ;; (global-display-line-numbers-mode 1)

  ;; Default theme
  ;; Load dark theme later at night
  (if (> (decoded-time-hour (decode-time (current-time))) 18)
      (load-theme 'modus-vivendi)
    (load-theme 'modus-operandi-tinted))

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
  (global-set-key (kbd "M-p") 'backward-paragraph)
  (global-set-key (kbd "M-n") 'forward-paragraph)

  ;; C-w terminal behavior
  (defun backward-kill-word-or-region (&optional arg)
    (interactive "p")
    (if (region-active-p)
        (call-interactively #'kill-region)
      (backward-kill-word arg)))
  (global-set-key (kbd "C-w")  'backward-kill-word-or-region)
  )

(use-package no-littering
  ;; Put emacs files in ~/.cache/emacs/
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

(use-package meow
  ;; Modal editing
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
   '("t k" . kill-this-buffer)
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
   '("P"    . "C-x p")
   '("p p"	.	project-switch-project)
   '("p b"	.	consult-project-buffer)
   '("p c"	.	project-compile)
   '("p b"	.	project-swith-buffer)
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
  :config
  (setq avy-keys '(?a ?r ?s ?t ?n ?e ?i ?o ?d ?h)))

(use-package hydra)
(use-package dumb-jump
  :after hydra
  :bind
  (("C-c j" . dumb-jump-hydra/body))
  :init
  (defhydra dumb-jump-hydra (:color blue :columns 3)
    "Dumb Jump"
    ("j" dumb-jump-go "Go")
    ("o" dumb-jump-go-other-window "Other window")
    ("e" dumb-jump-go-prefer-external "Go external")
    ("x" dumb-jump-go-prefer-external-other-window "Go external other window")
    ("i" dumb-jump-go-prompt "Prompt")
    ("l" dumb-jump-quick-look "Quick look")
    ("b" dumb-jump-back "Back"))
  )

(use-package crux
  ;; Collection of Ridiculously Useful eXtensions
  :bind
  (("M-o" . 'crux-other-window-or-switch-buffer)
   ("C-a" . 'crux-move-beginning-of-line)))

(use-package smartparens
  :diminish
  :config
  (setq meow-paren-keymap (make-keymap))

  (meow-define-state paren
    "paren state"
    :lighter " [P]"
    :keymap meow-paren-keymap)

  (setq meow-cursor-type-paren 'hollow)

  (defun hk/sp-wrap-string (&optional arg) (interactive "P") (sp-wrap-with-pair "\""))
  (defun hk/sp-back-transpose () (interactive) (sp-transpose-sexp -1))

  (meow-define-keys 'paren
    '("<escape>" . meow-normal-mode)
    '("q" . meow-normal-mode)
    '("g" . meow-normal-mode)
    '("u" . meow-undo)
    '("n" . sp-forward-sexp)
    '("N" . sp-down-sexp)
    '("p" . sp-backward-sexp)
    '("P" . sp-up-sexp)
    '("e" . sp-backward-sexp)
    '("E" . sp-up-sexp)
    '("o s" . sp-wrap-square)
    '("o r" . sp-wrap-round)
    '("o c" . sp-wrap-curly)
    '("o g" . hk/sp-wrap-string)
    '("O" . sp-unwrap-sexp)
    '("i" . sp-slurp-hybrid-sexp)
    '("m" . sp-forward-barf-sexp)
    '("," . sp-split-sexp)
    '("a" . sp-beginning-of-sexp)
    '("f" . sp-end-of-sexp)
    '("G" . sp-goto-top)
    '("t" . sp-transpose-sexp)
    '("T" . hk/sp-back-transpose))

  (meow-normal-define-key
   '("P" . meow-paren-mode))

  (smartparens-global-mode +1)
  (show-smartparens-global-mode +1))

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

(use-package savehist
  :ensure nil ;; Not a real package, but a place to collect settings
  :custom
  (savehist-autosave-interval 60)
  :init
  (savehist-mode))

(use-package olivetti
  ;; Center text for nicer writing and reading
  :defer 3
  :bind (("C-c t z" . olivetti-mode))
  :hook (org-mode   . olivetti-mode)
  :hook (eww-mode   . olivetti-mode)
  :hook (Info-mode  . olivetti-mode)
  :hook (elfeed-search-mode  . olivetti-mode)
  :hook (elfeed-show-mode    . olivetti-mode)
  :config
  (setq-default olivetti-body-width 120
                fill-column 90)
  )

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
  :custom
  (org-babel-load-languages '((awk . t)
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
                              (sqlite . t)))
  (org-use-speed-commands
   (lambda () (and (looking-at org-outline-regexp) (looking-back "^\\**")))) ;  when point is on any star at the beginning of the headline
  :config
  (setq org-directory "~/documents/org/"
        org-agenda-files '("~/documents/org/gtd/")
        org-return-follows-link t
        org-deadline-warning-days 30
        org-startup-indented t
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
          ("W" "Weekly Review" plain
           (file+olp+datetree "roam/review.org")
           (file "templates/weekly-review.org")
           :immediate-finish t
           :jump-to-captured t
           :clock-in t
           ))
        org-agenda-custom-commands
        '(("g" "Get Things Done (GTD)"
           ((agenda "" (;; start from yesterday
                        (org-agenda-start-day "-1d")
                        ;; show 8 days
                        (org-agenda-span 8)))
            (todo "NEXT" ((org-agenda-overriding-header "Next:")))
            (todo "WAIT" ((org-agenda-overriding-header "Waiting on:")))
            (tags-todo "inbox" ((org-agenda-overriding-header "Inbox:")))
            (tags-todo "project//TODO" ((org-agenda-overriding-header "Projects:")))
            (tags "CLOSED>=\"<today>\"" ((org-agenda-overriding-header "Completed today:")))
            ))))
  )

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

(use-package org-ai
  :commands (org-ai-mode)
  :init
  (defun hk/chatgpt ()
    (interactive)
    (switch-to-buffer (get-buffer-create "*scratch-org-ai*"))
    (unless (eq major-mode 'org-mode)
      (org-mode)
      (toggle-truncate-lines)
      (insert "#+begin_ai\n")
      (insert "[SYS]: You are a helpful assistant that gives precise and concise answers.\n\n")
      (insert "[ME]: ")
      (push-mark)
      (insert "\n#+end_ai\n")
      (exchange-point-and-mark)
      ))
  :custom
  (org-ai-openai-api-token (substring (shell-command-to-string "pass show tools/openai_api_token") 0 -1))
  :bind
  (("C-c i" . hk/chatgpt))
  :init
  (add-hook 'org-mode-hook #'org-ai-mode))

(use-package org-roam
  :custom
  (org-roam-directory (concat org-directory "roam/"))
  :bind
  (("C-c o n" . 'org-roam-node-find))
  :config
  (org-roam-db-autosync-mode))

(use-package org-download)

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

(use-package denote
  :custom
  (denote-directory (concat org-directory "denote/"))
  (denote-known-keywords '("emacs" "philosophy" "pol" "C/C++"))
  :bind
  (("C-c C-n" . denote)))

(use-package pdf-tools)

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

(use-package format-all)

(use-package abbrev
  :ensure nil
  :init
  (add-hook 'text-mode-hook #'abbrev-mode)
  (add-hook 'prog-mode-hook #'abbrev-mode)
  :custom
  (save-abbrevs 'silently))

(use-package aas
  ;; auto activating snippets
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

(use-package tempel
  ;; Snippet
  :bind (("M-+" . #'tempel-complete)
         ("M-*" . #'tempel-insert))
  :custom
  (tempel-trigger-prefix ";") ;; Require trigger prefix before template name when completing.
  (tempel-path "~/documents/org/tempel")

  :config
  (add-to-list 'completion-at-point-functions #'tempel-complete))

;;; Git
(use-package magit
  :custom
  (magit-repository-directories '(("~/repos" . 2)))
  :bind
  (("C-c o m" . 'magit))
  )

(use-package magit-todos
  ;; Show TODOs (and FIXMEs, etc) in Magit status buffer
  :after magit)

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

;;; :completion
(use-package which-key
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1)
  :diminish)

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
        completion-category-overrides '((file (styles partial-completion)))))

(use-package corfu
  ;; Completion in buffer (popup ui)
  :custom
  (corfu-auto t "Enable Auto Completion")
  ;; (corfu-cycle t "Cycle completion options")
  (corfu-auto-prefix 2 "Trigger completion early")
  :config
  (global-corfu-mode))

(use-package cape
  ;; Cape for better completion-at-point support and more
  :config
  ;; Add useful defaults completion sources from cape
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package mixed-pitch
  :hook (org-mode . mixed-pitch-mode))
(use-package all-the-icons)

(use-package helpful
  ;; Make default `describe-*' screens more helpful
  :bind (([remap describe-command]  . #'helpful-command)
         ([remap describe-function] . #'helpful-callable)
         ([remap describe-key] .  #'helpful-key)
         ([remap describe-symbol] .  #'helpful-symbol)
         ([remap describe-variable] . #'helpful-variable)
         ("C-c C-d" . #'helpful-at-point)
         ("C-h F" . #'helpful-function)
         ("C-h K" . #'helpful-keymap)))

;;; IDE
(use-package hl-todo
  ;; Using the hl-todo package, we are able to highlight keywords
  ;; related to the working environment, like: TODO, FIXME and some
  ;; more.
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
  :hook (prog-mode . rainbow-mode)
  :diminish)

(use-package envrc)
(use-package direnv
  :config
  (direnv-mode))

(use-package eglot
  :hook
  (c++-mode . eglot-ensure)
  (c-mode . eglot-ensure)
  (nix-mode . eglot-ensure)
  :bind
  (("C-c C" . eglot)
   ("C-c A" . eglot-code-actions)
   ("C-c R" . eglot-rename)
   ("C-c F" . eglot-format)))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((c++-mode c-mode) "clangd" "--clang-tidy" "--completion-style=detailed")))

(use-package nix-mode
  :mode (("\\.nix\\'" . nix-mode))
  :config
  (add-to-list 'eglot-server-programs '(nix-mode . ("rnix-lsp"))))

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

(use-package zig-mode)

;;; :tools
(use-package eww
  :ensure nil
  :bind
  (("M-n" . nil)
   ("M-p" . nil))
  :config
  ;; Use & to open externally if eww can't handle the page
  (setq browse-url-browser-function #'eww-browse-url)
  (setq browse-url-generic-program "firefox"))

(use-package elfeed
  ;; rss reader
  :custom
  (elfeed-db-directory "~/documents/org/.elfeed") ;; Sync rss feeds with Syncthing
  (elfeed-sort-order 'ascending))

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

(use-package undo-tree
  :diminish
  :config
  (global-undo-tree-mode))

(use-package saveplace
  ;; Yes, please save my place when opening/closing files:
  :ensure nil
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
  ((text-mode prog-mode) . ws-butler-mode)
  :diminish
  :custom
  (ws-butler-keep-whitespace-before-point nil))

(use-package editorconfig
  :config
  (setq editorconfig-trim-whitespaces-mode 'ws-butler-mode))

(use-package flyspell
  :ensure nil)

(use-package flycheck
  :config
  ;; (global-flycheck-mode)
  )

;; (load-file (concat hk/config-dir "whitebox.el"))

(provide 'init)
;;; init.el ends here

;; Local Variables:
;; outline-regexp: "\(use-package.*"
;; End:
