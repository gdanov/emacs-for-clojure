(setq ido-default-buffer-method `selected-window)

(global-set-key (kbd "C-x C-d" ) 'ido-dired)

(global-set-key (kbd "M-x") 'helm-M-x)

(global-set-key (kbd "C-.") 'helm-imenu)

(global-set-key (kbd "<C-s-tab>") 'other-window)
(global-set-key (kbd "<s-tab>") 'other-window)
(global-set-key (kbd "<M-tab>") 'ido-switch-buffer)

(global-set-key (kbd "C-s-s") 'helm-regexp)

(global-set-key (kbd "C-s-q") 'indent-region)    

(global-set-key (kbd "<M-SPC>") 'fixup-whitespace)

;; (add-to-list 'package-pinned-packages '(cider . "melpa-stable") t)

(defun setup-imenu ()
  ;; clojure-mode seems to be bit brutal, see the manual
  (setq imenu-create-index-function 'imenu-default-create-index-function)
  (setq imenu-generic-expression
        (append
				 '(("fact(s)" "(\\(fact\\|facts\\) +\"\\(.+\\)\"" 2))
				 (map 'list
							(lambda (name)
								(list name
											(concatenate 'string
																	 "^(\\([[:alnum:]-_.]+/\\)*" name " +\\([[:alnum:]?_./\\:*\\-]+\\)")
											2))
							'("def" "defn" "defprotocol" "defrecord" "defmulti" "defmacro" "defmethod"))
				 )
        )
  (imenu-add-menubar-index)
  )

(global-set-key [(f5)]
                '(lambda ()
                   (interactive)
                   (setup-imenu)
                   ))

(add-hook 'clojure-mode-hook
          (lambda ()
            (setup-imenu)
            ))


(global-set-key (kbd "C-s") 'helm-occur)      

(setq helm-M-x-fuzzy-match 1)
(setq helm-follow-mode 1)

(setq mac-command-modifier 'control)
(setq mac-control-modifier 'meta)
(setq mac-option-modifier 'super)

(setq-default indent-tabs-mode 1)
(setq-default tab-width 2)
;; (setq indent-line-function 'insert-tab)


(global-company-mode)

;; works as expected, but only for 2 buffers
(defun switch-to-previous-buffer ()
	(interactive)
	(switch-to-buffer (other-buffer (current-buffer) 1)))

																				;(global-set-key (kbd "<f12>") 'switch-to-previous-buffer)

(setq buffer-stack-show-position 'buffer-stack-show-position-buffers)

																				;(global-set-key [(f10)] 'buffer-stack-bury)
																				;(global-set-key [(control f10)] 'buffer-stack-bury-and-kill)

(global-set-key [(f6)] 'buffer-stack-down)
(global-set-key [(f7)] 'buffer-stack-up)

(global-set-key [(shift f6)] 'buffer-stack-bury-thru-all)
(global-set-key [(S shift f6)] 'buffer-stack-down-thru-all)
(global-set-key [(shift f7)] 'buffer-stack-up-thru-all)



(global-set-key [(f8)]
                '(lambda ()
									 (interactive)
									 (print "#########################")


									 
									 (print (first(window-tree)))
									 (print (buffer-file-name (window-buffer)))
									 (print (persp-all-names))
									 ;; (print (persp-window-configuration persp-curr))
									 (gethash "jira" perspectives-hash)))

(toggle-frame-maximized)

;; PESPECTIVE
(require 'persp-projectile)
(persp-mode)

;; POPWIN
(require 'popwin)
(popwin-mode 1)
(global-set-key (kbd "C-z") popwin:keymap)

(push '("*HTTP Response*" :noselect t :stick nil) popwin:special-display-config)
(push "*cider-error*" popwin:special-display-config)
(push '(cider-repl-mode) popwin:special-display-config)

;; SCROLLING

;; (setq scroll-step           1
;; scroll-conservatively 10000)
(setq mouse-wheel-scroll-amount '(2 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

;; CIDER
(setq cider-lein-parameters "trampoline repl :headless")
(setq cider-repl-pop-to-buffer-on-connect nil)
(setq cider-prompt-save-file-on-load nil)
(setq cider-repl-use-pretty-printing t)

;; Clojure keys
(global-set-key (kbd "RET") (key-binding (kbd "M-j"))) ;; seems to not work
(global-set-key (kbd "<C-return>")
								'(lambda ()
									 (interactive)
									 (move-beginning-of-line nil)
									 (newline-and-indent)
									 (previous-line)                     
									 (indent-for-tab-command)))

(global-set-key `[s-down] `scroll-up-line)
(global-set-key `[s-up] `scroll-down-line)

;;
(add-to-list 'auto-mode-alist '("\\.rest-client\\'" . restclient-mode))

;;
(require 'clj-refactor)
(add-hook 'clojure-mode-hook (lambda ()
															 (clj-refactor-mode 1)
															 (cljr-add-keybindings-with-prefix "C-&")
															 (yas/minor-mode 1)
															 (setq clojure-defun-style-default-indent t)
															 ))


;; -----------------------
(defun jira-setup ()
  (interactive)
  (delete-other-windows)
	
  (split-window-horizontally) ;; -> |
  (find-file "~/work/playground/jira/src/jj/repl.clj")

  (next-multiframe-window)
	
  ;; (cider-jack-in)

	(helm-projectile)

	(setq helm-follow-mode-persistent 1)
	(helm-occur-init-source)
	(helm-attrset 'follow 1 helm-source-occur)
  )

(defun nan-setup ()
	(interactive)
	
	(persp-switch "nan")
	
	(delete-other-windows)

	(find-file "~/work/playground/nan/src/root.clj")
	(split-window-horizontally)
	)


(persp-switch ".emacs.d")
(find-file "~/.emacs.d/customizations/gdanov.el")

(persp-switch "jira" )
(jira-setup)

(setq cider-annotate-completion-candidates 1)

(define-key projectile-mode-map [remap projectile-find-file-dwim] 'helm-projectile-grep) ;c-c p g

(defun my-forward-whitespace (arg)
  "Move point to the end of the next sequence of whitespace chars.
Each such sequence may be a single newline, or a sequence of
consecutive space and/or tab characters.
With prefix argument ARG, do it ARG times if positive, or move
backwards ARG times if negative."
  (interactive "^p")
  (if (natnump arg)
      (re-search-forward "[({\[ /\t\n]+" nil 'move)
    ))

(defun my-backward-whitespace (arg)
  (interactive "^p")
  (re-search-backward "\\([ \[({/'`\n\t][:_]*\\w+\\)\\|\\([ \t]\"\\)" nil 'move)
  (forward-char))


(global-set-key (kbd "M-f") 'my-forward-whitespace)
(global-set-key (kbd "M-b") 'my-backward-whitespace)



;; --------------------
(load "savewin.el")
