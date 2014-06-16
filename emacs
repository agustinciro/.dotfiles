;;;;;;;;;;;;;;;;;;;;;;;;
;: ben swift's .emacs ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; dotfiles repo: https://github.com/benswift/.dotfiles

;;;;;;;;;;
;; elpa ;;
;;;;;;;;;;

(require 'package)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.milkbox.net/packages/")
        ("elpy" . "http://jorgenschaefer.github.io/packages/")))

(unless package--initialized
  (package-initialize))

(when (null package-archive-contents)
  (package-refresh-contents))

(dolist (package
         '(ac-nrepl
           ac-cider-compliment
           ace-jump-mode
           ag
           auctex
           auto-complete
           bookmark+
           cider
           clojure-snippets
           dash-at-point
           xcscope
           elpy
           epl
           erc-hl-nicks
           erc-terminal-notifier
           ess
           exec-path-from-shell
           flatui-theme
           flx-ido
           flycheck
           gist
           glsl-mode
           htmlize
           ido-ubiquitous
           imenu-anywhere
           isearch+
           less-css-mode
           jedi
           magit
           markdown-mode
           monokai-theme
           multiple-cursors
           ;; nrepl-ritz ;; shadows cider-mode
           org
           powerline
           rainbow-delimiters
           scss-mode
           smartparens
           smex
           string-utils
           wgrep-ag
           yaml-mode
           yasnippet
           zoom-frm))
  (if (not (package-installed-p package))
      (package-install package)))

(global-set-key (kbd "C-c p") 'list-packages)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cross-platform setup ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun ben-set-default-faces (face-height)
  (set-face-attribute 'default nil :height face-height :family "Source Code Pro")
  (set-face-attribute 'variable-pitch nil :height face-height :family "Source Sans Pro"))

(exec-path-from-shell-initialize)
(exec-path-from-shell-copy-envs '("EDITOR" "EXT_LLVM_DIR" "LD_LIBRARY_PATH" "PYTHONPATH"))

;; linux

(defun ben-linux-setup ()
  (ben-set-default-faces 140)
  (setq frame-maximization-mode 'maximized)
  (ben-setup-keybindings))

;; OSX

(defun spotlight-locate-make-command-line (search-string)
  (list "mdfind" "-interpret" search-string))

(defun ben-setup-keybindings ()
  (define-key global-map (kbd "s-a") 'mark-whole-buffer)
  (define-key global-map (kbd "s-k") 'kill-this-buffer)
  (define-key global-map (kbd "s-l") 'goto-line)
  (define-key global-map (kbd "s-n") 'make-frame)
  (define-key global-map (kbd "s-q") 'save-buffers-kill-emacs)
  (define-key global-map (kbd "s-s") 'save-buffer)
  (define-key global-map (kbd "s-u") 'revert-buffer)
  (define-key global-map (kbd "s-v") 'yank)
  (define-key global-map (kbd "s-c") 'kill-ring-save)
  (define-key global-map (kbd "s-w") 'delete-frame)
  (define-key global-map (kbd "s-x") 'kill-region))

(defun ben-osx-setup ()
  (ben-set-default-faces 140)
  (setq mac-option-modifier 'meta)
	(setq mac-command-modifier 'super)
  (setq helm-locate-command "mdfind -name %s %s")
  (setq locate-make-command-line 'spotlight-locate-make-command-line)
  (setq x-bitmap-file-path '("/usr/X11/include/X11/bitmaps"))
  (setq source-directory "/Library/Caches/Homebrew/emacs-mac--git")
  (setq dired-guess-shell-alist-user '(("\\.pdf\\'" "open")))
  (setq frame-maximization-mode 'fullscreen)
  ;; for railwaycat emacs-mac
  (ben-setup-keybindings))

;; Windows

(defun ben-windows-setup ()
  (ben-set-default-faces 160)
  (setq w32-pass-lwindow-to-system nil)
  (setq w32-lwindow-modifier 'super)
  (ben-setup-keybindings))

(cond ((equal system-type 'gnu/linux) (ben-linux-setup))
      ((equal system-type 'darwin) (ben-osx-setup))
      ((equal system-type 'windows-nt) (ben-windows-setup)))

;;;;;;;;;;;;;;;;;;;
;; customisation ;;
;;;;;;;;;;;;;;;;;;;

(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file t)

;;;;;;;;;;;;;;;;
;; smex & ido ;;
;;;;;;;;;;;;;;;;

(require 'flx-ido)

(setq smex-save-file (concat user-emacs-directory ".smex-items"))
(smex-initialize)

(setq ido-enable-prefix nil
      ido-enable-flex-matching t
      ido-auto-merge-work-directories-length nil
      ido-create-new-buffer 'always
      ido-use-filename-at-point 'guess
      ido-use-virtual-buffers t
      ido-handle-duplicate-virtual-buffers 2
      ido-max-prospects 10)

(ido-mode 1)
(ido-ubiquitous-mode 1)
(flx-ido-mode 1)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c i") 'imenu-anywhere)
(global-set-key (kbd "C-c o") 'occur)

;;;;;;;;;;;;;;;;;;;;;;;;
;; garbage collection ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(setq gc-cons-threshold 50000000)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display & appearance ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq visible-bell t)
(setq inhibit-startup-message t)
(setq color-theme-is-global t)
(setq bidi-display-reordering nil)

(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (mouse-wheel-mode t)
  (blink-cursor-mode -1)
  (dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode))
    (when (fboundp mode) (funcall mode -1))))

(set-default 'indent-tabs-mode nil)
(set-default 'tab-width 2)
(set-default 'indicate-empty-lines t)
(set-default 'imenu-auto-rescan t)

(show-paren-mode 1)

(column-number-mode 1)
(hl-line-mode t)

;; from http://www.emacswiki.org/emacs/ToggleWindowSplit
(defun window-toggle-split-direction ()
  "Switch window split from horizontally to vertically, or vice versa.

i.e. change right window to bottom, or change bottom window to right."
  (interactive)
  (require 'windmove)
  (let ((done))
    (dolist (dirs '((right . down) (down . right)))
      (unless done
        (let* ((win (selected-window))
               (nextdir (car dirs))
               (neighbour-dir (cdr dirs))
               (next-win (windmove-find-other-window nextdir win))
               (neighbour1 (windmove-find-other-window neighbour-dir win))
               (neighbour2 (if next-win (with-selected-window next-win
                                          (windmove-find-other-window neighbour-dir next-win)))))
          ;;(message "win: %s\nnext-win: %s\nneighbour1: %s\nneighbour2:%s" win next-win neighbour1 neighbour2)
          (setq done (and (eq neighbour1 neighbour2)
                          (not (eq (minibuffer-window) next-win))))
          (if done
              (let* ((other-buf (window-buffer next-win)))
                (delete-window next-win)
                (if (eq nextdir 'right)
                    (split-window-vertically)
                  (split-window-horizontally))
                (set-window-buffer (windmove-find-other-window neighbour-dir) other-buf))))))))

(global-set-key (kbd "C-c y") 'window-toggle-split-direction)

;; show time and battery status in mode line

(display-time-mode 1)
(setq display-time-format "%H:%M")
(display-battery-mode -1)

;; whitespace

(setq sentence-end-double-space nil)
(setq shift-select-mode nil)
(setq whitespace-style '(face trailing lines-tail tabs))
(setq whitespace-line-column 80)
(add-to-list 'safe-local-variable-values '(whitespace-line-column . 80))

;; mark region commands as safe

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; text mode tweaks

(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook 'turn-on-flyspell)
(remove-hook 'text-mode-hook 'smart-spacing-mode)

;; file visiting

(setq save-place t
      save-place-file (concat user-emacs-directory "places")
      recentf-max-saved-items 100)

;; file backups

(setq backup-by-copying t
      backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

(global-auto-revert-mode t)

;; uniquify

(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward
      uniquify-separator ":")

;; other niceties

(add-to-list 'safe-local-variable-values '(lexical-binding . t))
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq diff-switches "-u")
(setq ispell-dictionary "en_GB")

(define-key lisp-mode-shared-map (kbd "RET") 'reindent-then-newline-and-indent)

(defalias 'yes-or-no-p 'y-or-n-p)

;; transparency

(defun set-current-frame-alpha (value)
  (interactive
   (list (read-number "Frame alpha: " 1.0)))
   (set-frame-parameter (selected-frame) 'alpha value))

(global-set-key (kbd "C-c t") 'set-current-frame-alpha)

;; fullscreen

(defcustom frame-maximization-mode 'maximized
  "The maximization style of \\[toggle-frame-maximized]."
  :type '(choice
          (const :tab "Respect window manager screen decorations." maximized)
          (const :tab "Ignore window manager screen decorations." fullscreen))
  :group 'frames)

(defun toggle-frame-maximized ()
  "Maximize/un-maximize Emacs frame according to `frame-maximization-mode'."
  (interactive)
  (modify-frame-parameters
   nil `((fullscreen . ,(if (frame-parameter nil 'fullscreen)
                            nil frame-maximization-mode)))))

(define-key global-map (kbd "C-s-f") 'toggle-frame-maximized)

;; hide certain minor modes from mode line

(setq eldoc-minor-mode-string "")

;; pretty lambdas

(add-hook 'prog-mode-hook
          '(lambda ()
             (font-lock-add-keywords
              nil `(("(?\\(lambda\\>\\)"
                     (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                               ,(make-char 'greek-iso8859-7 107))
                               nil)))))))

;;;;;;;;;;;;;;;;;
;; color theme ;;
;;;;;;;;;;;;;;;;;

(let ((theme 'monokai))
  (if (display-graphic-p)
      (case theme
        ('monokai (load-theme 'monokai t)
                  (add-to-list 'default-frame-alist
                               '(background-mode . dark))
                  (set-cursor-color "white"))
        ;; flatui
        ('flatui  (load-theme 'flatui t)
                  (add-to-list 'default-frame-alist
                               '(background-mode . light))))))

;;;;;;;;;;;;;;;;;
;; keybindings ;;
;;;;;;;;;;;;;;;;;

;; always use reindent-then-newline-and-indent

(global-set-key (kbd "RET") 'reindent-then-newline-and-indent)

;; handy shortcuts

(global-set-key (kbd "<f5>") 'magit-status)
(global-set-key (kbd "<f6>") 'compile)
(global-set-key (kbd "C-c g") 'ag)
(global-set-key (kbd "C-c u") 'ag-dired)

;; window navigation

(global-set-key (kbd "s-[") '(lambda () (interactive) (other-window -1)))
(global-set-key (kbd "s-]") 'other-window)

(global-set-key (kbd "s-{") 'shrink-window-horizontally)
(global-set-key (kbd "s-}") 'enlarge-window-horizontally)

;; Mac OS X-like

(global-set-key (kbd "s-z") 'undo)

(global-set-key (kbd "<s-left>") 'move-beginning-of-line)
(global-set-key (kbd "<s-right>") 'move-end-of-line)
(global-set-key (kbd "<s-up>") 'beginning-of-buffer)
(global-set-key (kbd "<s-down>") 'end-of-buffer)
(global-set-key (kbd "<M-delete>") 'kill-word)
(global-set-key (kbd "<M-backspace>") 'backward-kill-word)
(global-set-key (kbd "<s-backspace>") (lambda () (interactive) (kill-visual-line 0)))

(eval-after-load "magit"
  '(cl-nsubstitute-if '(magit-auto-revert-mode "")
                      (lambda (x) (equalp (car x) 'magit-auto-revert-mode))
                      minor-mode-alist))

;;;;;;;;;;;;;;
;; zoom-frm ;;
;;;;;;;;;;;;;;

(require 'zoom-frm)

(global-set-key (kbd "C-x C-+") 'zoom-in/out)
(global-set-key (kbd "C-x C--") 'zoom-in/out)
(global-set-key (kbd "C-x C-=") 'zoom-in/out)
(global-set-key (kbd "C-x C-0") 'zoom-in/out)

;;;;;;;;;;;;;;;
;; powerline ;;
;;;;;;;;;;;;;;;

(require 'powerline)

(setq powerline-default-separator 'slant)
(setq powerline-height 30)

;; monokai has changed the way it does it's colours - so this no longer works

;; (set-face-attribute 'mode-line nil :foreground monokai-bg-1 :background monokai-cyan-1)
;; (set-face-attribute 'mode-line-inactive nil :foreground monokai-fg :background monokai-bg+1)
;; (set-face-attribute 'mode-line-buffer-id nil :foreground monokai-bg-1)
;; (set-face-attribute 'powerline-active1 nil :foreground monokai-fg-1 :background monokai-bg)
;; (set-face-attribute 'powerline-active2 nil :foreground monokai-fg-1 :background monokai-bg-1)
;; (set-face-attribute 'powerline-inactive1 nil :foreground monokai-fg-1 :background monokai-bg)
;; (set-face-attribute 'powerline-inactive2 nil :foreground monokai-fg-1 :background monokai-bg-1)

(defun powerline-ben-theme ()
  "Ben's powerline theme, based on \\[powerline-default-theme]"
  (interactive)
  (setq-default mode-line-format
                '("%e"
                  (:eval
                   (let* ((active (powerline-selected-window-active))
                          (mode-line (if active 'mode-line 'mode-line-inactive))
                          (face1 (if active 'powerline-active1 'powerline-inactive1))
                          (face2 (if active 'powerline-active2 'powerline-inactive2))
                          (separator-left (intern (format "powerline-%s-%s"
                                                          powerline-default-separator
                                                          (car powerline-default-separator-dir))))
                          (separator-right (intern (format "powerline-%s-%s"
                                                           powerline-default-separator
                                                           (cdr powerline-default-separator-dir))))
                          (lhs (list (powerline-raw "%*" nil 'l)
                                     (powerline-buffer-id nil 'l)
                                     (when (and (boundp 'which-func-mode) which-func-mode)
                                       (powerline-raw which-func-format nil 'l))
                                     (powerline-raw " ")
                                     (funcall separator-left mode-line face1)
                                     (when (boundp 'erc-modified-channels-object)
                                       (powerline-raw erc-modified-channels-object face1 'l))
                                     (powerline-major-mode face1 'l)
                                     (powerline-process face1)
                                     (powerline-minor-modes face1 'l)
                                     (powerline-narrow face1 'l)
                                     (powerline-raw " " face1)
                                     (funcall separator-left face1 face2)))
                          (rhs (list (powerline-raw global-mode-string face2 'r)
                                     (funcall separator-right face2 face1)
                                     (powerline-raw "%4l" face1 'l)
                                     (powerline-raw ":" face1 'l)
                                     (powerline-raw "%3c" face1 'r)
                                     (funcall separator-right face1 mode-line)
                                     (powerline-raw " ")
                                     (powerline-raw "%6p" nil 'r)
                                     (powerline-hud face2 face1))))
                     (concat (powerline-render lhs)
                             (powerline-fill face2 (powerline-width rhs))
                             (powerline-render rhs)))))))

(powerline-ben-theme)

;;;;;;;;;;;;;;;;;;;
;; ace-jump-mode ;;
;;;;;;;;;;;;;;;;;;;

(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

(autoload
  'ace-jump-mode-pop-mark
  "ace-jump-mode"
  "Ace jump back:-)"
  t)
(eval-after-load "ace-jump-mode"
  '(ace-jump-mode-enable-mark-sync))
(define-key global-map (kbd "C-x SPC") 'ace-jump-mode-pop-mark)

;;;;;;;;;;;;
;; cscope ;;
;;;;;;;;;;;;

;; uses xcscope.el

(cscope-setup)

;;;;;;;;;;
;; dash ;;
;;;;;;;;;;

(global-set-key (kbd "C-c d") 'dash-at-point)

;;;;;;;;;;;;
;; eshell ;;
;;;;;;;;;;;;

(setq eshell-aliases-file "~/.dotfiles/eshell-alias")
(global-set-key (kbd "C-c e") 'eshell)

(defun ben-eshell-mode-hook ()
  ;; config vars
  (setq eshell-cmpl-cycle-completions nil)
  (setq eshell-save-history-on-exit t)
  (setq eshell-buffer-shorthand t)
  (setq eshell-cmpl-dir-ignore "\\`\\(\\.\\.?\\|CVS\\|\\.svn\\|\\.git\\)/\\'")
  ;; environment vars
  (setenv "EDITOR" "export EDITOR=\"emacsclient --alternate-editor=emacs --no-wait\"")
  ;; keybindings
  (define-key eshell-mode-map (kbd "<C-up>") 'eshell-previous-matching-input-from-input)
  (define-key eshell-mode-map (kbd "<C-down>") 'eshell-next-matching-input-from-input)
  (define-key eshell-mode-map (kbd "<up>") 'previous-line)
  (define-key eshell-mode-map (kbd "<down>") 'next-line)
  ;; prompt helpers
  (setq eshell-directory-name (concat user-emacs-directory "eshell/"))
  (setq eshell-prompt-regexp "^[^@]*@[^ ]* [^ ]* [$#] ")
  (setq eshell-prompt-function
        (lambda ()
          (concat (user-login-name) "@" (host-name) " "
                  (base-name (eshell/pwd))
                  (if (= (user-uid) 0) " # " " $ "))))
  ;; helpful bits and pieces
  (turn-on-eldoc-mode)
  (add-to-list 'eshell-command-completions-alist
               '("gunzip" "gz\\'"))
  (add-to-list 'eshell-command-completions-alist
               '("tar" "\\(\\.tar|\\.tgz\\|\\.tar\\.gz\\)\\'"))
  (add-to-list 'eshell-visual-commands "ssh"))

(add-hook 'eshell-mode-hook 'ben-eshell-mode-hook)

(defun base-name (path)
  "Returns the base name of the given path."
  (let ((path (abbreviate-file-name path)))
    (if (string-match "\\(.*\\)/\\(.*\\)$" path)
        (if (= 0 (length (match-string 1 path)))
            (concat "/" (match-string 2 path))
          (match-string 2 path))
      path)))

(defun host-name ()
  "Returns the name of the current host minus the domain."
  (let ((hostname (downcase (system-name))))
    (save-match-data
      (substring hostname
                 (string-match "^[^.]+" hostname)
                 (match-end 0)))))

;;;;;;;;;;;
;; elisp ;;
;;;;;;;;;;;

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)

;;;;;;;;;;;
;; dired ;;
;;;;;;;;;;;

(setq dired-listing-switches "-alh")
(setq dired-auto-revert-buffer t)

;;;;;;;;;;;;;
;; ibuffer ;;
;;;;;;;;;;;;;

(global-set-key (kbd "C-x C-b") 'ibuffer)

;;;;;;;;;;;
;; magit ;;
;;;;;;;;;;;

(setq vc-display-status nil)
(setq magit-save-some-buffers nil)

;;;;;;;;;;;;;
;; cc-mode ;;
;;;;;;;;;;;;;

;; (setq c-default-style "k&r")

;;;;;;;;;;;;;;
;; org mode ;;
;;;;;;;;;;;;;;

(require 'org)

(setq org-completion-use-ido t)
(setq org-export-with-toc nil)

(defun ben-org-mode-hook ()
  ;; ;; org-latex export
  ;; (add-to-list 'org-export-latex-classes
  ;;              '("scrartcl"
  ;;                "\\documentclass[12pt,a4paper]{scrartcl}"
  ;;                ("\\section{%s}" . "\\section*{%s}")
  ;;                ("\\subsection{%s}" . "\\subsection*{%s}")
  ;;                ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
  ;;                ("\\paragraph{%s}" . "\\paragraph*{%s}")
  ;;                ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  ;; (setq org-export-latex-default-class "scrartcl")
  ;; keymappings
  (define-key org-mode-map (kbd "<M-left>") 'backward-word)
  (define-key org-mode-map (kbd "<M-right>") 'forward-word)
  (define-key org-mode-map (kbd "<C-left>") 'org-metaleft)
  (define-key org-mode-map (kbd "<C-right>") 'org-metaright)
  ;; stop org-mode shadowing the mc keybindings
  (define-key org-mode-map (kbd "<C-S-up>") nil)
  (define-key org-mode-map (kbd "<C-S-down>") nil)
  (define-key org-mode-map (kbd "<C-S-right>") nil)
  (define-key org-mode-map (kbd "<C-S-left>") nil)
  ;; disable rainbow-delimiters
  (rainbow-delimiters-mode-disable))

(add-hook 'org-mode-hook 'ben-org-mode-hook)

;; (setq org-format-latex-header
;;       "\\documentclass[12pt,a4paper]{scrartcl}
;; \\usepackage{libertineotf}
;; \\usepackage{fontspec}
;; \\setmonofont[Scale=MatchLowercase,Mapping=tex-text]{Source Code Pro}

;; \\usepackage{booktabs}
;; \\usepackage{tabularx}
;; \\renewcommand{\\arraystretch}{1.2}

;; % biblatex

;; \\usepackage[%
;; backend=biber,
;; natbib=true,
;; backref=true,
;; citecounter=true,
;; dashed=false,
;; backrefstyle=three,
;; citestyle=authoryear-icomp,
;; firstinits=true,
;; maxcitenames=2,
;; maxbibnames=10,
;; uniquename=mininit,
;; bibstyle=authoryear,
;; % refsegment=chapter,
;; % ibidtracker=strict,
;; url=false,
;; doi=false]{biblatex}

;; % to use year-only bib format
;; \\AtEveryBibitem{\\clearfield{month}}
;; \\AtEveryCitekey{\\clearfield{month}}

;; % specify the bib file here
;; \\addbibresource{papers.bib}

;; % IMPORTANT: to actually print the bibliography in the document,
;; % insert the command: \\printbibliography[title=References]

;; % csquotes

;; \\usepackage[english=british,threshold=15,thresholdtype=words]{csquotes}
;; \\SetCiteCommand{\\parencite}

;; \\newenvironment*{smallquote}
;;   {\\quote\\small}
;;   {\\endquote}
;; \\SetBlockEnvironment{smallquote}

;; % hyperref & bookmark

;; \\usepackage[svgnames,hyperref]{xcolor}

;; \\usepackage[%
;; unicode=true,
;; hyperindex=true,
;; bookmarks=true,
;; colorlinks=true, % change to false for final
;; pdfborder=0,
;; allcolors=DarkBlue,
;; % plainpages=false,
;; pdfpagelabels,
;; hyperfootnotes=true]{hyperref}

;; ")

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ben is On the Tubes ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; need to use the command `org-html-htmlize-generate-css' to extract
;; class definitions
(setq org-html-htmlize-output-type 'inline-css)

;; (setq org-html-htmlize-font-prefix "")

(setq org-html-footnotes-section
      "<div id=\"footnotes\">
<h2>%s </h2>
<div id=\"text-footnotes\">
%s
</div>
</div>")
(setq org-html-footnote-format "[%s] ")
(setq org-html-footnote-separator "")
(setq org-publish-project-alist
      '(("biott-posts"
         :base-directory "~/Documents/biott/"
         :base-extension "org"
         :exclude "draft-posts/*"
         :publishing-directory "~/Code/clojure/benswift.me/resources/"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :html-extension "html"
         :body-only t
         :html-head-include-default-style nil
         :section-numbers nil
         :html-link-home "/"
         :html-link-use-abs-url t)
        ("biott-images"
         :base-directory "~/Documents/biott/public/img/"
         :base-extension "png\\|jpg\\|pdf"
         :publishing-directory "~/Code/clojure/benswift.me/resources/public/img/"
         :recursive t
         :publishing-function org-publish-attachment)
        ("biott" :components ("biott-posts" "biott-images"))))

(setq org-export-html-mathjax-options
      '((path "http://orgmode.org/mathjax/MathJax.js")
        (scale "100")
        (align "center")
        (indent "2em")
        (mathml t)))


(require 'url-util) ; needed for url-unerserved-chars

(defun biott-sanitise-post-name (post-name)
  (apply #'string (reverse (cl-reduce (lambda (processed char)
                                      (if (member char url-unreserved-chars)
                                          (cons char processed)
                                        (if (and processed
                                                 (= (first processed) ?-))
                                            processed
                                          (cons ?- processed))))
                                      (string-to-list post-name)
                    :initial-value '()))))

(defun biott-new-post (post-name)
  (interactive "sPost title: ")
  (let ((post-url-basename
         (concat (format-time-string "%Y-%m-%d-")
                 (downcase (biott-sanitise-post-name post-name)))))
    (find-file (concat "~/Documents/biott/draft-posts/"
                       post-url-basename
                       ".org"))
    (insert (format
             "#+begin_html
---
title: %s
alias: [\"./%s.html\"]
tags:
---
#+end_html
"
             post-name post-url-basename))))

;;;;;;;;;;;;;;
;; hunspell ;;
;;;;;;;;;;;;;;

;; (require 'ispell)

;; (setq ispell-program-name "/usr/local/bin/hunspell")
;; (setq ispell-dictionary "en_AU")
;; (add-to-list 'ispell-dictionary-alist
;;              '("en_AU" "[[:alpha:]]" "[^[:alpha:]]" "" t ("-d" "/Library/Spelling/en_AU") nil iso-8859-1))

;; (setq rw-hunspell-dicpath-list '("/Library/Spelling"))

;;;;;;;;;
;; erc ;;
;;;;;;;;;

(unless (load "~/.dotfiles/secrets/ercpass" t)
  ("Couldn't find the secrets file, you need to pull it down from dropbox."))

(erc-services-mode 1)
(setq erc-nick "benswift")
(setq erc-prompt-for-password nil)
(setq erc-prompt-for-nickserv-password nil)
(setq erc-autojoin-channels-alist '(("freenode.net" "#extempore")))

;; erc-notify

(setq erc-notify-list '("digego"))

;;;;;;;;;;;;;;;;;;;;
;; LaTeX & reftex ;;
;;;;;;;;;;;;;;;;;;;;

(require 'latex)
(require 'reftex)

(defun ben-latex-mode-hook ()
  (setq TeX-master t)
  (setq TeX-PDF-mode t)
  (setq TeX-auto-untabify t)
  (setq TeX-parse-self t)
  (setq TeX-auto-save t)
  (add-to-list 'auto-mode-alist '("\\.cls" . LaTeX-mode))
  ;; use Skim for pdfs on OSX
  (add-to-list 'TeX-view-program-list
               '("Skim" "~/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b"))
  (if (equal system-type 'darwin)
      (add-to-list 'TeX-view-program-selection '(output-pdf "Skim")))
  ;; synctex
  (setq TeX-source-correlate-mode t)
  (setq TeX-source-correlate-method 'synctex)
  ;; latex keybindings
  (define-key LaTeX-mode-map (kbd "C-c w") 'latex-word-count)
  ;; reftex
  (setq reftex-enable-partial-scans t)
  (setq reftex-save-parse-info t)
  (setq reftex-plug-into-AUCTeX t)
  (setq reftex-cite-prompt-optional-args nil)
  (setq reftex-cite-cleanup-optional-args t)
  (setq reftex-bibliography-commands '("bibliography" "nobibliography" "setupbibtex\\[.*?database=" "addbibresource"))
  (reftex-mode 1)
  ;; reftex keybindings
  (define-key LaTeX-mode-map (kbd "C-c =") 'reftex-toc)
  (define-key LaTeX-mode-map (kbd "C-c c") 'reftex-citation)
  (define-key LaTeX-mode-map (kbd "C-c r") 'reftex-reference))

(defun latex-word-count ()
  (interactive)
  (let* ((tex-file (if (stringp TeX-master)
		       TeX-master
		     (buffer-file-name)))
         (enc-str (symbol-name buffer-file-coding-system))
         (enc-opt (cond
                   ((string-match "utf-8" enc-str) "-utf8")
                   ((string-match "latin" enc-str) "-latin1")
                   ("-encoding=guess")))
         (word-count
          (with-output-to-string
            (with-current-buffer standard-output
              (call-process "texcount" nil t nil "-1" "-merge" enc-opt tex-file)))))
    (message word-count)))

(add-hook 'LaTeX-mode-hook 'ben-latex-mode-hook)

;; for minted

(eval-after-load "tex"
  '(setcdr (assoc "LaTeX" TeX-command-list)
          '("%`%l%(mode) -shell-escape%' %t"
          TeX-run-TeX nil (latex-mode doctex-mode) :help "Run LaTeX")))

;;;;;;;;;;;;;;;
;; extempore ;;
;;;;;;;;;;;;;;;

(setq user-extempore-directory "~/Code/extempore/")
(autoload 'extempore-mode (concat user-extempore-directory "extras/extempore.el") "" t)
(add-to-list 'auto-mode-alist '("\\.xtm$" . extempore-mode))
(add-to-list 'dash-at-point-mode-alist '(extempore-mode . "gl4,gl3,gl2,c,c++,osx"))

;; extempore customisation
(setq extempore-tab-completion nil)

;; device-specific Extempore config
(cond
 ((string= system-name "lonyx")
  (setq extempore-program-args "--device 0 --frames 1024 --run libs/xtm.xtm"))
 ((string= system-name "cyril.local")
  (setq extempore-program-args "--device 2 --frames 1024 --run libs/xtm.xtm"))
 ((string= system-name "hodgey.local")
  (setq extempore-program-args "--device 1 --frames 1024 --run libs/xtm.xtm"))
 ((string= system-name "hodgey-ubuntu")
  (setq extempore-program-args "--device 0 --frames 1024 --run libs/xtm.xtm"))
 (t nil))

(defun ben-extempore-mode-hook ()
  (turn-on-eldoc-mode)
  (setq eldoc-documentation-function
        'extempore-eldoc-documentation-function)
  ;; (if (and (not extempore-logger-mode)
  ;;          (yes-or-no-p "Do you want to log this session?"))
  ;;     (extempore-logger-mode 1))
  (yas-minor-mode-on)
  ;; monokai-bg is #272822 (monokai 20140109.2253)
  (set-face-attribute 'extempore-blink-face nil :foreground "#272822" :background "#FD971F")
  (set-face-attribute 'extempore-sb-blink-face nil :foreground "#272822" :background "#39FF14"))

(add-hook 'extempore-mode-hook 'ben-extempore-mode-hook)

(autoload #'llvm-mode (concat user-extempore-directory "extras/llvm-mode.el")
  "Major mode for editing LLVM IR files" t)

(add-to-list 'auto-mode-alist '("\\.ir$" . llvm-mode))
(add-to-list 'auto-mode-alist '("\\.ll$" . llvm-mode))

(defun extempore-create-template-file (base-path filename &optional header)
  (let ((full-path (format "%s/%s" base-path filename)))
    (unless (file-exists-p full-path)
      (progn
        (find-file full-path)
        (if header (insert header))
        (save-buffer)
        (kill-buffer)))))

(defun extempore-create-template (name)
  "Set up the directory structure and files for a new extempore session/gig."
  (interactive "sSession name: ")
  (let* ((xtm-dir (expand-file-name "~/Code/xtm/"))
         (base-path (concat xtm-dir "sessions/" name))
         (setup-header
          (concat ";;; setup.xtm --- setup file for " name "\n"
                  "(sys:load \"libs/xtm.xtm\")\n"
                  "(sys:load \"" xtm-dir "lib/ben-lib-xtlang.xtm\")\n"
                  "(sys:load \"" xtm-dir "lib/ben-lib-scheme.xtm\")\n"
                  "(ipc:load \"utility\" \"" xtm-dir "lib/ben-lib-scheme.xtm\")\n"
                  "(sys:load \"" xtm-dir "lib/sampler-maps.xtm\")\n"
                  "(ipc:load \"utility\" \"" xtm-dir "lib/sampler-maps.xtm\")\n\n"
                  "(bind-func dsp:[SAMPLE,SAMPLE,i64,i64,SAMPLE*]*\n"
                  "  (lambda (in time chan dat)\n"
                  "    0.0))\n\n"
                  ";; (ipc:bind-func \"utility\" 'instname)\n"
                  "(ipc:audio-setup \"utility\")\n"
                  "(dsp:set! dsp)")))
    (if (file-exists-p base-path)
        (error "Cannot create xtm session: directory already exists."))
    (make-directory base-path)
    ;; practice files
    (extempore-create-template-file
     base-path "prac-utility.xtm" "headeru")
    (extempore-create-template-file
     base-path "prac-primary.xtm" "headerp")
    ;; gig files
    (extempore-create-template-file
     base-path "gig-utility.xtm" "headeru")
    (extempore-create-template-file
     base-path "gig-primary.xtm" "headerp")
    ;; setup file
    (extempore-create-template-file
     base-path "setup.xtm" setup-header)
    (dired base-path)))

;; yasnippet helpers


;; used in extempore-mode's print-line-debug snippet
(defun extempore-yas-println-debug-expander (pl-str format-str)
  (if (not (string= pl-str ""))
      (mapconcat (lambda (name) (format format-str name name))
                 (cl-remove-if (lambda (x) (or (string-match "^'.*:$" x)
                                          (string-match "^\".*:\"$" x)))
                               (split-string pl-str " "))
                 " ")
    pl-str))

(defvar extempore-yas-expansion-list-oscmc_c
  '(("osc" "0." "chan amp freq")
    ("square" "0." "chan amp freq n")
    ("triangle" "0." "chan amp freq n")
    ("rect" "0." "chan amp freq duty")
    ("saw" "0." "chan amp freq")
    ("pulse" "" "chan amp freq width")
    ("fade" "" "chan initial final dur")
    ("delay" "2 max_delay_samps" "chan in wet fb")
    ("comb" "2 max_delay_samps" "chan in delay wet fb")
    ("flanger" "2 delay mod_phase mod_range mod_rate" "chan in wet fb")
    ("chorus" "2 phase" "chan in wet fb")
    ("tap_delay" "2 max_delay_samps ntaps" "chan in")
    ("allpass" "2 delay_sec" "chan in wet")
    ("reverb" "2 size_ms" "chan in wet fb")
    ("hold" "2" "chan in h")
    ("lpf" "2" "chan in freq res")
    ("hpf" "2" "chan in freq res")
    ("bpf" "2" "chan in freq bw")
    ("notch" "2" "chan in freq bw")
    ("vcf" "type chan" "chan in freq res")
    ("hann" "" "chan width")
    ("linear" "start end dur" "chan inc")))

(defun extempore-yas-oscmc_c-expander (type construct-p)
  (let ((res (cl-find-if (lambda (x) (string= (car x) type))
                         extempore-yas-expansion-list-oscmc_c)))
    (if res
        (if construct-p
            (cadr res)
          (caddr res))
      "")))

;;;;;;;;;;;;;;;;;
;; smartparens ;;
;;;;;;;;;;;;;;;;;

(require 'smartparens)
(require 'smartparens-config)

(add-to-list 'sp-ignore-modes-list 'org-mode)

(setq sp-highlight-wrap-tag-overlay nil
      sp-highlight-wrap-overlay nil
      sp-highlight-pair-overlay nil
      sp-hybrid-kill-excessive-whitespace t)

(defun ben-smartparens-mode-hook ()
  (define-key sp-keymap (kbd "M-<down>") 'sp-splice-sexp-killing-forward)
  (define-key sp-keymap (kbd "M-<up>") 'sp-splice-sexp-killing-backward)
  (define-key sp-keymap (kbd "s-<left>") 'sp-backward-up-sexp)
  (define-key sp-keymap (kbd "s-<right>") 'sp-up-sexp)
  (define-key sp-keymap (kbd "s-S-<left>") 'sp-backward-down-sexp)
  (define-key sp-keymap (kbd "s-S-<right>") 'sp-down-sexp)
  (define-key sp-keymap (kbd "C-<left>") 'sp-forward-barf-sexp)
  (define-key sp-keymap (kbd "C-<right>") 'sp-forward-slurp-sexp)
  (define-key sp-keymap (kbd "M-S-<up>") 'sp-splice-sexp-killing-around)
  (define-key sp-keymap (kbd "M-S-<left>") 'sp-convolute-sexp)
  (define-key sp-keymap (kbd "M-S-<right>") 'sp-transpose-sexp)
  (define-key sp-keymap (kbd "s-S-<down>") 'sp-duplicate-next-sexp)
  (define-key sp-keymap (kbd "M-S-<down>") 'sp-wrap-with-paren)
  (add-to-list 'sp--lisp-modes 'extempore-mode))

(add-hook 'smartparens-enabled-hook 'ben-smartparens-mode-hook)

(defun sp-wrap-with-paren (&optional arg)
  (interactive "p")
  (sp-select-next-thing-exchange arg)
  (execute-kbd-macro (kbd "(")))

(defun sp-duplicate-next-sexp (&optional arg)
  (interactive "p")
  (sp-select-next-thing arg)
  (kill-ring-save (mark) (point))
  (reindent-then-newline-and-indent)
  (yank)
  (sp-backward-sexp))

(defun sp-reindent-defun (&optional argument)
  "Reindent the definition that the point is on.

If the point is in a string or a comment, fill the paragraph
instead, and with a prefix argument, justify as well."
  (interactive "P")
  (if (or (sp-point-in-string)
          (sp-point-in-comment))
      (lisp-fill-paragraph argument)
    (save-excursion
      (end-of-defun)
      (beginning-of-defun)
      (indent-sexp))))

(define-key lisp-mode-shared-map (kbd "M-q") 'sp-reindent-defun)

(smartparens-global-mode 1)
(smartparens-global-strict-mode 1)

;; make the quote (') character work right in lisp modes
;; taken from https://github.com/Fuco1/smartparens/issues/286
(defun sp--org-skip-markup (ms mb me)
  (save-excursion
    (and (progn
           (goto-char mb)
           (save-match-data (looking-back "\\sw\\|\\s_\\|\\s.")))
         (progn
           (goto-char me)
           (save-match-data (looking-at "\\sw\\|\\s_\\|\\s."))))))

(sp-with-modes sp--lisp-modes
  ;; disable ', it's the quote character!
  (sp-local-pair "'" nil :actions nil)
  ;; also only use the pseudo-quote inside strings where it serve as
  ;; hyperlink.
  (sp-local-pair "`" "'" :when '(sp-in-string-p sp-in-comment-p))
  (sp-local-pair "`" nil
                 :skip-match (lambda (ms mb me)
                               (cond
                                ((equal ms "'")
                                 (or (sp--org-skip-markup ms mb me)
                                     (not (sp-point-in-string-or-comment))))
                                (t (not (sp-point-in-string-or-comment)))))))

;;;;;;;;;;;;;;;;;;;;;;;;
;; rainwow-delimiters ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(global-rainbow-delimiters-mode)

;;;;;;;;;;;;;
;; clojure ;;
;;;;;;;;;;;;;

;; cider

(setq nrepl-hide-special-buffers t)
(setq cider-auto-select-error-buffer nil)
(setq cider-repl-use-pretty-printing nil)
(setq cider-repl-use-clojure-font-lock t)

;;;;;;;;;;;;;;
;; markdown ;;
;;;;;;;;;;;;;;

(add-to-list 'auto-mode-alist '("\\.md" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown" . markdown-mode))

(defun ben-markdown-mode-hook ()
  ;; unset these keys in markdown-mode-map
  (define-key markdown-mode-map (kbd "<M-left>") nil)
  (define-key markdown-mode-map (kbd "<M-right>") nil))

(add-hook 'markdown-mode-hook 'ben-markdown-mode-hook)

;;;;;;;;;;
;; yaml ;;
;;;;;;;;;;

(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

;;;;;;;;;
;; git ;;
;;;;;;;;;

(add-to-list 'auto-mode-alist '(".*gitconfig$" . conf-unix-mode))
(add-to-list 'auto-mode-alist '(".*gitignore$" . conf-unix-mode))

;;;;;;;
;; R ;;
;;;;;;;

(require 'ess-site)

(add-to-list 'auto-mode-alist '("\\.r$" . R-mode))
(add-to-list 'auto-mode-alist '("\\.R$" . R-mode))

(defun ben-ess-R-post-run-hook ()
  (smartparens-mode t)
  (set (make-local-variable 'sp-hybrid-kill-excessive-whitespace) nil))

(add-hook 'ess-R-post-run-hook 'ben-ess-R-post-run-hook)

;;;;;;;;;;;;
;; Python ;;
;;;;;;;;;;;;

(setq python-indent-offset 2)

;; elpy setup

(elpy-enable)
(elpy-use-ipython)

;; (setq elpy-rpc-backend "jedi")

(setq  elpy-default-minor-modes
       '(eldoc-mode
         flycheck-mode
         highlight-indentation-mode
         auto-complete-mode))

;;;;;;;;;;;;;;;
;; yasnippet ;;
;;;;;;;;;;;;;;;

(require 'yasnippet)

(setq yas-prompt-functions '(yas-ido-prompt yas-no-prompt))
(setq yas-triggers-in-field t)
(add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
(yas-global-mode 1)

(eval-after-load "yasnippet"
  '(cl-nsubstitute-if '(yas-minor-mode "")
                      (lambda (x) (equalp (car x) 'yas-minor-mode))
                      minor-mode-alist))

;;;;;;;;;;;;;;;;;;
;; autocomplete ;;
;;;;;;;;;;;;;;;;;;

;; autocomplete needs to be set up after yasnippet

(require 'auto-complete-config)

;; (ac-set-trigger-key "<tab>")
(add-to-list 'ac-dictionary-directories (concat user-emacs-directory ".ac-dict"))
(setq ac-auto-start 2)
(ac-config-default)

(eval-after-load "auto-complete"
  '(cl-nsubstitute-if '(auto-complete-mode "")
                      (lambda (x) (equalp (car x) 'auto-complete-mode))
                      minor-mode-alist))

;; for using Clang autocomplete

;; (require 'auto-complete-clang)

;; (defun my-ac-cc-mode-setup ()
;;   (setq ac-sources (append '(ac-source-clang ac-source-yasnippet ac-source-gtags) ac-sources)))

;; (defun my-ac-config ()
;;   (setq-default ac-sources '(ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))
;;   (add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)
;;   (add-hook 'c-mode-common-hook 'my-ac-cc-mode-setup)
;;   (add-hook 'ruby-mode-hook 'ac-ruby-mode-setup)
;;   (add-hook 'css-mode-hook 'ac-css-mode-setup)
;;   (add-hook 'auto-complete-mode-hook 'ac-common-setup)
;;   (global-auto-complete-mode t))

;; (my-ac-config)

;;;;;;;;;;;;;;;;;;;;;;;
;; ttl (Turtle) mode ;;
;;;;;;;;;;;;;;;;;;;;;;;

(autoload 'ttl-mode "ttl-mode" "Major mode for OWL or Turtle files" t)
(add-to-list 'auto-mode-alist '("\\.n3" . ttl-mode))
(add-to-list 'auto-mode-alist '("\\.ttl" . ttl-mode))
(add-hook 'ttl-mode-hook 'turn-on-font-lock)

;;;;;;;;;;;;;
;; Nyquist ;;
;;;;;;;;;;;;;

(add-to-list 'auto-mode-alist '("\\.ny" . lisp-mode))

;;;;;;;;;;;;;;
;; lilypond ;;
;;;;;;;;;;;;;;

(autoload 'LilyPond-mode "lilypond-mode")
(add-to-list 'auto-mode-alist '("\\.ly$" . LilyPond-mode))
(add-hook 'LilyPond-mode-hook 'turn-on-font-lock)

;;;;;;;;;
;; abc ;;
;;;;;;;;;

(add-to-list 'auto-mode-alist '("\\.abc\\'"  . abc-mode))
(add-to-list 'auto-mode-alist '("\\.abp\\'"  . abc-mode))

;;;;;;;;;;;;;;;;;;;;;;
;; multiple-cursors ;;
;;;;;;;;;;;;;;;;;;;;;;

(require 'multiple-cursors)

(global-set-key (kbd "<C-S-up>") 'mc/edit-lines)
(global-set-key (kbd "<C-S-down>") 'mc/mark-all-like-this-dwim)
(global-set-key (kbd "<C-S-right>") 'mc/mark-next-like-this)
(global-set-key (kbd "<C-S-left>") 'mc/mark-previous-like-this)

(global-set-key (kbd "C-c n") 'mc/insert-numbers)

;;;;;;;;;;
;; misc ;;
;;;;;;;;;;

(defun read-lines (fpath)
  "Return a list of lines of a file at at FPATH."
  (with-temp-buffer
    (insert-file-contents fpath)
    (split-string (buffer-string) "\n" t)))

(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

;; from http://www.emacswiki.org/emacs/CommentingCode
(defun comment-dwim-line (&optional arg)
  "Replacement for the `comment-dwim' command.
If no region is selected and current line is not blank and we are not at the end of the line,
then comment current line.
Replaces default behaviour of `comment-dwim', when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))

(global-set-key (kbd "s-'") 'comment-dwim-line)

;; from
;; http://stackoverflow.com/questions/88399/how-do-i-duplicate-a-whole-line-in-emacs

(defun duplicate-line ()
  "Clone line at cursor, leaving the latter intact."
  (interactive "*")
  (save-excursion
    ;; The last line of the buffer cannot be killed
    ;; if it is empty. Instead, simply add a new line.
    (if (and (eobp) (bolp))
	(newline)
      ;; Otherwise kill the whole line, and yank it back.
      (let ((kill-read-only-ok t)
	    deactivate-mark)
	(read-only-mode 1)
	(kill-whole-line)
	(read-only-mode 0)
	(yank)))))

;; (global-set-key (kbd "C-c d") 'duplicate-line)
;; (global-set-key (kbd "C-c b") 'comment-box)

;;;;;;;;;;;;;;;;;;
;; emacs server ;;
;;;;;;;;;;;;;;;;;;

(require 'server)

;; (setq server-name "ben")

(unless (server-running-p)
  (server-start))

;; toggle fullscreen

(if (display-graphic-p)
    (toggle-frame-maximized))
