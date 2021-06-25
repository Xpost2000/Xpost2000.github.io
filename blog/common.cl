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

;; What are the other lisp runtime equivalents?
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

;; This produces a linked list (not the data structure kind persay) of
;; links. I use this for generating the blog page, but technically I can use
;; this for general articles as well.
;; You are expected to sort these in any order you wish before hand.
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

;; From the blog format
;; I do require space separation.
;; M/D/Y HR:MIN AM/PM
(defun date-string->date-month-year-triplet (date-string)
  (map 'list #'parse-integer (uiop:split-string date-string :separator '(#\/))))

(defun time-string->time-pair (time &optional antem/post.-merdium)
  (if time
   (destructuring-bind (hour minute) (map 'list #'parse-integer (uiop:split-string time :separator '(#\:)))
     (when antem/post.-merdium
       (cond
         ((and (string= antem/post.-merdium "PM")
               (not (= hour 12)))
          (incf hour 12))
         ((and (string= antem/post.-merdium "AM")
               (= hour 12))
          (decf hour))))
     (list hour minute))
   (list 0 0)))

(time-string->time-pair "11:06" "PM")

(defun create-encoded-time-from-date-string (date-string)
  (destructuring-bind (date &optional time antem/post.-merdium) (uiop:split-string date-string :separator '(#\Space))
    (let ((date-triplet (date-string->date-month-year-triplet date))
          (time-pair (time-string->time-pair time antem/post.-merdium)))
            (encode-universal-time
             0
             (second time-pair)
             (first time-pair)
             (second date-triplet)
             (first date-triplet)
             (third date-triplet)))))

(defun relative-directory-listing (directory)
  (map 'list #'enough-namestring (uiop:directory-files directory)))

(defun file-lines (file-path)
  (with-open-file (file-stream file-path)
    (values
     (loop for line = (read-line file-stream nil nil)
           while line collect line)
     file-path)))
