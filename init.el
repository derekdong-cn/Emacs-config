;;; init.el -- msherry's init.el

;;; Commentary:

;; Much of this is organized similar to:
;; http://bitbucket.org/brodie/dotfiles/src/tip/.emacs

;;; Code:

;; Do these early so if there's an error in config we don't pollute ~/ with
;; junk files
(defvar save-place-file)                ; C-h i g (Elisp) Warning Tips
(setq save-place-file "~/.emacs.d/emacs-places"
      backup-directory-alist '(("." . "~/.emacs.d/backups")))

; Seed RNG
(random t)

;; Plugins - add plugins dir, vendors dir, and all dirs under vendor
;; excluding . and ..
(add-to-list 'load-path "~/.emacs.d/plugins")
(add-to-list 'load-path "~/.emacs.d/plugins/vendor")
(add-to-list 'load-path "~/.emacs.d/plugins/language-specific")
(dolist (dir (directory-files "~/.emacs.d/plugins/vendor" t "^[^.]"))
  (when (file-directory-p dir)
    (add-to-list 'load-path dir)))

(when (and (eq system-type 'darwin) window-system)
  (require 'msherry-macos))

;; Set up GUI as soon as possible
(when window-system
  (cond ((eq system-type 'darwin)
         (setq default-frame-alist
               (append `((left . ,(cond ((< emacs-major-version 23) 15)
                                        (t 8)))
                         (top . 20)
                         (width . 175)
                         (height . ,(cond ((< emacs-major-version 23) 47)
                                          ((< emacs-major-version 24) 52)
                                          (t 49))))
                       default-frame-alist)))
        ((eq system-type 'gnu/linux)
         (setq default-frame-alist
               (append `((left . 520)
                         (top . 48)
                         (width . 186)
                         (height . 87))))
         (set-frame-font "-unknown-DejaVu Sans Mono-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1")))
  (if (fboundp #'tool-bar-mode) (tool-bar-mode -1))

  (set-frame-parameter (selected-frame) 'alpha '(100 100))
  (add-to-list 'default-frame-alist '(alpha 100 100)))

;; I edit these files a lot, so put them in registers
(set-register ?z '(file . "~/.emacs.d/init.el"))
(set-register ?p '(file . "~/.emacs.d/pass.org.gpg"))
(set-register ?t '(file . "~/TODO.org"))
(set-register ?f '(file . "~/Desktop/fraud/fraud_scripts.py"))
(set-register ?g '(file . "~/code/pinboard/schemas/goldpick_commons/ttypes.py"))

;; Set up environment
(set-language-environment "UTF-8")

(defvar expanded-user-emacs-directory (expand-file-name user-emacs-directory))

;; Configure ELPA (package loader)
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
             '("elpy" . "http://jorgenschaefer.github.io/packages/"))
(add-to-list 'package-archives
             '("org" . "http://orgmode.org/elpa/") t)
;; Marmalade is less up-to-date than melpa and is currently giving certificate
;; errors
;; (add-to-list 'package-archives
;;              '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

; Others'
(when (locate-library "auctex")
  (require 'tex-site))
(require 'auto-complete)
(require 'comint)        ; better key handling in shell mode
;; (require 'doxymacs)
(require 'erlang-start)
(require 'flycheck-pycheckers)
(require 'highlight-beyond-fill-column)
(require 'jabber-keymap) ; This loads inconsistently on its own
(require 'magit)
(require 'paredit)
(require 'rainbow-mode)
(require 'saveplace)
(require 'slime-autoloads)
(require 'tramp)
(require 'uniquify)      ; stop naming buffers <2>
(require 'xclip)         ; OMG I love you - now I can copy and paste from linux
(require 'yasnippet)

; TODO: clean this up, it comes from http://www.braveclojure.com/basic-emacs/
(load "setup-clojure.el")
;; (load "~/.emacs.d/plugins/vendor/nxhtml/autostart.el")
; Mine
(require 'custom-faces)
(when (locate-library "disaster")
  (require 'disaster))
(require 'lambda)
(require 'lisp-customization)
(require 'load-edict)
(require 'msherry-go)
(require 'msherry-mail)
(require 'msherry-python)
(require 'org-customization)
(require 'tags-funcs)
(require 'totd)
(when (version< emacs-version "23")
  (progn
    (require 'old-emacs-git)
    (require 'vc-svn)))

; Theme
(when window-system
  (load-theme 'solarized-dark t))

; Modeline
(setq read-mail-command #'(lambda () (notmuch)))

; Autoloads
(autoload 'actionscript-mode "actionscript-mode" nil t) ; Connors' version
(autoload 'clojure-mode "clojure-mode" "Clojure Mode" t)
(autoload 'csv-mode "csv-mode" nil t)
(autoload 'ess-mode "ess-mode" "ESS mode" t)
(autoload 'js2-mode "js2" nil t)
(autoload 'php-mode "php-mode" nil t) ; either Mac or 22 only
(autoload 'turn-on-cldoc-mode "cldoc" "CL docs" t)

;;; Configure snippets
;; load all el files in the snippets directory, they're usually lisp
;; helpers that help with snippet expansions.
(setq core-custom-snippets (concat expanded-user-emacs-directory "snippets"))
(mapc 'load (directory-files core-custom-snippets t "^[^#].*el$"))
(yas-global-mode 1)
(yas-load-directory (concat expanded-user-emacs-directory "snippets"))

(auto-insert-mode 1)

;; Enable preview-latex
(add-hook 'LaTeX-mode-hook 'LaTeX-preview-setup)

;; File/mode associations
(add-to-list 'auto-mode-alist '("BUILD$" . bazel-mode))
(add-to-list 'auto-mode-alist '("\\.R$" . r-mode))
(add-to-list 'auto-mode-alist '("\\.as$" . actionscript-mode))
(add-to-list 'auto-mode-alist '("\\.avsc\\'" . json-mode))
(add-to-list 'auto-mode-alist '("\\.bzl$" . bazel-mode))
(add-to-list 'auto-mode-alist '("\\.csv$" . csv-mode))
(add-to-list 'auto-mode-alist '("\\.d$" . dtrace-script-mode))
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.pyst$" . python-mode))
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.pac$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.tsx$" . js2-mode))


;; Indentation settings
(setq-default indent-tabs-mode nil)     ; indent with spaces instead of tabs
; Use SLIME-style indentation, instead of Emacs' huge tab stops
(setq lisp-indent-function #'common-lisp-indent-function)
(setq standard-indent 4)
(setq c-default-style "bsd")
(setq c-basic-offset 4)                 ; imo uses four
(setq js2-basic-offset 2)               ; imo uses four

;; Settings that 24 broke
;; TODO: figure out why this doesn't work on the mac
(setq-default grep-find-use-xargs 'exec)

;; Other settings that 23 broke
(when (>= emacs-major-version 23)
    (setq ring-bell-function 'ignore
          split-height-threshold nil))      ; TODO: Not sure this is good -
                                            ; only seems needed in a terminal
                                            ; on Linux
(blink-cursor-mode 1)
(show-paren-mode t)
(ido-ubiquitous-mode 1)

; Display
(setq transient-mark-mode t            ; on by default in 23.x
      column-number-mode t
      global-font-lock-mode t
      inhibit-splash-screen t
      truncate-partial-width-windows nil
      ediff-split-window-function #'split-window-horizontally
; Functionality
      require-final-newline t           ; add only on save
      inferior-erlang-prompt-timeout t
      vc-delete-logbuf-window nil       ; don't close vc window when done
      vc-follow-symlinks t              ; don't always ask
      vc-log-show-limit 0               ; I like seeing the full log

; put the dabbrev (regular M-/ functionality) first
      hippie-expand-try-functions-list '(
          try-expand-dabbrev
          try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill
          try-complete-file-name-partially try-complete-file-name
          try-expand-all-abbrevs try-expand-list try-expand-line
          try-complete-lisp-symbol-partially try-complete-lisp-symbol)
      ediff-window-setup-function 'ediff-setup-windows-plain ; same window, pls
      mouse-yank-at-point t)            ; middle-click paste at point, not mouse

(setq-default show-trailing-whitespace nil
              fill-column 79            ; default of 72 is too narrow
              save-place t)             ; This didn't used to be buffer-local
(put 'upcase-region 'disabled nil)
(fset 'yes-or-no-p 'y-or-n-p)            ; stop forcing me to spell out "yes"

; Uniquifying
(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-separator "|")
(setq uniquify-after-kill-buffer-p t)
(setq uniquify-ignore-buffers-re "^\\*")

;; Copy files between dired buffers easily
(setq dired-dwim-target t)

;; Magit settings
(setq magit-popup-show-common-commands t)
(add-to-list 'git-commit-style-convention-checks
             'overlong-summary-line)

;; Bindings
(global-set-key (kbd "M-o") #'other-window)
(global-set-key (kbd "C-l") #'recenter)  ; recenter-top-bottom? No thanks
(global-set-key (kbd "<kp-delete>") (kbd "<deletechar>"))
;; I don't really need a key bound to the GPL
(global-set-key (kbd "C-h C-c") #'hc)
;; Forward-deletion of words
(global-set-key (kbd "M-<kp-delete>") #'kill-word)
;; Magit
(global-set-key (kbd "C-x g") #'magit-status)

(global-set-key (kbd "M-g") #'goto-line)
(global-set-key (kbd "C-c e") #'ediff-buffers)
(global-set-key [insertchar] nil)       ; Right next to delete!!
; scroll without moving point
(global-set-key (kbd "M-n") (lambda() (interactive) (scroll-up 1)))
(global-set-key (kbd "M-p") (lambda() (interactive) (scroll-down 1)))
(global-set-key (kbd "C-x \\") #'align-regexp)
(global-set-key (kbd "M-/") #'hippie-expand) ; better than dabbrev
(global-set-key (kbd "C-M-z") #'ack)

;; From http://doc.norang.ca/org-mode.html
(global-set-key (kbd "<f9> I") 'bh/punch-in)
(global-set-key (kbd "<f9> O") 'bh/punch-out)


; Readline in shell mode
(define-key comint-mode-map [up] #'comint-previous-input)
(define-key comint-mode-map [down] #'comint-next-input)
;;; On Mac OS, Ctrl-(arrow) changes desktops, so rebind these for paredit
(define-key paredit-mode-map (kbd "s-<right>") #'paredit-forward-slurp-sexp)
(define-key paredit-mode-map (kbd "s-<left>") #'paredit-forward-barf-sexp)
;; C-j is useful in scratch buffers, and I don't use the paredit version
(define-key paredit-mode-map (kbd "C-j") nil)

; Util functions for dired
(eval-after-load "dired"
  (lambda ()
    (define-key dired-mode-map "F" #'find-matching-pattern-under-dir)))
; IBuffer is better than list-buffers
(global-set-key (kbd "C-x C-b") #'ibuffer)

; Better buffer switching
(iswitchb-mode t)
; Don't prompt when creating scratch buffers
(setq iswitchb-prompt-newbuffer nil)

;; ; Trailing newlines are annoying in snippets
;; (setq-default mode-require-final-newline nil)

; Give us the ability to leave certain words highlighted - always got jealous
; when I saw this in vim
(global-hi-lock-mode 1)

; Don't complain about utf8 as a coding system name
(define-coding-system-alias 'utf8 'utf-8)

; Just adding this for Jedi for python - no clue what effect it has on other
; languages
(global-auto-complete-mode)

; Let's try flycheck instead of flymake, with a custom checker for our own
; wrapper script
(global-flycheck-mode 1)
;;; TODO: flymake-add-next-checker should let us chain existing checkers
;;; without needing our script at all -
;;; https://github.com/flycheck/flycheck/issues/185
(with-eval-after-load 'flycheck
  (add-hook 'flycheck-mode-hook
            '(lambda ()
              (local-set-key (kbd "C-c .") 'flycheck-next-error)
              (flycheck-pycheckers-setup)
              (flycheck-rust-setup))
            )
  ;; https://github.com/flycheck/flycheck/issues/1397
;;   (defun flycheck-fill-and-expand-error-file-names (errors directory)
;;   "Fill and expand file names in ERRORS relative to DIRECTORY.

;; Expand all file names of ERRORS against DIRECTORY.  If the file
;; name of an error is nil fill in the result of function
;; `buffer-file-name' in the current buffer.

;; Return ERRORS, modified in-place."
;;   (seq-do (lambda (err)
;;             (setf (flycheck-error-filename err)
;;                   (buffer-file-name)))
;;           errors)
;;   errors)
  )

; Fast jumps to windows
(window-numbering-mode)

; Create two windows initially if we have the room. Check both current width
; and width from default-frame-alist (if present), since the frame may not have
; been resized yet
(if (> (max (window-width)
            (or (cdr (assoc 'width default-frame-alist))
                0))
       160)
    (split-window-horizontally))


;; Mode hooks
(defvar programming-modes '(actionscript-mode c-mode conf-mode emacs-lisp-mode ess-mode
                            go-mode java-mode js-mode js2-mode lisp-mode makefile-mode
                            objc-mode python-mode ruby-mode rust-mode sh-mode tickscript-mode)
  "Modes used for programming.")


(defun programming-mode-hook ()
  "Hook common to all programming modes."
  (msherry-font-lock-fontify-todo)
  (msherry-font-lock-fontify-numbers)
  (flyspell-prog-mode)
  ;; (highlight-beyond-fill-column)
  ;; (doxymacs-mode)

  (add-hook 'before-save-hook 'delete-trailing-whitespace)

  ;; Second line of arglists gets two indents
  (c-set-offset 'arglist-cont-nonempty '++)
  (c-set-offset 'arglist-cont '++)
  (c-set-offset 'arglist-close '++)
  (setq show-trailing-whitespace t)
  ;; Completion that doesn't compete with OSX's program switching
  (local-set-key (kbd "s-<tab>") 'complete-symbol))


;; Colors in files where it makes sense
(add-hook 'css-mode-hook 'rainbow-mode)
(add-hook 'sass-mode-hook 'rainbow-mode)
(add-hook 'dot-mode-hook 'rainbow-mode)

; Add a common hook to every programming mode
(mapc #'(lambda (x)
        ; Get the mode's name and turn that into a mode hook
        (let ((mode-hook (intern (concat (symbol-name x) "-hook"))))
          (add-hook mode-hook 'programming-mode-hook)))
      programming-modes)

(add-hook 'text-mode-hook
          #'(lambda ()
            (flyspell-mode t)
            ;(longlines-mode t)
            ))

(add-hook 'python-mode-hook
          '(lambda ()
            ;; C-c C-p is now used by projectile, unbind it from elpy-flymake-previous-error
            (define-key elpy-mode-map (kbd "C-c C-p") nil)))

(add-hook 'rust-mode-hook 'cargo-minor-mode)
(add-hook 'rust-mode-hook 'racer-mode)
;;; At some point, rustfmt stopped respecting .rustfmt.toml files. I can't
;;; track down where, so hack it up with a hardcoded path for now.
(add-hook 'rust-mode-hook
          '(lambda ()
            (setq rust--format-args '("--config-path" "/Users/msherry/src/client/rust/nucleus/.rustfmt.toml"))
            (defun rust--format-call (buf)
              "Format BUF using rustfmt."
              (with-current-buffer (get-buffer-create "*rustfmt*")
                (erase-buffer)
                (insert-buffer-substring buf)
                (let* ((tmpf (make-temp-file "rustfmt"))
                       (ret (apply #'call-process-region (point-min) (point-max) rust-rustfmt-bin
                                   t `(t ,tmpf) nil rust--format-args)))
                  (unwind-protect
                       (cond
                         ((zerop ret)
                          (if (not (string= (buffer-string)
                                            (with-current-buffer buf (buffer-string))))
                              (copy-to-buffer buf (point-min) (point-max)))
                          (kill-buffer))
                         ((= ret 3)
                          (if (not (string= (buffer-string)
                                            (with-current-buffer buf (buffer-string))))
                              (copy-to-buffer buf (point-min) (point-max)))
                          (erase-buffer)
                          (insert-file-contents tmpf)
                          (error "Rustfmt could not format some lines, see *rustfmt* buffer for details"))
                         (t
                          (erase-buffer)
                          (insert-file-contents tmpf)
                          (error "Rustfmt failed, see *rustfmt* buffer for details"))))
                  (delete-file tmpf))))))

;; Know what's useless? A lot of flyspell keybindings
(eval-after-load "flyspell"
  '(progn
    (define-key flyspell-mode-map (kbd "C-.") nil)
    (define-key flyspell-mode-map (kbd "C-,") nil)))


;; Tramp adds a hook to auto-save files. Remove it
(remove-hook 'find-file-hook 'tramp-set-auto-save)
;; That's not really enough to turn off auto-save remotely, so add our own hook
;; here
(require 'custom-utils)
(defun turn-off-auto-save-mode-if-tramp ()
  "Disable `auto-save-mode' if the file is remote."
  (when (not (file-is-local-and-writable-p))
    (auto-save-mode nil)))

(add-hook 'find-file-hook 'turn-off-auto-save-mode-if-tramp)

;; Mouse wheel scrolling in xterm
(unless window-system
  (xterm-mouse-mode 1)
  (mouse-wheel-mode 1)
  (global-set-key [mouse-4] '(lambda ()
                               (interactive)
                               (scroll-down 5)))
  (global-set-key [mouse-5] '(lambda ()
                               (interactive)
                               (scroll-up 5))))

(defun bh-choose-header-mode ()
  "Choose the correct C style (Objective-C, C++, C) when opening a .h file.

  Based on the presence of a similarly-named .m/.cpp file.

Based on
http://bretthutley.com/programming/emacs/opening-a-cobjective-cc-header-file-in-emacs/,
but with additional hacks for frameworks by Marc Sherry"
  (interactive)
  (let ((fn (buffer-file-name)))
    (if (string-equal (substring fn -2) ".h")
        (progn
          ;; OK, we got a .h file, if a .m file exists we'll assume it's an
          ;; objective c file. Otherwise, we'll look for a .cpp file.
          (let ((dot-m-file (concat (substring fn 0 -1) "m"))
                (dot-cpp-file (concat (substring fn 0 -1) "cpp")))
            (if (file-exists-p dot-m-file)
                (objc-mode)
                (if (file-exists-p dot-cpp-file)
                    (c++-mode))
                ;; Could be C, or could be Objective-C with no matching .m file
                ;; (e.g., framework headers). Check for the #import directive,
                ;; which is mostly Objective-C (and Microsoft-specific C++).
                (progn
                  (if (with-temp-buffer
                        (insert-file-contents fn)
                        (goto-char (point-min))
                        (re-search-forward "^#import\\|@\"\\|@protocol" nil t))
                      (objc-mode)))))))))
(add-hook 'find-file-hook 'bh-choose-header-mode)

;; Modify functions that aren't quite right
(defadvice dired-mark-files-containing-regexp (before unmark-all-first
                                                      (regexp &optional marker-char)
                                                      activate)
  "Unmark marked files in dired mode before searching for new ones."
  (dired-unmark-all-files ?\r))

(defadvice dired-mark-python-with-errors (before unmark-all-first-2
                                                      (regexp &optional marker-char)
                                                      activate)
  "Unmark marked files in dired mode before searching for new ones."
  (dired-unmark-all-files ?\r))


;; Emacs server
(server-start)
;; Don't prompt re: killing buffers with clients open
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)


;; Replace functions that are completely wrong

(eval-after-load "vc-svn"
  '(progn
    (defun vc-svn-annotate-command (file buf &optional rev)
      "Marc's version of this - exactly the same as stock, but 'async
has been replaced with t -- without this, we only get partial
annotations"
      (vc-svn-command buf 't file "annotate" (if rev (concat "-r" rev))))))


(eval-after-load "vc-hg"
  '(progn
    (defun vc-hg-annotate-command (file buffer &optional revision)
      "Marc's version of vc-hg-annotate-command. Adds the -u option"
      (vc-hg-command buffer 0 file "annotate" "-u" "-d" "-n"
                     (when revision (concat "-r" revision))))
    ;; Since we modified the annotate command, we have to retell vc how to
    ;; get the version information. This is dumb.
    ;; Format:
    ;; username (VERSION_NUMBER) (DATE) (FILENAME)/NOTHING: CONTENTS
    (defconst vc-hg-annotate-re
      "^[ \t]*[^ ]+ +\\([0-9]+\\) \\(.\\{30\\}\\)\\(?:\\(: \\)\\|\\([^:]+\\): \\)")
      ;; "^[ \t]*\\([0-9]+\\) \\(.\\{30\\}\\)\\(?:\\(: \\)\\|\\(?: +\\(.+\\): \\)\\)")

    ;; (defun vc-hg-annotate-time ()
    ;;   (when (looking-at vc-hg-annotate-re)
    ;;     (goto-char (match-end 0))
    ;;     (vc-annotate-convert-time
    ;;      (date-to-time (match-string-no-properties 3)))))

    ;; (defun vc-hg-annotate-extract-revision-at-line ()
    ;;   (save-excursion
    ;;     (beginning-of-line)
    ;;     (when (looking-at vc-hg-annotate-re)
    ;;       (if (match-beginning 4)
    ;;           (match-string-no-properties 2)
    ;;           (cons (match-string-no-properties 2)
    ;;                 (expand-file-name (match-string-no-properties 5)
    ;;                                   (vc-hg-root default-directory)))))))
))


(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)


(defun buffer-mode-histogram ()
  "Display a histogram of Emacs buffer modes.

http://blogs.fluidinfo.com/terry/2011/11/10/emacs-buffer-mode-histogram/"
  (interactive)
  (let* ((totals `())
         (buffers (buffer-list()))
         (total-buffers (length buffers))
         (ht (make-hash-table :test `equal)))
    (save-excursion
      (dolist (buffer buffers)
        (set-buffer buffer)
        (let ((mode-name (symbol-name major-mode)))
          (puthash mode-name (1+ (gethash mode-name ht 0)) ht))))
    (maphash (lambda (key value)
               (setq totals (cons (list key value) totals)))
             ht)
    (setq totals (sort totals (lambda (x y) (> (cadr x) (cadr y)))))
    (with-output-to-temp-buffer "Buffer mode histogram"
      (princ (format "%d buffers open, in %d distinct modes\n\n"
                      total-buffers (length totals)))
      (dolist (item totals)
        (let
            ((key (car item))
             (count (cadr item)))
          (if (equal (substring key -5) "-mode")
              (setq key (substring key 0 -5)))
          (princ (format "%2d %20s %s\n" count key
                         (make-string count ?+))))))))

;; http://emacsredux.com/blog/2013/06/21/eval-and-replace/
(defun eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))
(global-set-key (kbd "C-c C-e") 'eval-and-replace)


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(button ((t (:foreground "#b58900" :underline t))))
 '(csv-separator-face ((t (:foreground "cornflower blue"))))
 '(diff-added ((t (:background "#002b36" :foreground "green4"))))
 '(diff-refine-added ((t (:inherit diff-refine-change :background "dark green"))))
 '(diff-refine-removed ((t (:inherit diff-refine-change :background "red4"))))
 '(ediff-current-diff-B ((((class color) (min-colors 16)) (:background "#ff00ff" :foreground "blue"))))
 '(ediff-current-diff-C ((t (:background "#888833" :foreground "black"))))
 '(ediff-even-diff-B ((((class color) (min-colors 16)) (:background "Grey" :foreground "black"))))
 '(error ((t (:foreground "Coral"))))
 '(font-lock-constant-face ((t nil)))
 '(font-lock-variable-name-face ((t nil)))
 '(org-agenda-current-time ((t (:inherit org-time-grid :foreground "SpringGreen3"))))
 '(org-habit-ready-face ((t (:background "green4" :foreground "#859900"))))
 '(org-habit-ready-future-face ((t (:background "green4"))))
 '(region ((((class color) (min-colors 24)) (:background "#00ffff"))))
 '(warning ((t (:background "#a4caff")))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ack-command "ag ")
 '(appt-delete-window-function (lambda nil))
 '(appt-disp-window-function 'msherry/appt-disp-window)
 '(appt-display-format 'window)
 '(appt-display-interval 5)
 '(appt-message-warning-time 10)
 '(auto-revert-verbose nil)
 '(custom-safe-themes
   '("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default))
 '(dired-bind-jump nil)
 '(display-time-default-load-average nil)
 '(display-time-format "")
 '(display-time-mail-face 'hi-blue)
 '(display-time-mail-function 'msherry-new-important-mail)
 '(display-time-mode t)
 '(elpy-eldoc-show-current-function nil)
 '(elpy-modules
   '(elpy-module-company elpy-module-eldoc elpy-module-pyvenv elpy-module-sane-defaults))
 '(elpy-project-ignored-directories
   '(".bzr" "CVS" ".git" ".hg" ".svn" ".tox" "build" "dist" ".cask" ".mypy_cache"))
 '(elpy-rpc-python-command "python2")
 '(elpy-rpc-timeout 10)
 '(epg-pinentry-mode 'loopback)
 '(exec-path-from-shell-variables '("PATH" "MANPATH" "CARGO_HOME" "RUST_SRC_PATH" "GOPATH"))
 '(flycheck-checker-error-threshold nil)
 '(flycheck-display-errors-delay 0.15)
 '(flycheck-flake8-maximum-line-length 120)
 '(flycheck-global-modes '(not org-mode org-agenda-mode))
 '(flycheck-highlighting-mode 'lines)
 '(flycheck-pycheckers-checkers '(pylint pep8 mypy2 mypy3 bandit))
 '(flycheck-pycheckers-enable-codes '("W0613"))
 '(flycheck-pycheckers-max-line-length 100)
 '(flycheck-rust-check-tests t)
 '(gc-cons-threshold 100000000)
 '(git-commit-summary-max-length 79)
 '(global-eldoc-mode nil)
 '(ido-cr+-function-whitelist '(org-agenda-refile org-refile))
 '(jabber-account-list
   '(("msherry@gmail.com"
      (:network-server . "talk.google.com")
      (:port . 5223)
      (:connection-type . ssl))))
 '(jabber-alert-message-hooks
   '(jabber-message-wave jabber-message-echo jabber-message-scroll))
 '(jabber-alert-message-wave "/System/Library/Sounds/Bottle.aiff")
 '(jabber-auto-reconnect t)
 '(magit-log-arguments '("--graph" "--color" "--decorate" "-n256"))
 '(magit-push-always-verify nil)
 '(magit-tag-arguments '("--annotate"))
 '(mm-inline-large-images 'resize)
 '(mm-text-html-renderer 'shr)
 '(notmuch-after-tag-hook
   '((lambda
         (&rest rest)
       (shell-command
        (concat "touch "
                (shell-quote-argument msherry-email-update-file-path))))))
 '(notmuch-archive-tags '("-INBOX"))
 '(notmuch-crypto-process-mime t)
 '(notmuch-saved-searches
   '((:name "inbox" :query "tag:INBOX" :key "i")
     (:name "unread" :query "tag:unread AND tag:INBOX" :key "u")
     (:name "Ideas" :query "tag:Ideas AND tag:unread" :key "I")
     (:name "flagged" :query "tag:flagged" :key "f")
     (:name "Flawless" :query "tag:Flawless AND tag:unread")
     (:name "sent" :query "tag:sent" :key "t")
     (:name "drafts" :query "tag:draft" :key "d")
     (:name "all mail" :query "*" :key "a")))
 '(notmuch-search-oldest-first nil)
 '(ns-alternate-modifier 'super)
 '(ns-command-modifier 'meta)
 '(org-agenda-clockreport-parameter-plist '(:link t :maxlevel 3))
 '(org-agenda-custom-commands
   '(("c" "Agenda and all unscheduled/everyday TODO's / unfiled"
      ((agenda ""
               ((org-super-agenda-groups
                 '((:log t)
                   (:name "Schedule" :time-grid t)
                   (:name "Priority" :priority "A")
                   (:name "Overdue" :deadline past)
                   (:name "Due today" :deadline today)
                   (:name "Today" :scheduled today)
                   (:name "Due soon" :deadline future)
                   (:name "No deadline" :tag "WORK")))))
       (tags "EVERYDAY"
             ((org-agenda-overriding-header "Every day")
              (org-agenda-skip-function
               '(org-agenda-skip-entry-if 'regexp "\\^* .*:EVERYDAY\\|^\\*\\*\\*"))))
       (todo ""
             ((org-agenda-overriding-header "Unscheduled TODOs")
              (org-agenda-skip-function
               '(org-agenda-skip-entry-if 'deadline 'scheduled))))
       (tags "TOREAD"
             ((org-agenda-overriding-header "To read")
              (org-agenda-skip-function
               '(org-agenda-skip-entry-if 'regexp "\\* To read.*:TOREAD:"))))
       (tags "REFILE"
             ((org-agenda-overriding-header "To refile"))))
      nil)
     ("N" "Notes" tags "NOTE"
      ((org-agenda-overriding-header "Notes")
       (org-tags-match-list-sublevels t)))
     ("o" "Completed tasks older than 6 months (http://gnuru.org/article/1639/org-mode-find-all-done-items-older-than-2-months)" tags "CLOSED<\"<-6m>\"" nil)
     ("w" "Tasks completed within the past week" tags "CLOSED>=\"<-7d>\"" nil)))
 '(org-agenda-files
   '("/Users/msherry/.emacs.d/org/personal.org" "/Users/msherry/.emacs.d/org/dropbox-cal.org" "/Users/msherry/.emacs.d/org/flagged.org" "/Users/msherry/.emacs.d/org/personal-cal.org" "/Users/msherry/.emacs.d/org/refile.org" "/Users/msherry/.emacs.d/org/work.org" "/Users/msherry/.emacs.d/org/llc.org"))
 '(org-agenda-persistent-filter t)
 '(org-agenda-prefix-format
   '((agenda . " %i %-12:c%?-12t% s")
     (timeline . "  % s")
     (todo . " %i %-12:c%l")
     (tags . " %i %-12:c")
     (search . " %i %-12:c")))
 '(org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled)
 '(org-agenda-skip-scheduled-if-deadline-is-shown t)
 '(org-agenda-span 'day)
 '(org-agenda-start-on-weekday nil)
 '(org-agenda-sticky t)
 '(org-agenda-time-grid
   '((daily today)
     (800 1000 1200 1400 1600 1800 2000)
     "......" "----------------"))
 '(org-agenda-timegrid-use-ampm t)
 '(org-babel-clojure-backend 'cider)
 '(org-babel-load-languages
   '((C . t)
     (awk . t)
     (clojure . t)
     (dot . t)
     (emacs-lisp . t)
     (gnuplot . t)
     (lisp . t)
     (python . t)
     (ruby . t)
     (js . t)
     (shell . t)
     (sql . t)))
 '(org-capture-templates
   '(("t" "TODO" entry
      (file "~/.emacs.d/org/refile.org")
      "* TODO %?
 %U
 %a
 " :clock-in t :clock-resume t)
     ("w" "work TODO" entry
      (file+headline "~/.emacs.d/org/work.org" "Tasks")
      "** TODO %?
 %a
 " :clock-in t :clock-resume t)
     ("p" "personal TODO" entry
      (file+headline "~/.emacs.d/org/personal.org" "Tasks")
      "** TODO %?
 %a
 " :clock-in t :clock-resume t)
     ("l" "LLC TODO" entry
      (file+headline "~/.emacs.d/org/llc.org" "Tasks")
      "** TODO %?
 %a
 " :clock-in t :clock-resume t)
     ("n" "note" entry
      (file "~/.emacs.d/org/refile.org")
      "* %? :NOTE:
 %U
 %a
 " :clock-in t :clock-resume t)
     ("m" "Meeting" entry
      (file+olp "~/.emacs.d/org/work.org" "Meetings")
      "* %? :MEETINGS:
 " :clock-in t :clock-resume t)))
 '(org-clock-out-remove-zero-time-clocks t)
 '(org-clock-persist nil)
 '(org-clock-report-include-clocking-task t)
 '(org-enforce-todo-dependencies t)
 '(org-export-backends '(ascii html icalendar latex md odt))
 '(org-export-with-sub-superscripts '{})
 '(org-habit-show-habits-only-for-today nil)
 '(org-image-actual-width '(300))
 '(org-indirect-buffer-display 'current-window)
 '(org-log-done 'time)
 '(org-mobile-agendas '("c"))
 '(org-mobile-files-exclude-regexp "-cal.org$")
 '(org-mobile-force-id-on-agenda-items nil)
 '(org-modules
   '(org-bbdb org-bibtex org-docview org-gnus org-habit org-info org-irc org-mhe org-mouse org-rmail org-w3m org-notmuch))
 '(org-refile-use-outline-path t)
 '(org-src-tab-acts-natively t)
 '(org-use-sub-superscripts '{})
 '(package-selected-packages
   '(ac-geiser ack auctex bazel-mode blacken cargo cider clojure-mode clojure-mode-extra-font-locking diff-hl dtrace-script-mode el2markdown elpy ess esup exec-path-from-shell feature-mode flx-ido flycheck-clojure flycheck-package flycheck-pycheckers flycheck-rust fxrd-mode geiser gitignore-mode go-mode graphviz-dot-mode httpcode ido-completing-read+ jabber jedi json-mode latex-preview-pane magit markdown-preview-mode notmuch oauth2 org-agenda-property org-jira org-mru-clock org-plus-contrib org-pomodoro org-super-agenda package-lint paredit php-mode pinentry projectile protobuf-mode puppet-mode pymacs python-mode racer rainbow-mode rust-mode s sass-mode slime solarized-theme suggest tagedit thrift tickscript-mode virtualenv window-numbering yaml-mode yasnippet-snippets))
 '(projectile-enable-caching t)
 '(projectile-globally-ignored-modes
   '("erc-mode" "help-mode" "completion-list-mode" "Buffer-menu-mode" "gnus-.*-mode" "occur-mode" "graphviz-dot-mode"))
 '(projectile-mode t nil (projectile))
 '(python-shell-interpreter "ipython")
 '(racer-rust-src-path nil)
 '(rust-format-on-save t)
 '(safe-local-variable-values
   '((rust--format-args quote
      ("--config-path" "/Users/msherry/src/client/rust/nucleus/.rustfmt.toml"))
     (flycheck-checker . go-lint)
     (tickscript-kapacitor-version . "1.3")
     (tickscript-kapacitor-version . "1.4")
     (tickscript-series-name . "medians_dev")
     (tickscript-series-dbrp . "apogee.autogen")
     (tickscript-kapacitor-url . http://localhost:9092)
     (tickscript-kapacitor-url . http://localhost:5092)
     (tickscript-series-type . "stream")
     (tickscript-series-dbrp . "desktop_client.default")
     (tickscript-series-type . "batch")
     (tickscript-series-name . "medians")))
 '(tickscript-add-extra-graph-options t)
 '(tramp-syntax 'simplified nil (tramp)))


;; (eval-after-load 'cc-mode
;;   '(progn
;;      (defun my-c-mode-common-hook ()
;;        (define-key c-mode-base-map (kbd "C-c C-d") 'disaster))
;;     (add-hook 'c-mode-common-hook 'my-c-mode-common-hook)))

(byte-recompile-directory expanded-user-emacs-directory)

;; Mitigate Bug#28350 (security) in Emacs 25.2 and
;; earlier. http://www.openwall.com/lists/oss-security/2017/09/11/1
(eval-after-load "enriched"
  '(defun enriched-decode-display-prop (start end &optional param)
    (list start end)))


;;; Snippet for auto-scping a file on save
; (add-hook 'after-save-hook (lambda () (shell-command (format "scp %s apogee-influxdb:kapacitor-tools/" (buffer-name)))) nil t)

;;; Set the PATH, even if not started from the shell.  Formerly did this
;;; ourselves, replaced with exec-path-from-shell. Must be done after the call
;;; to `custom-set-variables' has set things for us.
(exec-path-from-shell-initialize)

;;; Misc
(defun mirth ()
  "Browse code.pp for the current file/line."
  (interactive)
  (let* ((path (buffer-file-name))
         (repo-root (s-chomp (shell-command-to-string "git rev-parse --show-toplevel")))
         (repo-name (s-chomp (shell-command-to-string (format "basename %s" repo-root))))
         (url-root (cond ((string= repo-name "client") "desktop-client")
                         (t repo-name)))
         (relative-path (file-relative-name path repo-root)))
    (let ((url (format "https://code.pp.dropbox.com/view/%s/%s#L%s"
                       url-root relative-path (number-to-string (line-number-at-pos)))))
      (browse-url url))))

(global-set-key (kbd "C-c C-'") #'mirth)

(provide 'init)

;;; init.el ends here
