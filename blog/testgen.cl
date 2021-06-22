#|
	Common Lisp page generator for Xpost2000.github.io

	Makes the page generation less painful, mostly.

	This is reusable for generating other pages, although obviously don't
	use this for actual websites since this probably only works for my specific
	scenario. Please use something else, like Clojurescript which actually has good
	libraries to do this thing.

	It only really works with the requirements of this page, as this thing does not even try to pretty print
	correctly. Any attempts at using <PRE> may explode violently.

	I might try to do proper pretty printing later if I don't forget about this tomorrow.

	Basically use a hiccup like format, and common lisp acts as a convenient template engine. At least I don't need
	external html files. It's also easier to write than html itself...
|#
(load "htmlify.cl")

(defun page-content (title lines &rest list-elements)
  `((:div ((:class "body-container"))
          ((:h1 ,title)
           ,@(concatenate 'list
              (map 'list
               (lambda (x)
                 (if (empty-stringp x) 
                     '(:br) (list :p x)))
               lines)
              list-elements)))))

(defun blog-page-content (title date lines)
  `((:div ((:class "body-container"))
          ((:h1 ,title)
           (:p ((:b "Date Published")
                (:span ((:style "background-color: yellow; color: black;")) ,(format nil "(~a)" date))))
           (:br)
           ,@(map 'list
                (lambda (x)
                  (if (empty-stringp x)
                      '(:br) (list :p x)))
                lines)
           (:br)
           (:p "View the plantext version <a href=\"#\">here</a>")))))

(defun generate-blog-page (path-to-source links link)
  (let* ((file-lines (with-open-file (file-stream path-to-source)
                      (loop for line = (read-line file-stream nil nil)
                            while line collect line)))
         (title (elt file-lines 0))
         (date-created (elt file-lines 1)))
    (with-open-file (*standard-output* (format nil "pages/~a.html" (pathname-name path-to-source)) :direction :output :if-exists :supersede :external-format :utf-8)
      (write-string
       (compile-html
        `(:html
          (,(generate-page-header 2)
           (:body
            (,@(blog-page-content title date-created (subseq file-lines 2))
             (:div ((:id "ugly-ass-gutter")) "")
             ,(generate-modeline-and-minibuffer "blog-page" links link)
             ,(script-tag 2))))))))
    `(:title ,title
      :date-created ,date-created)))

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

(defun generate-pages-and-listings (links)
  (loop for link in links
         collect
         (let* ((current-link (getf link :current))
                (adjusted-pathname (concatenate 'string "pages/" (%adjusted-pathname% current-link)))
                (blog-page (generate-blog-page current-link links link)))
           (list
            :date (create-encoded-time-from-date-string (getf blog-page :date-created))
            :link link
            :tag `(:a ((:href ,adjusted-pathname)) (:p ,(getf blog-page :title)))))))

(defun sorted-list-of-blog-listing-links (blog-directory)
    (sort
     (generate-pages-and-listings
      (page-links (map 'list #'enough-namestring (uiop:directory-files blog-directory))))
     (lambda (a b)
       (< (getf a :date)
          (getf b :date)))))

(with-open-file (*standard-output* "index.html" :direction :output :if-exists :supersede :external-format :utf-8)
  (write-string
   (compile-html
    (let* ((blog-listing-and-links
             (sorted-list-of-blog-listing-links "./text/"))
           (listing-tags
             (loop for item in blog-listing-and-links collect (getf item :tag)))
           (links
             (loop for item in blog-listing-and-links collect (getf item :link))))
      `(:html
        (,(generate-page-header)
         (:body
          (
           ,@(page-content
              "Jerry's Blog"
              (list "Welcome to the blog"
                    ""
                    "Whenever this gets updated, there's going to be some new content here."
                    "This lbog listing should be generated by a Common Lisp program in the repository,"
                    "I'm probably going to just talk about whatever I find interesting."
                    ""
                    "Feel free to use the modeline as an alternate form of navigation."
                    )
              '(:p (:b "Listing: "))
              '(:br)
              listing-tags)
           (:div ((:id "ugly-ass-gutter")) "")
           ,(generate-modeline-and-minibuffer "welcome-to-my-website" links)
           ,(script-tag)))))))))
