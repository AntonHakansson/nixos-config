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
  (blink-cursor-mode -1)                             ; Steady cursor
  (push '(vertical-scroll-bars) default-frame-alist) ; Remove vertical scroll bar

  ;; Buffers, Lines, and indentation
  (setopt display-line-numbers-type 'relative) ; Relative line numbers
  (setopt indent-tabs-mode nil)                ; Use spaces instead of tabs
  (setopt tab-width 2)
  (setopt x-underline-at-descent-line nil)  ; Prettier underlines
  (setopt show-trailing-whitespace nil)     ; By default, don't underline trailing spaces
  (setopt indicate-buffer-boundaries 'left) ; Show buffer top and bottom in the margin
  (setopt switch-to-buffer-obey-display-actions t) ; Make switching buffers more consistent

  ;; Quickly access recent files
  (setopt recentf-max-menu-items 30)    ; bump the limits a bit
  (setopt recentf-max-saved-items 256)
  (add-hook 'after-init-hook #'recentf-mode) ; Turn on recentf mode

  ;; Misc. Emacs tweaks
  (fset 'yes-or-no-p 'y-or-n-p)         ; Shorter confirmation
  (setopt isearch-lazy-count t)
  (setopt delete-by-moving-to-trash t)
  (setopt set-mark-command-repeat-pop t) ; after =C-u C-SPC=, keep ctrl down and press space to cycle mark ring
  (setopt bookmark-save-flag 1)       ; Write bookmark file when bookmark list is modified

  ;; Keybinds
  (global-set-key (kbd "C-(") 'previous-buffer)
  (global-set-key (kbd "C-)") 'next-buffer)
  (global-set-key (kbd "<f1>") 'shell)
  (global-set-key (kbd "<f5>") 'recompile)
  (global-set-key (kbd "<f7>") 'scroll-lock-mode)
  ;; (global-set-key (kbd "M-p") 'backward-paragraph)
  ;; (global-set-key (kbd "M-n") 'forward-paragraph)
  (keymap-set global-map "<remap> <list-buffers>" 'ibuffer) ;; C-x C-b

  ;; ibuffer
  (setopt ibuffer-expert t)             ; stop yes no prompt on delete
  (setopt ibuffer-saved-filter-groups
	        '(("default"
		         ("dired" (mode . dired-mode))
		         ("org"   (and
                       (mode . org-mode)
                       ;; exclude GTD and scratch buffer
                       (not (or (filename . "^.+/gtd/.+")
                                (name . "^\\*scratch\\*$")))))
		         ("magit" (name . "^magit"))
		         ("planner" (or
				                 (name . "^\\*Calendar\\*$")
				                 (name . "^\\*Org Agenda\\*")
                         (filename . "^.+gtd.+")))
             ("config" (filename . "/nixos-config/"))
		         ("emacs" (or
			                 (name . "^\\*scratch\\*$")
			                 (name . "^\\*Messages\\*$"))))))

  (add-hook 'ibuffer-mode-hook
	          (lambda ()
	            (ibuffer-switch-to-saved-filter-groups "default")))


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
   ("M-s l" . 'consult-line)            ; needed by consult-line to detect isearch
   ("M-s L" . 'consult-line-multi)      ; needed by consult-line to detect isearch
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
  (("C-." . embark-act)
   ("C-;" . embark-dwim))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
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

  :config
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
   '("e" . "H-e")                      ; To execute original e in MOTION state, use SPC e.
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

  ;; Register HTML tag as a meow object/thing
  (meow-thing-register 'angle '(regexp "<" ">") '(regexp "<" ">"))
  (add-to-list 'meow-char-thing-table '(?a . angle))

  (setq meow-replace-state-name-list
          '((normal . "N")
            (motion . "M")
            (keypad . "K")
            (insert . "I")
            (beacon . "B")))
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
    ("b" dumb-jump-back "Back")))

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
  :hook (((prog-mode text-mode tex-mode) . corfu-mode)
         ((shell-mode eshell-mode) . hk/corfu-shell-settings)
         (minibuffer-setup . hk/corfu-enable-always-in-minibuffer))
  :custom
  (corfu-auto t "Enable Auto Completion")
  (corfu-auto-delay 0.05 "Disable completion suggestion delay")
  (corfu-auto-prefix 3 "Trigger completion early")
  (corfu-cycle t "Cycle candidates")
  :bind
  (:map corfu-map
        ("RET" . nil)     ; return should insert a newline - not complete the sugggestion.
        ("<escape>" . (lambda ()
                        (interactive)
                        (corfu-quit)
                        (meow-normal-mode))))
  :init
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
  :config
  (setq cape-dabbrev-check-other-buffers t
        dabbrev-ignored-buffer-regexps
        '("\\.\\(?:pdf\\|jpe?g\\|png\\|svg\\|eps\\)\\'"
          "^ "
          "\\(TAGS\\|tags\\|ETAGS\\|etags\\|GTAGS\\|GRTAGS\\|GPATH\\)\\(<[0-9]+>\\)?")
        dabbrev-upcase-means-case-search t)

  ;; Add useful defaults completion sources from cape
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block) ; Complete in org, markdown code block
  (defalias 'cape-dabbrev-min-3 (cape-capf-prefix-length #'cape-dabbrev 3))
  (add-to-list 'completion-at-point-functions #'cape-dabbrev-min-3)

  ;; Quickly duplicate line from buffer
  (global-set-key (kbd "C-t") 'cape-line) ; orig. transpose-chars
  (global-set-key (kbd "C-S-t") 'hippie-expand) ; orig. transpose-chars
  )

(use-package pcmpl-args
  ;; Extend Pcomplete with completions from man pages.
  ;; There is a built-in pcomplete-from-help that parses '--help' output of command.
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Notes (org-mode, etc)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun hk/text-capf ()
  "Set up completion-at-point for writing"
  (setq-local completion-at-point-functions
              '(cape-dabbrev-min-3
                cape-elisp-block
                cape-file)))

(add-hook 'text-mode-hook 'hk/text-capf)

(use-package denote
  :demand t
  :after org
  :hook (dirvish-mode . denote-dired-mode)
  :bind
  (("C-c C-n" . denote)
   ("C-c o n" . denote-open-or-create)
   ("C-c o N" . hk/diary))
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
  (denote-templates `((diary .   "* TODO Morning Checklist

- [ ] Sunlight + Water + Meditate
- [ ] Bicycle + [[file:~/videos][Video]] | Workout
- [ ] Cold Shower
- [ ] Breakfast
- [ ] Process [[elisp:(mu4e)][Mail]]
- [ ] Process [[file:~/documents/org/gtd/inbox.org][Inbox]]
- [ ] Process yesterday
- [ ] Plan day
  - [ ] Free recall practice
  - [ ]
- [ ] Clock in!

* TODO Preperation for tomorrow

- [ ] Overnight oats
- [ ] [[file:~/videos][Video]] entertainment for bicycle workout
- [ ] [[file:~/documents/books/audio][Audio]] entertainment for chores")))
  :config
  (unless (hk/diary-today-file)
    (hk/diary))
  :init
  (defun hk/diary-today-file ()
    (let* ((today (format-time-string "%A %e %B %Y"))
           (sluggified (denote-sluggify today))
           (file (car (denote-directory-files-matching-regexp sluggified))))
      file))
  (defun hk/diary ()
    "Create an entry tagged 'diary' with the date as its title.
If a diary for the current day exists, visit it.  If multiple
entries exist, prompt with completion for a choice between them.
Else create a new file.

The file is added to 'org-agenda-files' if not present."
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
        (denote today '("diary") nil nil nil 'diary))
       ))
    (let ((file (hk/diary-today-file)))
      (unless (member file org-agenda-files)
        (add-to-list 'org-agenda-files file)))
    ))

(use-package htmlize)
(use-package gnuplot)
(require 'gnuplot-context) ; org mode error: run-hooks: Symbol’s function definition is void: gnuplot-context-sensitive-mode

(defun hk/truncate-lines ()
  (message "truncating lines")
  (toggle-truncate-lines +1))

(use-package org
  :hook (org-agenda-mode . olivetti-mode)
  :hook (org-agenda-finalize . hk/truncate-lines)
  :hook (org-after-refile-insert . org-save-all-org-buffers)
  :bind
  (("C-c a"  . org-agenda)
   ("C-c c"  . org-capture)
   ("C-c l"  . org-store-link)
   :map org-mode-map
   ("C-," . nil)  ; Orig. cycle agenda buffers
   ("C-'" . nil)  ; Orig. cycle agenda buffers
   :map org-src-mode-map
   ("C-c C-v" . org-src-do-key-sequence-at-code-block))
  :custom
  (org-directory      "~/documents/org/")
  (org-return-follows-link t)
  (org-startup-indented t)
  (org-startup-with-inline-images t)
  (org-cycle-hide-block-startup t)
  (org-startup-folded "show2levels") ; apparently default showeverything overrides hide-block
  (org-image-actual-width nil) ; Use width from #+attr_org and fallback to original width.
  (org-fold-catch-invisible-edits 'smart)
  (org-use-speed-commands (lambda () ; when point is on any star at the beginning of the headline
                            (and (looking-at org-outline-regexp)
                                 (looking-back "^\\**"))))
  (org-footnote-section nil) ; define footnotes locally at end of subtree
  (org-id-method 'ts)
  (org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id)
  ;; Put attachment in: <org-attach-directory>/year-month/<rest>
  (org-attach-id-to-path-function-list '(org-attach-id-ts-folder-format
                                         org-attach-id-uuid-folder-format
                                         org-attach-id-fallback-folder-format))
  (org-attach-use-inheritance t) ; always respect parent IDs
  (org-format-latex-options (plist-put org-format-latex-options :scale 1.3)) ; increase scale of latex fragments
  :custom
  (org-agenda-files (mapcar (lambda (f) (concat org-directory "gtd/" f)) '("inbox.org" "projects.org" "repeaters.org" "someday.org")))
  (calendar-date-style 'european)
  (org-agenda-window-setup 'current-window)
  (org-agenda-time-grid '((daily today require-timed) (600 1200 1800 2200) "" ""))
  (org-agenda-current-time-string "<-")
  (org-agenda-block-separator (kbd " "))
  (org-agenda-tags-column 90)           ; play nice with olivetti-mode
  (org-deadline-warning-days 30)
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
       (tags-todo "someday//TODO" ((org-agenda-overriding-header "Someday:")))
       ))))
  (org-agenda-prefix-format
        '((agenda . " %i %?-12t% s")
          (todo . " %i ")
          (tags . " %i ")
          (search . " %i %-12:c")))
  :config
  (use-package svg-lib
    :config
    (setq org-agenda-category-icon-alist
          `(("inbox"     ,(concat svg-lib-icons-dir "material_inbox.svg") nil nil :ascent center :scale 0.8)
            ("projects"  ,(concat svg-lib-icons-dir "material_description.svg") nil nil :ascent center :scale 0.8)
            ("someday"   ,(concat svg-lib-icons-dir "material_lightbulb-on-90.svg") nil nil :ascent center :scale 0.8)
            ("repeaters" ,(concat svg-lib-icons-dir "material_restart.svg") nil nil :ascent center :scale 0.8)
            ("home"      ,(concat svg-lib-icons-dir "material_home.svg") nil nil :ascent center :scale 0.8)
            ("comp"      ,(concat svg-lib-icons-dir "material_laptop.svg") nil nil :ascent center :scale 0.8)
            ("read"      ,(concat svg-lib-icons-dir "material_book.svg") nil nil :ascent center :scale 0.8)
            ("uni"       ,(concat svg-lib-icons-dir "material_school.svg") nil nil :ascent center :scale 0.8)
            ("birthday"  ,(concat svg-lib-icons-dir "material_cake.svg") nil nil :ascent center :scale 0.8)
            (".*_diary"  ,(concat svg-lib-icons-dir "material_weather-sunset.svg") nil nil :ascent center :scale 0.8)
            ))
    )
  :custom
  (org-babel-results-keyword "results" "Make babel results blocks lowercase")
  (org-confirm-babel-evaluate nil)
  (org-babel-load-languages
   (mapcar (lambda (e) (cons e t))
           '(awk calc C css emacs-lisp haskell js latex lisp makefile org perl plantuml python ruby shell sql sqlite)))
  :custom
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n!)" "|" "DONE(d)")
     (sequence "WAIT(w@/!)" "|" "CANCELLED(c@/!)")))
  (org-log-done 'time)
  (org-log-into-drawer 't "Insert state changes into a drawer LOGBOOK")
  (org-capture-templates
   '(("t" "Todo [inbox]" entry (file "gtd/inbox.org")
      "* TODO %?\n:PROPERTIES:\n:ENTERED_ON: %U\n:END:\n%i\n")
     ("T" "Tickler" entry
      (file "gtd/repeaters.org")
      "* %i%? \n %U")
     ("a" "Anki Basic" entry (file+headline "anki.org" "Scratch")
      "* %<%H:%M>\n:PROPERTIES:\n:ANKI_NOTE_TYPE: Basic\n:ANKI_DECK: Mega\n:END:\n** Front\n%?\n** Back\n")
     ("w" "Web" entry (file+function "gtd/inbox.org" hk/org-capture-template-goto-link)
      "* %<%H:%M>\n%(hk/org-capture-html)\n" :immediate-finish t)
     ("W" "Webclip" entry (file+headline "gtd/inbox.org" "Unsorted Webclips")
      "* %? :webclip:\n:PROPERTIES:\n:ENTERED_ON: %U\n:END:\n%(hk/insert-org-from-html-clipboard)")
     ))
  :custom
  (org-refile-targets '((nil :maxlevel . 9)
                        (org-agenda-files :maxlevel . 3)))
  (org-refile-use-outline-path 't "Show full outline of target")
  :config
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

  ; https://www.reddit.com/r/emacs/comments/7m6nwo/comment/drt7mmr
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

(use-package org ; ox-extra ignore-headlines
  :config (add-hook 'org-export-filter-parse-tree-functions #'org-export-ignore-headlines)
  :init
  ;; During export headlines which have the "ignore" tag are removed
  ;; from the parse tree.  Their contents are retained (leading to a
  ;; possibly invalid parse tree, which nevertheless appears to function
  ;; correctly with most export backends) all children headlines are
  ;; retained and are promoted to the level of the ignored parent
  ;; headline.
  ;;
  ;; This makes it possible to add structure to the original Org-mode
  ;; document which does not effect the exported version, such as in the
  ;; following examples.
  ;;
  ;; Wrapping an abstract in a headline
  ;;
  ;;     * Abstract                        :ignore:
  ;;     #+LaTeX: \begin{abstract}
  ;;     #+HTML: <div id="abstract">
  ;;
  ;;     ...
  ;;
  ;;     #+HTML: </div>
  ;;     #+LaTeX: \end{abstract}
  ;;
  ;; Placing References under a headline (using ox-bibtex in contrib)
  ;;
  ;;     * References                     :ignore:
  ;;     #+BIBLIOGRAPHY: dissertation plain
  ;;
  ;; Inserting an appendix for LaTeX using the appendix package.
  ;;
  ;;     * Appendix                       :ignore:
  ;;     #+LaTeX: \begin{appendices}
  ;;     ** Reproduction
  ;;     ...
  ;;     ** Definitions
  ;;     #+LaTeX: \end{appendices}
  ;;
  (defun org-export-ignore-headlines (data backend info)
    "Remove headlines tagged \"ignore\" retaining contents and promoting children.
Each headline tagged \"ignore\" will be removed retaining its
contents and promoting any children headlines to the level of the
parent."
    (org-element-map data 'headline
      (lambda (object)
        (when (member "ignore" (org-element-property :tags object))
          (let ((level-top (org-element-property :level object))
                level-diff)
            (mapc (lambda (el)
                    ;; recursively promote all nested headlines
                    (org-element-map el 'headline
                      (lambda (el)
                        (when (equal 'headline (org-element-type el))
                          (unless level-diff
                            (setq level-diff (- (org-element-property :level el)
                                                level-top)))
                          (org-element-put-property el
                                                    :level (- (org-element-property :level el)
                                                              level-diff)))))
                    ;; insert back into parse tree
                    (org-element-insert-before el object))
                  (org-element-contents object)))
          (org-element-extract-element object)))
      info nil)
    (org-extra--merge-sections data backend info)
    data)

  (defun org-extra--merge-sections (data _backend info)
    (org-element-map data 'headline
      (lambda (hl)
        (let ((sections
               (cl-loop
                for el in (org-element-map (org-element-contents hl)
                              '(headline section) #'identity info)
                until (eq (org-element-type el) 'headline)
                collect el)))
          (when (and sections
                     (> (length sections) 1))
            (apply #'org-element-adopt-elements
                   (car sections)
                   (cl-mapcan (lambda (s) (org-element-contents s))
                              (cdr sections)))
            (mapc #'org-element-extract-element (cdr sections)))))
      info)))

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
  :after org-capture
  :bind (:map org-mode-map
              ("<f12>" . anki-editor-cloze-region-dont-incr)
              ("<f11>" . anki-editor-cloze-region-auto-incr)
              ("<f10>" . anki-editor-reset-cloze-number)
              ("<f9>"  . anki-editor-push-tree))
  :hook (org-capture-after-finalize . anki-editor-reset-cloze-number) ; Reset cloze-number after each capture.
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
  (anki-editor-reset-cloze-number)
  :init
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
    (anki-editor-reset-cloze-number)))

(use-package org-download
  :custom
  (org-download-method 'attach)
  (org-download-screenshot-method "flameshot gui --raw > %s"))

(use-package org-web-tools
  :bind (:map org-mode-map
              ("C-c y" . org-web-tools-insert-link-for-url))
  :config
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

(use-package idle-org-agenda
  :after org-agenda
  :ensure t
  :custom
  (idle-org-agenda-key "g")
  (idle-org-agenda-interval (* 5 60))
  :config (idle-org-agenda-mode))

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
  :bind (("M-)" . 'embrace-commander))  ; orig. move-past-close-and-reindent
  :hook (LaTeX-mode . embrace-LaTeX-mode)
  :hook (org-mode   . embrace-org-mode-hook)
  :config
  (with-eval-after-load 'meow
    (meow-normal-define-key '("(" . embrace-commander))))

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
  (("C-%"     . #'git-gutter:previous-hunk)
   ("C-^"     . #'git-gutter:next-hunk)
   ("C-c g n" . #'git-gutter:next-hunk)
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
  ((nix-mode . eglot-ensure)
   ((eglot-managed-mode) . hk/eglot-capf))
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
   'eglot-server-programs '((nix-mode) "nil"))

  :init
  (defun hk/eglot-capf ()
    "Use eglot completions alongside cape and tempel."
    (setq-local completion-at-point-functions
              (list (cape-super-capf
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
  :init
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

(use-package nix-mode :mode (("\\.nix\\'" . nix-mode)))

(use-package emacs ;; c-mode
  ;; c-mode, c-ts-mode config
  :ensure nil
  :config
  (setopt c-basic-offset 2)
  (add-hook 'c-mode-hook 'hk/c-mode-hook)
  (add-hook 'c-ts-mode-hook 'hk/c-mode-hook)
  :init
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
        ))))

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
  :config
  (defun ct/sqlite-view-file-magically ()
    "Runs `sqlite-mode-open-file' on the file name visited by the
current buffer, killing it."
    (require 'sqlite-mode)
    (let ((file-name buffer-file-name))
      (kill-current-buffer)
      (sqlite-mode-open-file file-name)))
  (add-to-list 'magic-mode-alist '("SQLite format 3\x00" . ct/sqlite-view-file-magically)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Applications and tools
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package shell-mode
  :ensure nil
  :bind ("C-r" . consult-history))

(use-package dirvish
  ;; File manager
  :bind
  (:map dirvish-mode-map
        ("a"   . 'dirvish-quick-access)
        ("TAB" . 'dirvish-subtree-toggle)
        ("T"   . 'dirvish-layout-toggle)) ; Orig. dired-do-touch
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
  :config
  (setq dirvish-mode-line-format
        '(:left (sort symlink) :right (omit yank index)))
  (setq dirvish-attributes
        '(nerd-icons file-time file-size collapse subtree-state vc-state git-msg))
  (setq dirvish-preview-dispatchers (delete 'pdf dirvish-preview-dispatchers)) ; Remove pdf preview. It is too slow.
  (dirvish-override-dired-mode)
  (require 'dirvish-quick-access)
  (require 'dirvish-extras))

(use-package eww
  ;; Web browser
  :ensure nil
  :hook (eww-mode . olivetti-mode)
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

  :init
  (defun hk/eww-toggle-images ()
    "Toggle whether images are loaded and reload the current page."
    (interactive)
    (setq-local shr-inhibit-images (not shr-inhibit-images))
    (eww-reload t)
    (message "Images are now %s"
             (if shr-inhibit-images "off" "on")))

  (defun hk/map-url-to-bloatfree-alt (url)
    (cond
     ((string-match "reddit\\.com" url)
      (s-replace "www.reddit.com" "redlib.freedit.eu" url))
     ((string-match "youtube\\.com" url)
      (s-replace "www.youtube.com" "invidious.io.lol" url))
     ((string-match "x\\.com" url)
      (s-replace "x.com" "nitter.net" url))
     ((string-match "twitter\\.com" url)
      (s-replace "twitter.com" "nitter.net" url))))

  (defun hk/eww-redirect-to-bloatfree-alt ()
    (when-let* ((url (eww-current-url))
                (alt-url (hk/map-url-to-bloatfree-alt url)))
      (message "Redirecting to bloatfree alt. " alt-url)
      (eww alt-url))))

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
  :init
  (defun hk/mpv-play-url-at-point ()
    "Open the URL at point in mpv."
    (interactive)
    (let ((url (thing-at-point-url-at-point)))
      (when url
        (async-shell-command (concat "umpv \"" url "\"") nil nil)))))

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
  (setq mu4e-contexts
        `(,(make-mu4e-context
            :name "Personal"
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
          ,(make-mu4e-context
            :name "Gmail"
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

(use-package pixel-scroll
  :ensure nil
  :hook (emacs-startup . pixel-scroll-precision-mode)
  :custom
  (pixel-scroll-precision-interpolate-page t))

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
         ("M-'"   . popper-cycle)       ; Orig. abbrev-prefix-mark
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

(use-package mixed-pitch)

(use-package nerd-icons)

(use-package kind-icon
  ;; Display completion kind
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package ef-themes
  ;; :hook (after-init . (lambda () (load-theme 'ef-melissa-light)))
  :custom
  (ef-themes-mixed-fonts t)
  (ef-themes-headings
   '((1 . (variable-pitch 1.3))
     (2 . (1.1))
     (agenda-date . (1.1))
     (agenda-structure . (variable-pitch light 1.3))
     (t . (1.1))))
  :config
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

(use-package olivetti
  ;; Center text for nicer writing and reading
  :defer 3
  :bind (("C-c t z" . olivetti-mode))
  :custom
  (olivetti-body-width 120)
  (fill-column 90))

(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode)
  :diminish)

(use-package emacs ;; compilation
  :ensure nil
  :config
  ;; By default, compilation doesn't support ANSI colors. Enable them for compilation.
  (require 'ansi-color)
  (defun colorize-compilation-buffer ()
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region (point-min) (point-max))))
  (add-hook 'compilation-filter-hook 'colorize-compilation-buffer))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Transient helpers
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package transient
  :ensure nil
  :bind
  (:map isearch-mode-map
        ("C-t" . hk/isearch-menu))
  :init
  (transient-define-prefix hk/isearch-menu ()
    "isearch Menu"
    [["Edit Search String"
      ("e"
       "Edit the search string (recursive)"
       isearch-edit-string
       :transient nil)
      ("w"
       "Pull next word or character word from buffer"
       isearch-yank-word-or-char
       :transient nil)
      ("s"
       "Pull next symbol or character from buffer"
       isearch-yank-symbol-or-char
       :transient nil)
      ("l"
       "Pull rest of line from buffer"
       isearch-yank-line
       :transient nil)
      ("y"
       "Pull string from kill ring"
       isearch-yank-kill
       :transient nil)
      ("t"
       "Pull thing from buffer"
       isearch-forward-thing-at-point
       :transient nil)]

     ["Replace"
      ("q"
       "Start ‘query-replace’"
       isearch-query-replace
       :if-nil buffer-read-only
       :transient nil)
      ("x"
       "Start ‘query-replace-regexp’"
       isearch-query-replace-regexp
       :if-nil buffer-read-only
       :transient nil)]]

    [["Toggle"
      ("X"
       "Toggle regexp searching"
       isearch-toggle-regexp
       :transient nil)
      ("S"
       "Toggle symbol searching"
       isearch-toggle-symbol
       :transient nil)
      ("W"
       "Toggle word searching"
       isearch-toggle-word
       :transient nil)
      ("F"
       "Toggle case fold"
       isearch-toggle-case-fold
       :transient nil)
      ("L"
       "Toggle lax whitespace"
       isearch-toggle-lax-whitespace
       :transient nil)]

     ["Misc"
      ("o"
       "occur"
       isearch-occur
       :transient nil)]]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Scratch Area
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org-timeblock
  :custom
  (org-timeblock-inbox-file (concat org-directory "gtd/" "inbox.org"))
  :config
  (use-package denote
    :config
    (setq org-timeblock-inbox-file (hk/diary-today-file))))

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

(use-package el-easydraw
  ;; A SVG Editor within Emacs. Perfect with wacom tablet for small sketches and thoughts.
  :bind (:map org-mode-map
              ("<f7>" . hk/edraw-insert-link)
         :map edraw-editor-map
              ("@" . hk/edraw-toggle-interval))
  :config
  (with-eval-after-load 'org
    (require 'edraw-org)
    (edraw-org-setup-default))
  ;; When using the org-export-in-background option (when using the
  ;; asynchronous export function), the following settings are
  ;; required. This is because Emacs started in a separate process does
  ;; not load org.el but only ox.el.
  (with-eval-after-load "ox"
    (require 'edraw-org)
    (edraw-org-setup-exporter))
  :init
  (defun hk/edraw-insert-link ()
    (interactive)
    (insert "[[edraw:]]")
    (edraw-org-edit-link))

  (defun hk/edraw-toggle-interval ()
    "Switched between the default interaval and a interval of 1
Useful when using wacom tablet for freehand"
    (interactive)
    (let* ((editor (edraw-current-editor))
           (current-interval (edraw-get-setting editor 'grid-interval)))
      (if (= current-interval edraw-editor-default-grid-interval)
          (progn (message "interval 1")
                 (edraw-editor-set-grid-interval editor 1)
                 (edraw-set-grid-visible editor nil))
        (message "interval 20")
        (edraw-editor-set-grid-interval editor 20)
        (edraw-set-grid-visible editor t)))
    ))

(use-package org-noter
  :custom
  (org-noter-notes-search-path '("~/documents/org/"))
  (org-noter-default-notes-file-names '("notes.org")))

(use-package journalctl-mode
  ;; View systemd's journalctl within Emacs
  )

(use-package unfill)


(provide 'init)
;;; init.el ends here

;; Local Variables:
;; outline-regexp: "\(use-package.*"
;; End:
