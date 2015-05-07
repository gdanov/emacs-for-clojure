(setq ido-default-buffer-method `selected-window)

(global-set-key (kbd "C-x C-d" ) 'ido-dired)

(global-set-key (kbd "M-x") 'helm-M-x)

(global-set-key (kbd "C-.") 'helm-imenu)

(global-set-key (kbd "<C-s-tab>") 'other-window)
(global-set-key (kbd "<s-tab>") 'ido-switch-buffer
                                        ;'buffer-stack-down
                                ;'switch-to-previous-buffer
)

(global-set-key (kbd "C-s-s") 'helm-regexp)

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

(setq mac-command-modifier 'control)
(setq mac-control-modifier 'super)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq indent-line-function 'insert-tab)

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

(toggle-frame-maximized)

(require 'popwin)
(popwin-mode 1)

(require 'persp-projectile)
(persp-mode)

;; -----------------------
(defun my-setup ()
  (interactive)
  (delete-other-windows)
  ;; (dired "~/work/playground/jira/src")
  (find-file "~/work/playground/jira/src/jj/repl.clj")

  (split-window-horizontally) ;; -> |
  (next-multiframe-window)

  (setq cider-lein-parameters "trampoline repl :headless")
  (setq cider-repl-pop-to-buffer-on-connect nil)
  (cider-jack-in)
  (cider-repl-toggle-pretty-printing)
  

  (global-set-key (kbd "RET") (key-binding (kbd "M-j")))
  (global-set-key (kbd "<C-return>")
                  '(lambda ()
                     (interactive)
                     (move-beginning-of-line nil)
                     (newline-and-indent)
                     (previous-line)                     
                     (indent-for-tab-command)))
)



(persp-switch ".emacs.d")
(find-file "~/.emacs.d/customizations/gdanov.el")

(persp-switch "jira" )
(my-setup)

(helm-projectile)

(add-hook 'helm-mode-hook
 (lambda () (helm-follow-mode 1)))


;; --------------------
