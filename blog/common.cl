;; This is to get ASDF and quicklisp to work since usually I start from a REPL
;; This is basically whatever quicklisp injects by default. Most common lisp users have
;; it so might as well.
#-quicklisp
(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

(setf asdf:*central-registry*
      '(*default-pathname-defaults*))
(ql:quickload :uiop :silent t)

(defun command-line-arguments ()
  #+sbcl sb-ext:*posix-argv*)

;; Avoid <PRE> this generator will crap itself since that requires real pretty printing...
(defun empty-stringp (s) (or (string= s "") (string= s " ")))

(defun file-compare-by-write-date (a b)
  (< (file-write-date a) (file-write-date b)))

(defun repeat (elt count) ;; string repeat
           (if (= count 1)
               elt
               (concatenate 'string elt (repeat elt (1- count)))))

(defun page-links (links)
  (let ((length (length links)))
      (labels ((in-bounds (index) (and (>= index 0) (< index length)))
               (safe-elt (index) (if (in-bounds index) (elt links index))))
        (loop for index from 0 upto (1- length)
              collect 
              (list
               :current (safe-elt index)
               :previous (safe-elt (1- index)) 
               :next (safe-elt (1+ index)))))))
