
;; ----- save -------

(defun walk-win-tree (cfg)
	(consq (if (car cfg) "vert" "horiz")
				 (walk-wins (nthcdr 2 cfg)))
	)

(defun walk-wins (win-list)
	(mapcar
	 (lambda (w)
		 (if (listp w)
				 (walk-win-tree w)
			 (get-win-content-name (window-buffer w))))
	 win-list))

(defun get-win-content-name (b)
	(if (buffer-file-name b)
			`("file" ,(buffer-file-name b))
		`("buff" ,(buffer-name b)))
	)

(defun get-win-cfg-file-name ()
	(concat "~/.emacs.d/"
					(nth (persp-curr-position) (persp-all-names))
					".persp")
	)

(defun save-win-cfg ()
	"save the window config of the currpnt perspective in .emacs.d folder"
	(interactive)
	(let ((win-list (walk-win-tree (car (window-tree)))))
		(with-temp-file (get-win-cfg-file-name)
			(pp `(quote ,win-list) (current-buffer)))))

;; ----- restore -----

(defun slurp (f)
	(with-temp-buffer
		(insert-file-contents f)
		(buffer-substring-no-properties (point-min) (point-max))
		))

(defun load-win-cfg ()
	"read into list the window config for the current perspective from saved file"
	(eval (read (slurp (get-win-cfg-file-name)))))

(defun children (win)
	(let ((f (window-child win))
				(res (list)))
		(while f
			(setq res (append res (list f)))
			(setq f (window-next-sibling f)))
		res
		))

(defun split (op win lst)
	"lst is list of window/buffer descriptions"
	
	;; do the splitting
	(mapcar
	 (lambda (w) (split-window win nil op))
	 (cdr lst)														;one less
	 )
	
	(balance-windows)
	
	;;populate with files/buffers
	(mapcar
	 (lambda (o)
		 ;; (win . buffspec)
		 (let ((buffspec (cadr o))
					 type
					 win
					 fname)
			 (setq type (car buffspec))
			 (setq win (car o))
			 (setq fname (cadr buffspec))
			 
			 (cond
				((string= "file" type)
				 (progn
					 (with-selected-window win
						 (find-file fname))))
				((string= "buff" type)
				 (condition-case nil
						 (set-window-buffer win fname)
					 (error (progn
										(print (list "could not find buffer" fname))
										(set-window-buffer win "*Messages*"))))
				 )
				(t
				 (restore-win buffspec win))
				)))
	 (cl-mapcar 'list (children (window-parent win)) lst)
	 ))

(defun restore-win (win-list w)
	"expects win-list to be (<direction> <win-desc>..)"
	(split
	 (cond
		((string= "vert" (car win-list)) nil)
		((string= "horiz" (car win-list)) t))
	 w
	 (cdr win-list))
	)

(defun restore-win-cfg ()
	(interactive)
	(delete-other-windows)
	(restore-win (load-win-cfg)
							 (frame-first-window)
							 ))
