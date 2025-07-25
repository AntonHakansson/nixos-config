;;; init.el --- hakanssn's custom emacs config  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(when (< emacs-major-version 29)
  (error (format "Emacs config only works with Emacs 29 and newer; you have version %d" emacs-major-version)))

(defvar hk/config-dir (or (getenv "HK_CONFIG_DIR") "~/.config/emacs/") "Location off init.el.")
(defvar hk/data-dir (concat (or (getenv "XDG_DATA_HOME") "~/.local/share") "/emacs/") "Location for data.")
(defvar hk/cache-dir (concat (or (getenv "XDG_CACHE_DIR") "~/.cache") "/emacs/") "Location for cache.")

(use-package emacs
  :ensure nil                 ; Not a real package, but a place to collect global settings
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
  (blink-cursor-mode -1)                             ; Steady cursor
  (push '(vertical-scroll-bars) default-frame-alist) ; Remove vertical scroll bar
  (setopt scroll-conservatively 10
          scroll-margin 15)

  ;; Buffers, Lines, and indentation
  (setopt display-line-numbers-type 'relative) ; Relative line numbers
  (setopt indent-tabs-mode nil)                ; Use spaces instead of tabs
  (setopt tab-width 2)
  (setopt x-underline-at-descent-line nil)  ; Prettier underlines
  (setopt show-trailing-whitespace nil)     ; By default, don't underline trailing spaces
  (setopt indicate-buffer-boundaries 'left) ; Show buffer top and bottom in the margin
  (setopt switch-to-buffer-obey-display-actions t) ; Make switching buffers more consistent

  ;; Quickly access recent files
  (setopt recentf-max-menu-items 30)    ; Bump the limits a bit
  (setopt recentf-max-saved-items 256)
  (add-hook 'after-init-hook #'recentf-mode) ; Turn on recentf mode

  ;; Misc. Emacs tweaks
  (fset 'yes-or-no-p 'y-or-n-p)         ; Shorter confirmation
  (setopt isearch-lazy-count t)
  (setopt delete-by-moving-to-trash t)
  (setopt set-mark-command-repeat-pop t) ; After =C-u C-SPC=, keep ctrl down and press space to cycle mark ring
  (setopt bookmark-save-flag 1)       ; Write bookmark file when bookmark list is modified
  (electric-pair-mode +1)

  ;; Keybinds
  (global-set-key (kbd "C-x C-k") #'kill-current-buffer)
  (global-set-key (kbd "C-(") 'previous-buffer)
  (global-set-key (kbd "C-)") 'next-buffer)
  (global-set-key (kbd "<f5>") 'recompile)
  (global-set-key (kbd "<f7>") 'scroll-lock-mode)

  ;; ibuffer
  (keymap-set global-map "<remap> <list-buffers>" 'ibuffer) ;; C-x C-b
  (setopt ibuffer-expert t)             ; Stop yes no prompt on delete

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
        initial-scratch-message "#+title: Scratch Buffer\n\nFor random thoughts.\n\n#+begin_src emacs-lisp\n\n#+end_src\n")

  ;; Tab bar
  (defun tab-bar-format-menu-bar ()
    "Produce the Menu button for the tab bar that shows the menu bar."
    `((menu-bar menu-item (propertize " 𝝺 " 'face 'tab-bar-tab-inactive)
                tab-bar-menu-bar :help "Menu Bar")))

  (setopt tab-bar-format '(tab-bar-format-menu-bar
                           tab-bar-format-tabs))

  (setopt tab-bar-new-tab-choice 'ibuffer)
  (setopt tab-bar-tab-name-function 'tab-bar-tab-name-current)
  (setopt tab-bar-show t))

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
  (setq create-lockfiles nil)           ; #readme.txt#
  (setq make-backup-files nil)          ; readme.txt~
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
   ("<f6>" . 'consult-bookmark)
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
   ("M-e" . 'consult-isearch-history)   ; orig. isearch-edit-string
   ("M-s e" . 'consult-isearch-history) ; orig. isearch-edit-string
   ("M-s l" . 'consult-line)            ; Needed by consult-line to detect isearch
   ("M-s L" . 'consult-line-multi)      ; Needed by consult-line to detect isearch
   ;; Minibuffer history
   :map minibuffer-local-map
   ("M-s" . 'consult-history)           ; orig. next-matching-history-element
   ("M-r" . 'consult-history)           ; orig. previous-matching-history-element
   ("C-r" . 'consult-history))
  :init
  (require 'consult-imenu)
  (require 'consult-org)
  (require 'consult-flymake)
  (require 'consult-compile)
  (require 'consult-kmacro))

(use-package embark
  :bind
  ("C-." . embark-act)
  ("C-;" . embark-dwim)

  :init
  (setopt prefix-help-command #'embark-prefix-help-command)

  ;; `yt-dlp` utilities
  :bind
  (:map embark-url-map
        ("y" . #'hk/yt-dlp-video)
        ("Y" . #'hk/yt-dlp-audio))

  :preface
  (defcustom hk/yt-dlp-common-flags '("--embed-metadata" "--sub-langs" "en_US" "--restrict-filenames" "-o" "%(epoch>%Y%m%dT%H%M%S)s--%(title)s.%(ext)s")
    "Command line arguments passed directly to `yt-dlp` command")

  (defun hk/yt-dlp-audio (URL)
    "Downloads thing-at-point to ~/documents/audio/ with denote filename"
    (interactive (list
                  (or  (thing-at-point-url-at-point)
                       (read-string "Video URL: " (let ((url (current-kill 0)))
                                                    (when (url-p url) url))))))
    (apply 'start-process "yt-dlp"
                   (generate-new-buffer-name "*yt-dlp-audio*")
                   "yt-dlp" "-P" "~/documents/audio/" "--extract-audio" URL hk/yt-dlp-common-flags))

  (defun hk/yt-dlp-video (URL)
    "Downloads thing-at-point to ~/mpv/ with denote filename"
    (interactive (list
                  (or  (thing-at-point-url-at-point)
                       (read-string "Video URL: " (let ((url (current-kill 0)))
                                                    (when (url-p url) url))))))
    (apply 'start-process
           "yt-dlp"
           (generate-new-buffer-name "*yt-dlp-video*")
           "yt-dlp" "-P" "~/mpv/" URL hk/yt-dlp-common-flags)))

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
  ;; Colemak-Dh keys
  (setq avy-keys '(?a ?r ?s ?t ?n ?e ?i ?o ?d ?h))
  (setq avy-dispatch-alist
        '((?. . hk/avy-action-embark)
          (?x . avy-action-teleport)
          (?X . hk/avy-action-exchange)
          (?y . avy-action-yank)
          (?Y . avy-action-yank-line)
          (?$ . avy-action-ispell)
          (?z . avy-action-zap-to-char)))
  :init
  (defun hk/avy-action-embark (pt)
    "Run embark at PT."
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  (defun hk/avy-action-exchange (pt)
    "Exchange sexp at PT with the one at point."
    (set-mark pt)
    (transpose-sexps 0)))

(use-package crux
  ;; Collection of Ridiculously Useful eXtensions
  :bind
  (("M-o" . 'crux-other-window-or-switch-buffer)
   ("C-a" . 'crux-move-beginning-of-line)))

(use-package meow
  ;; Modal editing
  :custom
  (meow-use-clipboard 't)
  (meow-goto-line-function #'consult-goto-line)

  :preface
  (defcustom hk/meow-layout 'colemak-dh
    "What keyboard layout to load for meow."
    :options '(qwerty colemak-dh))

  (defun hk/meow-smart-reverse ()
    "Reverse selection or begin negative argument."
    (interactive)
    (if (use-region-p)
        (meow-reverse)
      (negative-argument nil)))

  (defun hk/meow-word ()
    "Expand word/symbol under cursor."
    (interactive)
    (if (and (use-region-p)
             (equal (car (region-bounds))
                    (bounds-of-thing-at-point 'word)))
        (meow-mark-symbol 1)
      (progn
        (when (and (mark)
                   (equal (car (region-bounds))
                          (bounds-of-thing-at-point 'symbol)))
          (meow-pop-selection))
        (meow-mark-word 1))))

  (defun hk/meow-setup-qwerty ()
    (setq meow-char-thing-table
          '((?f . round)
            (?d . square)
            (?s . curly)
            (?a . angle)
            (?r . string)
            (?v . paragraph)
            (?c . line)
            (?x . buffer)))

    (meow-normal-define-key
     ;; movement
     '("i" . meow-prev)
     '("k" . meow-next)
     '("j" . meow-left)
     '("l" . meow-right)

     '("z" . meow-search)
     '("-" . meow-visit)

     ;; expansion
     '("I" . meow-prev-expand)
     '("K" . meow-next-expand)
     '("J" . meow-left-expand)
     '("L" . meow-right-expand)

     '("u" . meow-back-word)
     '("U" . meow-back-symbol)
     '("o" . meow-next-word)
     '("O" . meow-next-symbol)

     '("a" . meow-mark-word)
     '("A" . meow-mark-symbol)
     '("s" . meow-line)
     '("S" . meow-replace)
     '("w" . meow-block)
     '("q" . meow-join)
     '("g" . meow-grab)
     '("G" . meow-pop-grab)
     '("m" . meow-swap-grab)
     '("M" . meow-sync-grab)
     '("p" . meow-cancel-selection)
     '("P" . meow-pop-selection)

     '("x" . meow-till)
     '("y" . meow-find)

     '("," . meow-beginning-of-thing)
     '("." . meow-end-of-thing)
     '(";" . meow-inner-of-thing)
     '(":" . meow-bounds-of-thing)

     ;; editing
     '("d" . meow-kill)
     '("f" . meow-change)
     '("t" . meow-delete)
     '("c" . meow-save)
     '("v" . meow-yank)
     '("V" . meow-yank-pop)

     '("e" . meow-insert)
     '("E" . meow-open-above)
     '("r" . meow-append)
     '("R" . meow-open-below)

     '("h" . undo-only)
     '("H" . undo-redo)

     '("b" . open-line)
     '("B" . split-line)

     '("ü" . indent-rigidly-left-to-tab-stop)
     '("+" . indent-rigidly-right-to-tab-stop))

    (keymap-unset meow-normal-state-keymap "n")
    (keymap-unset meow-normal-state-keymap ";")
    (meow-normal-define-key
     '("nk" . downcase-dwim)
     '("nq" . align-regexp)
     '("nw" . delete-trailing-whitespace)
     '("nf" . fill-paragraph)
     '("nt" . meow-comment)

     ;; general
     '(";q" . jinx-mode)
     '(";w" . jinx-correct)
     '(";t" . eglot-rename)
     '(";g" . magit-diff-buffer-file)
     '(";s" . save-buffer)
     '(";y" . overwrite-mode)
     '(";u" . whitespace-mode)
     '(";b" . eglot-format))
    )

  (defun hk/meow-setup-colemak-dh ()
    (setq meow-char-thing-table
          '((?t . round)
            (?s . square)
            (?r . curly)
            (?a . angle)
            (?p . string)
            (?d . paragraph)
            (?c . line)
            (?x . buffer)))

    (keymap-unset meow-normal-state-keymap "k")
    (keymap-unset meow-normal-state-keymap "o")
    (meow-normal-define-key
     ;; movement
     '("u" . meow-prev)
     '("e" . meow-next)
     '("n" . meow-left)
     '("i" . meow-right)

     '("j" . meow-search)
     ;; '("-" . meow-visit)
     '("T" . avy-goto-word-1)

     ;; expansion
     '("U" . meow-prev-expand)
     '("E" . meow-next-expand)
     '("N" . meow-left-expand)
     '("I" . meow-right-expand)

     '("l" . meow-back-word)
     '("L" . meow-back-symbol)
     '("y" . meow-next-word)
     '("Y" . meow-next-symbol)

     '("a" . hk/meow-word)
     '("A" . meow-mark-symbol) ; REVIEW: We can achieve the same with 'aa'
     '("r" . meow-line)
     '("R" . meow-replace)
     '("w" . meow-block)
     '("W" . meow-to-block)
     '("q" . meow-join)
     '("g" . meow-grab)
     '("G" . meow-pop-grab)
     '("h" . meow-swap-grab)
     '("H" . meow-sync-grab)
     '(";" . meow-cancel-selection)
     '(":" . meow-pop-selection)

     '("x" . meow-till)
     '("z" . meow-find)

     '("," . meow-beginning-of-thing)
     '("." . meow-end-of-thing)
     '("<" . meow-inner-of-thing)
     '(">" . meow-bounds-of-thing)

     ;; editing
     '("s" . meow-kill)
     '("t" . meow-change)
     '("b" . meow-delete)
     '("c" . meow-save)
     '("d" . meow-yank)
     '("D" . meow-yank-pop)

     '("f" . meow-insert)
     '("F" . meow-open-above)
     '("p" . meow-append)
     '("P" . meow-open-below)

     '("m" . undo-only)
     '("M" . undo-redo)

     '("kk" . downcase-dwim)
     '("kq" . align-regexp)
     '("kw" . delete-trailing-whitespace)
     '("kf" . fill-paragraph)
     ;; '("kp" . sp-split-sexp)
     '("kt" . meow-comment)

     ;; general
     '("oq" . jinx-mode)
     '("ow" . jinx-correct)
     '("ot" . eglot-rename)
     '("og" . magit-diff-buffer-file)
     '("os" . save-buffer)
     '("oy" . overwrite-mode)
     '("ou" . whitespace-mode)
     '("ob" . eglot-format)))

  (defun hk/meow-setup ()
    (interactive)
    (meow-thing-register 'angle
                         '(pair ("<") (">"))
                         '(pair ("<") (">")))

    (meow-normal-define-key
     ;; expansion
     '("0" . meow-expand-0)
     '("1" . meow-expand-1)
     '("2" . meow-expand-2)
     '("3" . meow-expand-3)
     '("4" . meow-expand-4)
     '("5" . meow-expand-5)
     '("6" . meow-expand-6)
     '("7" . meow-expand-7)
     '("8" . meow-expand-8)
     '("9" . meow-expand-9)
     ;; begin/end of thing
     '("'" . hk/meow-smart-reverse)
     '("," . meow-beginning-of-thing)
     '("." . meow-end-of-thing)
     '("<" . meow-inner-of-thing)
     '(">" . meow-bounds-of-thing)

     '("/" . meow-search)

     ;; ignore escape
     '("<escape>" . ignore))

    (pcase hk/meow-layout
      ('qwerty (hk/meow-setup-qwerty))
      ('colemak-dh (hk/meow-setup-colemak-dh))))

  (defun hk/meow-toggle-layout ()
    (interactive)
    (setopt hk/meow-layout
            (pcase hk/meow-layout
              ('qwerty     'colemak-dh)
              ('colemak-dh 'qwerty)))
    (hk/meow-setup))

  :config
  (hk/meow-setup)
  (meow-global-mode 1))

(use-package hydra)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer/completion settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vertico
  ;; Vertical UI Completion in minibuffer
  :hook
  (after-init . vertico-mode))

(use-package marginalia
  ;; Rich annotations in minibuffer
  :after vertico)

(use-package orderless
  ;; Advanced completion style (better fuzzy matching)
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package corfu
  ;; Completion in buffer (popup ui)
  :hook (((prog-mode text-mode tex-mode) . corfu-mode)
         ((shell-mode eshell-mode) . hk/corfu-shell-settings)
         (minibuffer-setup . hk/corfu-enable-always-in-minibuffer))
  :custom
  (corfu-auto t "Enable Auto Completion")
  (corfu-auto-delay 0.05 "Disable completion suggestion delay")
  (corfu-auto-prefix 3 "Trigger completion early")
  (corfu-cycle t "Cycle candidates")
  (corfu-on-exact-match 'quit "Don't auto insert completion/templates on single match")
  :bind
  (:map corfu-map
        ("RET" . nil)     ; Return should insert a newline - not complete the sugggestion.
        ("<escape>" . (lambda ()
                        (interactive)
                        (corfu-quit)
                        (meow-normal-mode))))
  :preface
  (defun hk/corfu-enable-always-in-minibuffer ()
    "Enable Corfu in the minibuffer if Vertico is not active."
    (unless (bound-and-true-p vertico--input)
      ;; (setq-local corfu-auto nil) ;; Enable/disable auto completion
      (setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
                  corfu-popupinfo-delay nil)
      (corfu-mode 1)))

  (defun hk/corfu-shell-insert-and-send ()
    (interactive)
    ;; 1. First insert the completed candidate
    (corfu-insert)
    ;; 2. Send the entire prompt input to the shell
    (cond
     ((and (derived-mode-p 'eshell-mode) (fboundp 'eshell-send-input))
      (eshell-send-input))
     ((derived-mode-p 'comint-mode)
      (comint-send-input))))

  (defun hk/corfu-shell-settings ()
    (setq-local corfu-quit-no-match t
                corfu-auto nil
                completion-cycle-threshold nil)
    (define-key corfu-map "\r" #'hk/corfu-shell-insert-and-send)
    (corfu-mode)))

(use-package corfu-info
  :ensure nil)

(use-package corfu-history
  :ensure nil
  :config
  (corfu-history-mode))

(use-package cape
  ;; Cape for better completion-at-point support and more
  :bind
  ;; Quickly duplicate line from buffer
  (("C-t" . 'cape-line)                 ; orig. transpose-chars
   ("C-S-t" . 'hippie-expand))          ; orig. transpose-chars
  :config
  (setq cape-dabbrev-check-other-buffers 'some
        dabbrev-ignored-buffer-regexps
        '("\\.\\(?:pdf\\|jpe?g\\|png\\|svg\\|eps\\)\\'"
          "^ "
          "\\(TAGS\\|tags\\|ETAGS\\|etags\\|GTAGS\\|GRTAGS\\|GPATH\\)\\(<[0-9]+>\\)?"))

  ;; Add useful defaults completion sources from cape
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block) ; Complete in org, markdown code block
  (defalias 'cape-dabbrev-min-3 (cape-capf-prefix-length #'cape-dabbrev 3))
  (add-to-list 'completion-at-point-functions #'cape-dabbrev-min-3))

(use-package pcmpl-args
  ;; Extend Pcomplete with completions from man pages.
  ;; There is a built-in pcomplete-from-help that parses '--help' output of command.
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Notes (org-mode, etc)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs ;; text-mode
  :ensure nil
  :preface
  (defun hk/text-capf ()
    "Set up completion-at-point for writing"
    (setq-local completion-at-point-functions
                '(cape-dabbrev-min-3
                  cape-elisp-block
                  cape-file)))

  (defun hk/fill-paragraph (&optional P)
    "When called with prefix argument call `fill-paragraph'.
Otherwise split the current paragraph into one sentence per line."
    (interactive "P")
    (if (not P)
        (save-excursion
          (let ((fill-column 12345678)) ;; relies on dynamic binding
            (fill-paragraph) ;; this will not work correctly if the paragraph is
            ;; longer than 12345678 characters (in which case the
            ;; file must be at least 12MB long. This is unlikely.)
            (let ((end (save-excursion
                         (forward-paragraph 1)
                         (backward-sentence)
                         (point-marker))))  ;; remember where to stop
              (beginning-of-line)
              (while (progn (forward-sentence)
                            (<= (point) (marker-position end)))
                (just-one-space) ;; leaves only one space, point is after it
                (delete-char -1) ;; delete the space
                (newline)        ;; and insert a newline
                ))))
      ;; otherwise do ordinary fill paragraph
      (fill-paragraph P)))

  :init
  (add-hook 'text-mode-hook 'hk/text-capf))

(use-package denote
  :hook (dired-mode . denote-dired-mode)
  :bind
  (("C-c C-n" . denote)
   ("C-c o n" . denote-open-or-create))
  :custom
  (denote-directory "~/documents/org/denote/")
  (denote-known-keywords '("emacs" "philosophy" "pol" "compsci" "cc"))
  (denote-org-front-matter
   ":PROPERTIES:
:ID: %4$s
:END:
#+title:      %1$s
#+date:       %2$s
#+filetags:   %3$s
#+identifier: %4$s\n\n")
  :config
  ;; Accept any symbol in a .dir-locals.el file; makes it easier to use silos.
  ;; See "silos" in the manual: https://protesilaos.com/emacs/denote
  (put 'denote-file-type 'safe-local-variable-p 'symbolp)

  :preface
  (defun hk/consult-denote (&optional initial)
    (interactive "P")
    (consult-ripgrep "~/documents/org/denote/" initial)))

(use-package htmlize)
(use-package gnuplot)
(require 'gnuplot-context) ; org mode error: run-hooks: Symbol’s function definition is void: gnuplot-context-sensitive-mode

(defun hk/truncate-lines ()
  (message "truncating lines")
  (toggle-truncate-lines +1))

(use-package org
  :hook (org-after-refile-insert . org-save-all-org-buffers)
  :bind
  (("C-c c"   . org-capture)
   ("C-c l"   . org-store-link)
   :map org-mode-map
   ("C-," . nil)  ; Orig. cycle agenda buffers
   ("C-'" . nil)  ; Orig. cycle agenda buffers
   :map org-src-mode-map
   ("C-c C-c" . hk/org-src-do-babel-execute)
   ("C-c C-v" . org-src-do-key-sequence-at-code-block))
  :custom
  (org-directory      "~/documents/org/")
  (org-return-follows-link t)
  (org-startup-indented t)
  (org-startup-folded "show2levels") ; Apparently default showeverything overrides hide-block
  (org-startup-with-inline-images t)
  (org-cycle-separator-lines 0) ; Hide emptly lines between subtrees
  (org-cycle-hide-block-startup t)
  (org-blank-before-new-entry '((heading . t) (plain-list-item . auto)))
  (org-image-actual-width nil) ; Use width from #+attr_org and fallback to original width.
  (org-fold-catch-invisible-edits 'show-and-error)
  (org-use-speed-commands (lambda () ; When point is on any star at the beginning of the headline
                            (and (looking-at org-outline-regexp)
                                 (looking-back "^\\**"))))
  (org-footnote-section nil) ; Define footnotes locally at end of subtree
  (org-id-method 'ts)
  (org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id)
  ;; Put attachment in: <org-attach-directory>/year-month/<rest>
  (org-attach-id-to-path-function-list '(org-attach-id-ts-folder-format
                                         org-attach-id-uuid-folder-format
                                         org-attach-id-fallback-folder-format))
  (org-attach-use-inheritance t) ; Always respect parent IDs

  :bind ("C-c a" . org-agenda)
  :hook (org-agenda-finalize . hk/truncate-lines)
  :custom
  (org-agenda-files (mapcar (lambda (f) (concat org-directory "gtd/" f)) '("inbox.org" "projects.org" "repeaters.org" "someday.org")))
  (calendar-date-style 'european)
  (org-agenda-window-setup 'current-window)
  (org-agenda-time-grid '((daily today require-timed) (600 1200 1800 2200) "" ""))
  (org-agenda-current-time-string "<-")
  (org-agenda-block-separator (kbd " "))
  (org-deadline-warning-days 30)
  (org-stuck-projects '("LEVEL=1&+project" ("NEXT") nil ""))
  :init
  (defun hk/org-skip-subtree-if-habit ()
    "Skip an agenda entry if it has a STYLE property equal to \"habit\"."
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (if (string= (org-entry-get nil "STYLE") "habit")
          subtree-end
        nil)))
  (defun hk/org-skip-subtree-if-priority (priority)
    "Skip an agenda subtree if it has a priority of PRIORITY.

PRIORITY may be one of the characters ?A, ?B, or ?C."
    (let ((subtree-end (save-excursion (org-end-of-subtree t)))
          (pri-value (* 1000 (- org-lowest-priority priority)))
          (pri-current (org-get-priority (thing-at-point 'line t))))
      (if (= pri-value pri-current)
          subtree-end
        nil)))
  :custom
  (org-agenda-custom-commands
   '(("g" "Get Things Done (GTD)"
      ((agenda "" (;; Show today
                   (org-agenda-span 1)
                   ))
       (todo "NEXT" ((org-agenda-overriding-header "Next:")))
       (todo "WAIT" ((org-agenda-overriding-header "Waiting on:")))
       (tags-todo "inbox//TODO" ((org-agenda-overriding-header "Inbox:")))
       (tags-todo "project//TODO" ((org-agenda-overriding-header "Projects:")))
       (tags-todo "diary//TODO" ((org-agenda-overriding-header "Today:")))
       (tags "CLOSED>=\"<today>\"" ((org-agenda-overriding-header "Completed today:")))
       (tags-todo "someday//TODO" ((org-agenda-overriding-header "Someday:")))))
     ("p" "Project List"
      ((tags "project" ((org-use-tag-inheritance nil)))))
     ("d" "Daily"
      ((agenda "" ((org-agenda-span 1)
                   (org-agenda-time-grid '((daily) () "" ""))
                   (org-habit-show-habits nil)))
       (tags "PRIORITY=\"A\""
             ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
              (org-agenda-overriding-header "High-priority:")))
       (todo "NEXT" ((org-agenda-overriding-header "Next:")))
       (alltodo ""
                ((org-agenda-skip-function '(or (hk/org-skip-subtree-if-habit)
                                                (hk/org-skip-subtree-if-priority ?A)
                                                (org-agenda-skip-if nil '(scheduled deadline))
                                                (org-agenda-skip-entry-if 'todo '("NEXT" "WAIT"))
                                                ))
                 (org-agenda-overriding-header "Actions:")))
       (todo "WAIT" ((org-agenda-overriding-header "Waiting on:"))))
      ;; Set Config
      ((org-agenda-tag-filter '("-someday"))))
     ))
  (org-agenda-prefix-format
        '((agenda . " %i %?-12t% s")
          (todo . " %i ")
          (tags . " %i ")
          (search . " %i %-12:c")))

  :hook (org-babel-after-execute . hk/maybe-org-redisplay-inline-images)
  :custom
  (org-babel-results-keyword "results" "Make babel results blocks lowercase")
  (org-confirm-babel-evaluate nil)
  (org-babel-load-languages
   (mapcar (lambda (e) (cons e t))
           '(awk calc C css emacs-lisp haskell js latex lisp makefile org perl plantuml python ruby shell sql sqlite)))
  :preface
  (defun hk/maybe-org-redisplay-inline-images (&optional beg end)
    (if (org--inline-image-overlays beg end)
        (org-redisplay-inline-images)))
  :custom
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n!)" "|" "DONE(d)")
     (sequence "WAIT(w@/!)" "|" "CANCELLED(c@/!)")))
  (org-log-done 'time)
  (org-log-into-drawer 't "Insert state changes into a drawer LOGBOOK")
  (org-capture-templates
   '(("t" "Todo [inbox]" entry (file "gtd/inbox.org")
      "* TODO %?\n:PROPERTIES:\n:ENTERED_ON: %U\n:END:\n%i\n" :empty-lines 1)
     ("i" "Clocked Todo" entry (file "gtd/inbox.org")
      "* NEXT %^{activity}\n:PROPERTIES:\n:ENTERED_ON: %U\n:END:\n%i\n" :empty-lines 1 :clock-in t :clock-keep t)
     ("m" "Mail [inbox]" entry (file "gtd/inbox.org")
      "* TODO Respond to %a\n:PROPERTIES:\n:ENTERED_ON: %U\n:END:\n%i\n")
     ("T" "Tickler" entry (file "gtd/repeaters.org")
      "* %i%?\n:PROPERTIES:\n:ENTERED_ON: %U\n:END:\n")
     ("a" "Anki Basic" entry (file+headline "anki.org" "Scratch")
      "* %<%H:%M>\n:PROPERTIES:\n:ANKI_NOTE_TYPE: Basic\n:ANKI_DECK: Mega\n:END:\n** Front\n%?\n** Back\n")
     ("w" "Web" entry (file+function "gtd/inbox.org" hk/org-capture-template-goto-link)
      "* %<%H:%M>\n%(hk/org-capture-html)\n" :immediate-finish t)
     ("W" "Webclip" entry (file+headline "gtd/inbox.org" "Unsorted Webclips")
      "* %? :webclip:\n:PROPERTIES:\n:ENTERED_ON: %U\n:END:\n%(hk/insert-org-from-html-clipboard)")
     ("c" "Item to Current Clocked Task" item (clock)
      "%i%?" :empty-lines 1)
     ("C" "Contents to Current Clocked Task" plain (clock)
      "%i" :immediate-finish t :empty-lines 1)
     ("k" "Kill-ring to Current Clocked Task" plain (clock)
      "%c" :immediate-finish t :empty-lines 1)
     ))

  :custom
  (org-refile-targets '((nil :maxlevel . 9)
                        (org-agenda-files :maxlevel . 3)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)

  :custom
  (org-format-latex-options (plist-put org-format-latex-options :scale 1.3)) ; Increase scale of latex fragments
  (org-preview-latex-image-directory "/tmp/ltximg/") ; Don't pollute working directory

  :preface
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

  (defun hk/org-src-do-babel-execute ()
    (interactive)
    (org-src-do-key-sequence-at-code-block "e"))

  (defun hk/insert-org-from-html-clipboard ()
    "Insert html from clipboard and convert into org-mode using pandoc."
    ;; credits to u/jsled
    (interactive)
    (require 'org-web-tools)
    (let* ((html (shell-command-to-string "wl-paste"))
           (html-sanitized (hk/sanitize-html html)))
      (insert (org-web-tools--html-to-org-with-pandoc html-sanitized))))

  ;; https://www.reddit.com/r/emacs/comments/7m6nwo/comment/drt7mmr
  (defun hk/org-capture-template-goto-link ()
    "Set point for capturing at what capture target file+headline with headline set to %l would do."
    (org-capture-put :target (list 'file+headline (nth 1 (org-capture-get :target)) (org-capture-get :annotation)))
    (org-capture-put-target-region-and-position)
    (let ((hd (nth 2 (org-capture-get :target))))
      (goto-char (point-min))
      (if (re-search-forward
           (format org-complex-heading-regexp-format (regexp-quote hd))
           nil t)
          (beginning-of-line)
        (goto-char (point-max))
        (or (bolp) (insert "\n"))
        (save-excursion
          (insert "* " hd " :webclip:" "\n"
                  ":PROPERTIES:" "\n"
                  ":ENTERED_ON: [" (format-time-string "%Y-%m-%d %a") "]\n"
                  ":END:" "\n" "\n"))
        (beginning-of-line))))

  (defun hk/sanitize-html (html)
    (with-temp-buffer
      (insert html)
      (cl-loop for (match . replace) in (list (cons "&nbsp;" " "))
               do (progn
                    (goto-char (point-min))
                    (while (re-search-forward match nil t)
                      (replace-match replace))))
      (buffer-string)))

  (defun hk/org-capture-html ()
    (require 'org-web-tools)
    (let* ((html (plist-get org-store-link-plist :initial))
           (html-sanitized (hk/sanitize-html html)))
      (org-web-tools--html-to-org-with-pandoc html-sanitized)))

  (defun hk/insert-org-from-leetcode ()
    "Insert org-mode formatted leetcode problem from url."
    (interactive)
    (let* ((not-nil-and-not-a-buffer-means-current-buffer 1)
           (dst-buffer not-nil-and-not-a-buffer-means-current-buffer)
           (leetcode-url (read-from-minibuffer "Leetcode slug: "))
           (command (concat "leetcode-to-org-mode.py " leetcode-url)))
      (shell-command command dst-buffer))))

(use-package ox-pandoc
  :after org)

(use-package org-ql
  :after org)

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

(use-package org-noter
  :after org
  :custom
  (org-noter-notes-search-path '("~/documents/org/"))
  (org-noter-default-notes-file-names '("notes.org")))

(use-package org-nix-shell
  :after org
  :hook (org-mode . org-nix-shell-mode))

(use-package org-download
  :after org
  :custom
  (org-download-method 'attach)
  (org-download-screenshot-method "flameshot gui --raw > %s"))

(use-package org-web-tools
  :bind (:map org-mode-map
              ("C-c y" . org-web-tools-insert-link-for-url))

  :config
  (with-eval-after-load 'embark
    (bind-key "O" #'hk/org-web-tools-read-url-as-org embark-url-map))

  :preface
  (defun hk/org-web-tools-read-url-as-org (url)
    "Read URL's readable content in an Org buffer."
    (let ((entry (org-web-tools--url-as-readable-org url)))
      (when entry
        (switch-to-buffer url)
        (org-mode)
        (insert entry)
        ;; Set buffer title
        (goto-char (point-min))
        (rename-buffer (cdr (org-web-tools--read-org-bracket-link))))))

  (defun hk/org-web-tools-url-as-denote (&optional url)
    "Create denote entry of URL's web page content.
Content is processed with `eww-readable' and Pandoc.
Takes optional URL or gets it from the clipboard."
    (interactive)
    (require 'denote)
    (-let* ((url (or url (org-web-tools--get-first-url)))
            (dom (plz 'get url :as #'org-web-tools--sanitized-dom))
            ((title . readable) (org-web-tools--eww-readable dom))
            (title (org-web-tools--cleanup-title (or title "")))
            (converted (org-web-tools--html-to-org-with-pandoc readable))
            (link (org-link-make-string url title))
            (timestamp (format-time-string (org-time-stamp-format 'with-time 'inactive))))
      (denote-create-note title '("article" "ref") 'org)
      (insert converted)
      (save-buffer))))

(use-package org-rich-yank
  :demand t
  :bind (:map org-mode-map
              ("C-M-y" . org-rich-yank))
  :custom
  (org-rich-yank-format-paste #'hk/org-rich-yank-format-paste)
  :init
  (defun hk/org-rich-yank-format-paste (language contents link)
    "Based on `org-rich-yank--format-paste-default'."
    (format "#+begin_src %s\n%s\n#+end_src\n#+comment: %s"
            language
            (org-rich-yank--trim-nl contents)
            link)))

(use-package org-appear
  :after org
  :custom
  (org-appear-autosubmarkers t)
  (org-appear-autoentities t)
  (org-appear-autolinks t)
  (org-appear-autokeywords t))

(use-package org-fragtog
  :after org
  :hook (org-mode . org-fragtog-mode))

(use-package org-modern
  :after org
  :hook
  (org-mode . global-org-modern-mode)
  :custom
  (org-modern-table nil))

(use-package laas
  :after org
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

(use-package expand-region
  :config
  (with-eval-after-load 'meow
    (meow-normal-define-key '("w" . er/expand-region))))

(use-package embrace
  ;; Add/Change/Delete pairs based on expand-region.
  :bind (("M-)" . 'embrace-commander))  ; orig. move-past-close-and-reindent
  :hook (LaTeX-mode . embrace-LaTeX-mode)
  :hook (org-mode   . embrace-org-mode-hook)
  :config
  (with-eval-after-load 'meow
    (meow-normal-define-key '("(" . embrace-commander))))

(use-package string-edit-at-point
  ;; Edit strings normally and get it escaped automatically
  :config
  (with-eval-after-load 'meow
    (meow-normal-define-key '("ki" . string-edit-at-point))))

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

(use-package forge
  ;; Forge allows you to work with Git forges, such as Github and Gitlab, from the comfort of Magit and the rest of Emacs.
  :after magit)

(use-package git-gutter
  :diminish
  :bind
  (("C-%"     . #'git-gutter:previous-hunk)
   ("C-^"     . #'git-gutter:next-hunk)
   ("C-c g"   . #'hk/git-gutter-hydra/body))
  :config
  (global-git-gutter-mode +1)
  (with-eval-after-load 'hydra
    (defhydra hk/git-gutter-hydra ()
      "git-gutter hydra."
      ("n" git-gutter:next-hunk "Next")
      ("p" git-gutter:previous-hunk "Previous")
      ("e" git-gutter:previous-hunk "Previous")
      ("h" git-gutter:mark-hunk "Mark")
      ("d" git-gutter:popup-hunk "Popup")
      ("s" git-gutter:stage-hunk "Stage")
      ("k" git-gutter:revert-hunk "Revert")
      ("m" magit "Magit"))))

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

(use-package emacs ;; treesitter
  :ensure nil
  :config
  (setq major-mode-remap-alist
        '((bash-mode . bash-ts-mode)
          (python-mode . python-ts-mode)
          (json-mode . json-ts-mode)
          (c-mode . c-ts-mode)
          (c++-mode . c++-ts-mode)
          (c-or-c++-mode . c-or-c++-ts-mode))))

(use-package eglot
  :hook
  (((eglot-managed-mode) . hk/eglot-capf))
  :bind
  (:map eglot-mode-map
        ("C-c C" . eglot)
        ("C-c A" . eglot-code-actions)
        ("C-c R" . eglot-rename)
        ("M-r"   . eglot-rename)
        ("C-c F" . eglot-format))
  :custom
  (eglot-send-changes-idle-time 0.1)
  :config
  (fset #'jsonrpc--log-event #'ignore)  ; massive perf boost---don't log every event

  ;; Eglot sometimes needs to know where to find language servers
  (add-to-list
   'eglot-server-programs
   '((c-mode c-ts-mode c++-mode c++-ts-mode)
     "clangd" "--completion-style=detailed" "--clang-tidy" "--function-arg-placeholders=false" "--header-insertion=never" "--malloc-trim"))
  (add-to-list
   'eglot-server-programs '((nix-mode) "nil"))

  :preface
  (defun hk/eglot-capf ()
    "Use eglot completions alongside cape and tempel."
    (setq-local completion-at-point-functions
              (list (cape-capf-super
                     #'eglot-completion-at-point
                     #'tempel-complete
                     #'cape-dabbrev-min-3
                     #'cape-file))))
  )

(use-package citre
  ;; ctags - useful if lsp is not available
  :hook
  ((citre-mode) . hk/citre-capf)
  :bind
  (:map citre-mode-map
        ("C-x c n" . hk/citre-jump+)
        ("C-x c N" . citre-jump-back)
        ("C-x c p" . citre-peek)
        ("C-x c u" . citre-update-this-tags-file))
  :custom
  (citre-default-create-tags-file-location 'global-cache)
  (citre-use-project-root-when-creating-tags t)
  (citre-tags-completion-case-sensitive nil)
  (citre-tags-substr-completion t)
  (citre-ctags-program    (file-truename (executable-find "ctags")))
  (citre-readtags-program (file-truename (executable-find "readtags")))
  :init
  (require 'citre-config)
  :preface
  (defun hk/citre-capf ()
    (setq citre-ctags-program    (file-truename (executable-find "ctags")))
    (setq citre-readtags-program (file-truename (executable-find "readtags")))
    (setq-local completion-at-point-functions
                '(citre-completion-at-point
                  cape-dabbrev-min-3
                  cape-file)))

   (defun hk/citre-jump+ ()
     "Jump to the definition of the symbol at point. Fallback to `xref-find-definitions'."
     (interactive)
     (condition-case _
         (citre-jump)
       (error (call-interactively #'xref-find-definitions)))))

(use-package envrc
  :config
  (envrc-global-mode))

(use-package nix-mode
  :mode (("\\.nix\\'" . nix-mode)))

(use-package emacs ;; c-mode
  ;; c-mode, c-ts-mode config
  :ensure nil
  :bind ("C-c o w" . hk/launch-whitebox)
  :config
  (setopt c-basic-offset 2)
  (add-hook 'c-mode-hook 'hk/c-mode-hook)
  (add-hook 'c-ts-mode-hook 'hk/c-mode-hook)
  :preface
  (defun hk/c-mode-hook ()
    (c-set-offset 'substatement 0)
    (c-set-offset 'substatement-open 0)
    (setq-local outline-regexp " *//\\(-+\\)"))

  (defun hk/c-ts-get-return-type ()
    (when-let* ((defun-node (treesit-defun-at-point))
                (return-type (treesit-node-child-by-field-name defun-node "type")))
      (treesit-node-text return-type)))

  (defun hk/c-ts-refactor-to-result-return ()
    (interactive)
    (when-let* ((defun-node (treesit-defun-at-point))
                (return-type (treesit-node-child-by-field-name defun-node "type"))
                (body (treesit-node-child-by-field-name defun-node "body"))
                (first-child (treesit-node-child body 1))
                )
      (progn
        (while (treesit-node-match-p first-child "\\(?:comment\\)")
          (setq first-child (treesit-node-next-sibling first-child)))
        (goto-char (treesit-node-start first-child))
        (insert (treesit-node-text return-type) " result = "
                (if (treesit-node-match-p return-type "\\(?:primitive_type\\)")
                    "0" "{0}")
                ";\n")
        (goto-char (treesit-node-start
                    (treesit-node-get (treesit-node-child-by-field-name (treesit-defun-at-point) "body")
                      '((child -1 nil)))))
        (open-line 1)
        (insert "return result;")
        (prog-fill-reindent-defun)
        )))

  (defvar hk/whitebox-directory (file-truename "~/documents/whitebox/whitebox_v0.122.0/"))
  (defun hk/launch-whitebox ()
    (interactive)
    (shell-command (concat "hyprctl dispatch exec " hk/whitebox-directory "whitebox"))
    (load-file (concat hk/whitebox-directory "editor_plugins/emacs/whitebox.el"))
    (when (derived-mode-p '(c-mode c-ts-mode)) (whitebox-mode))))

(use-package glsl-mode)

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

(use-package sqlite-mode
  :ensure nil
  :init
  (add-to-list 'magic-mode-alist '("SQLite format 3\x00" . hk/sqlite-view-file-magically))
  :preface
  (defun hk/sqlite-view-file-magically ()
    "Runs `sqlite-mode-open-file' on the file name visited by the
current buffer, killing it."
    (require 'sqlite-mode)
    (let ((file-name buffer-file-name))
      (kill-current-buffer)
      (sqlite-mode-open-file file-name))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Applications and tools
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package eat
  ;; Terminal emulator
  :bind (("<f1>" . 'eat))
  :config
  (use-package meow
    :config
    (dolist (state '((eat-mode . insert)))
      (add-to-list 'meow-mode-state-list state))))

(use-package dired
  :ensure nil
  ;; File manager
  :hook (dired-after-readin . hk/truncate-lines)
  :custom
  (delete-by-moving-to-trash t)
  (mouse-drag-and-drop-region-cross-program t)
  (dired-dwim-target t "copy/move operations based on other Dired window")
  (dired-mouse-drag-files t "enable drag-and-drop")
  (dired-listing-switches "-l --almost-all --human-readable --group-directories-first --no-group")
  (dired-create-destination-dirs 'ask)
  (dired-create-destination-dirs-on-trailing-dirsep t)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-auto-revert-buffer t))

(use-package gptel
  ;; AI assistant
  :preface
  (defun hk/gptel-setup ()
    (interactive)
    (setq
     github-access-token (shell-command-to-string "pass show dev/github-ai-access-token")
     gptel-model   'gpt-4o
     gptel-backend (gptel-make-openai "Github Models"
                     :host "models.inference.ai.azure.com"
                     :endpoint "/chat/completions"
                     :stream t
                     :key github-access-token
                     :models '("gpt-4o" "gpt-4o-mini"))))
  :custom
  (gptel-default-mode 'org-mode)
  :config
  (require 'gptel-gh)
  (setq gptel-model 'claude-sonnet-4
        gptel-backend (gptel-make-gh-copilot "Copilot")))

(use-package eww
  ;; Web browser
  :ensure nil
  :hook (eww-after-render . hk/eww-redirect-to-bloatfree-alt)
  :hook (eww-after-render . eww-readable)
  :bind
  (:map eww-mode-map
        ("n" . scroll-up-line)
        ("e" . scroll-down-line)
        ("I" . #'hk/eww-toggle-images))
  :config
  ;; Use & to open externally if eww can't handle the page
  (setq browse-url-browser-function #'eww-browse-url)
  (setq browse-url-generic-program "firefox")

  :preface
  (defun hk/eww-toggle-images ()
    "Toggle whether images are loaded and reload the current page."
    (interactive)
    (setq-local shr-inhibit-images (not shr-inhibit-images))
    (eww-reload t)
    (message "Images are now %s"
             (if shr-inhibit-images "off" "on")))

  (defun hk/map-url-to-bloatfree-alt (url)
    (cond
     ((string-match "www\\.reddit\\.com" url)
      (s-replace "www.reddit.com" "old.reddit.com" url))
     ((string-match "youtube\\.com" url)
      (s-replace "www.youtube.com" "invidious.io.lol" url))
     ((string-match "x\\.com" url)
      (s-replace "x.com" "xcancel.com" url))
     ((string-match "twitter\\.com" url)
      (s-replace "twitter.com" "xcancel.com" url))))

  (defun hk/eww-redirect-to-bloatfree-alt ()
    (when-let* ((url (eww-current-url))
                (alt-url (hk/map-url-to-bloatfree-alt url)))
      (message "Redirecting to bloatfree alt. " alt-url)
      (eww alt-url))))

(use-package journalctl-mode
  ;; View systemd's journalctl within Emacs
  :bind ("C-c o j" . journalctl))

(use-package pdf-tools
  :custom
  (pdf-view-display-size 'fit-page)
  :config
  (pdf-tools-install))

(use-package devdocs
  :bind (("C-c D" . 'devdocs-lookup))
  :custom
  (devdocs-data-dir (concat hk/cache-dir "devdocs/")))

(use-package elfeed
  ;; rss reader
  :bind ("C-c o e" . elfeed)
  :custom
  (elfeed-sort-order 'ascending)
  (elfeed-search-filter "@6-months-ago +unread +mustread")

  :config
  (use-package embark
    :preface
    (defun embark-elfeed-target-url ()
      "Target the URL of the elfeed entry at point."
      (when-let (((derived-mode-p 'elfeed-search-mode))
                 (entry (elfeed-search-selected :ignore-region))
                 (url (elfeed-entry-link entry)))
        (elfeed-search-untag-all-unread)
        `(url ,url ,(line-beginning-position) . ,(line-end-position))))
    :config
    (add-to-list 'embark-target-finders #'embark-elfeed-target-url))
  )

(use-package elfeed-org
  ;; Load rss feeds from org file
  :after elfeed
  :config
  (setq rmh-elfeed-org-files (list (concat org-directory "elfeed.org")))
  (elfeed-org)) ;; Hook up elfeed-org to read the configuration when elfeed starts

(use-package elfeed-tube
  :after elfeed
  :bind
  (:map elfeed-show-mode-map
        ("F" . elfeed-tube-fetch)
        ([remap save-buffer] . elfeed-tube-save)
        ("C-o" . elfeed-tube-mpv)
        :map elfeed-search-mode-map
        ("F" . elfeed-tube-fetch)
        ([remap save-buffer] . elfeed-tube-save))
  :config
  (elfeed-tube-setup)
  :preface
  (defun hk/mpv-play-url-at-point ()
    "Open the URL at point in mpv."
    (interactive)
    (let ((url (thing-at-point-url-at-point)))
      (when url
        (async-shell-command (concat "umpv \"" url "\"") nil nil)))))

(use-package elfeed-tube-mpv
  :after elfeed-tube
  :bind
  (:map elfeed-show-mode-map
        ("C-c C-f" . elfeed-tube-mpv-follow-mode)
        ("C-c C-w" . elfeed-tube-mpv-where)))

(use-package notmuch
  :defer t
  :bind (("C-x m" . notmuch))
  :custom
  (sendmail-program "msmtp")
  (message-directory "~/mail/")
  (message-send-mail-function 'message-send-mail-with-sendmail)
  (notmuch-fcc-dirs '(("anton@hakanssn.com" . "personal/Sent")
                      ("anton.hakanssson98@gmail.com" . "gmail/[Gmail]/Sent Mail")))

  :custom
  (message-cite-reply-position 'below)
  (message-kill-buffer-on-exit t)
  (notmuch-search-oldest-first nil "Show new mail first.")

  :custom
  (notmuch-show-logo nil)

  :config
  (with-eval-after-load 'meow
    (dolist (state '((notmuch-hello-mode . motion)
                     (notmuch-search-mode . motion)
                     (notmuch-tree-mode . motion)
                     (notmuch-show-mode . motion)))
      (add-to-list 'meow-mode-state-list state))))

(use-package ol-notmuch
  :after (org notmuch))
(use-package consult-notmuch
  :requires notmuch)

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

(use-package spacious-padding
  :hook (after-init-hook . spacious-padding-mode))

(use-package mixed-pitch)

(use-package nerd-icons)

(use-package kind-icon
  ;; Display completion kind
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; Compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package ef-themes
  :hook (after-init . (lambda () (interactive) (load-theme 'ef-light t)))
  :custom
  (ef-themes-mixed-fonts t)
  (ef-themes-headings
   '((1 . (variable-pitch 1.3))
     (2 . (1.1))
     (agenda-date . (1.1))
     (agenda-structure . (variable-pitch light 1.3))
     (t . (1.1))))

  ;; Font - Iosevka
  :config
  (modify-all-frames-parameters '((font . "Iosevka-18"))))

(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode)
  :diminish)

(use-package emacs ;; compilation
  :ensure nil
  :config
  ;; By default, compilation doesn't support ANSI colors. Enable them for compilation.
  (use-package ansi-color
    :ensure nil
    :hook (compilation-filter . ansi-color-compilation-filter)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Scratch Area
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun hk/enable-impermanent-melpa-use-package ()
  ;; I configure Emacs decoratively using Nix but sometimes you want to try things out temporally.
  (interactive)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (package-initialize)
  (setq use-package-always-ensure t))

(provide 'init)
;;; init.el ends here

;; Local Variables:
;; outline-regexp: "\(use-package.*"
;; End:
