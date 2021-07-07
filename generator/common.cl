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

;; this has an unintuitive use me thinks.
(defun date-string< (a b)
  (< (create-encoded-time-from-date-string a)
     (create-encoded-time-from-date-string b)))
(defun date-string<= (a b)
  (<= (create-encoded-time-from-date-string a)
     (create-encoded-time-from-date-string b)))
(defun date-string> (a b)
  (> (create-encoded-time-from-date-string a)
     (create-encoded-time-from-date-string b)))
(defun date-string>= (a b)
  (>= (create-encoded-time-from-date-string a)
     (create-encoded-time-from-date-string b)))
(defun date-string= (a b)
  (= (create-encoded-time-from-date-string a)
     (create-encoded-time-from-date-string b)))
(defun sort-by-date-string (obtain-date-string &optional (method '<))
  (lambda (a b)
    (let ((function (intern (concatenate 'string "DATE-STRING" (symbol-name method)))))
      (funcall function
               (funcall obtain-date-string a)
               (funcall obtain-date-string b)))))

(defun repeat (elt count) ;; string repeat
  (if (zerop count)
      ""
      (if (= count 1)
          elt
          (concatenate 'string elt (repeat elt (1- count))))))

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

(defun with-common-page-template (&key
                                    (depth 1)
                                    page-title
                                    body
                                    header-extra
                                    (modeline-text "welcome-to-my-website")
                                    modeline-links
                                    current-link-text
                                    current-link)
  `(:html
    (,(generate-page-header depth (concatenate 'string page-title " - Jerry Zhu / Xpost2000") header-extra)
     (:body
      ((:div ((:class "body-container"))
             ,body) 
       (:div ((:id "ugly-ass-gutter")) "")
       ,(generate-modeline-and-minibuffer
         modeline-text
         (or current-link-text (getf current-link :current))
         modeline-links
         current-link)
       ,(script-tag depth))))))

(defun remove-file-extension-from-string (string)
  (subseq string 0 (position #\. string :from-end t)))

(defun page-content (title lines &rest list-elements)
  `((:h1 ,title)
    ,@(concatenate 'list
                   (map 'list
                        (lambda (x)
                          (if (empty-stringp x) 
                              '(:br) (list :p x)))
                        lines)
                   list-elements)))

(defmacro html->file (name &rest code)
  `(with-open-file (*standard-output* ,name
                                      :direction :output
                                      :if-exists :supersede
                                      :external-format :utf-8)
     (write-string
      (compile-html
       ,@code))))
