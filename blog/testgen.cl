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

;; This is a PLIST
;; but it should probably be a hash-table if possible.
(defparameter *blog-entries* '())

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

(defun blog-page-content (title date lines source-path)
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
           (:p
             ,(format nil "View the plaintext version <a href=\"../~a\">here</a>" source-path))))))

;; Assume a list of lines.
(defun date-of-blog-entry (blog-lines) (elt blog-lines 1))
(defun title-of-blog-entry (blog-lines) (elt blog-lines 0))

(defun generate-blog-page (path-to-source links link)
  (let* ((file-lines (getf *blog-entries* path-to-source))
         (title (title-of-blog-entry file-lines))
         (date-created (date-of-blog-entry file-lines)))
    (with-open-file (*standard-output* (format nil "pages/~a.html" (pathname-name path-to-source)) :direction :output :if-exists :supersede :external-format :utf-8)
      (write-string
       (compile-html
        `(:html
          (,(generate-page-header 2 (concatenate 'string title " - Jerry Zhu / Xpost2000"))
           (:body
            (,@(blog-page-content title date-created (subseq file-lines 2) path-to-source)
             (:div ((:id "ugly-ass-gutter")) "")
             ,(generate-modeline-and-minibuffer "blog-page" links link)
             ,(script-tag 2))))))))
    `(:title ,title
      :date-created ,date-created)))


(defun generate-pages-and-listings (links)
  (loop for link in links
         collect
         (let* ((current-link (getf link :current))
                (adjusted-pathname (concatenate 'string "pages/" (%adjusted-pathname% current-link)))
                (blog-page (generate-blog-page current-link links link)))
           (list
            :link link
            :tag `(:a ((:href ,adjusted-pathname)) (:p ,(getf blog-page :title)))))))

;;
;; This technically does a double pass for reading which is slower, however
;; this is way simpler to do.
;; I could rearchitect this to just read all the files in memory and then sort afterwards
;; however, that would be faster and probably simplify the code now that I think about it
;; however this is what I have on hand as a quickfix.
;;

(defun directory-files-sorted-by-blog-date (directory)
  (loop for item in
                 (let* ((listing-with-contents
                          (mapcar
                           (lambda (item)
                             (reverse (multiple-value-list
                                       (file-lines item))))	
                           (relative-directory-listing directory)))
                        (sorted-listing
                          (sort listing-with-contents
                                (lambda (a b)
                                  (let ((date-of-first (date-of-blog-entry (second a)))
                                        (date-of-second (date-of-blog-entry (second b))))
                                    (< (create-encoded-time-from-date-string date-of-first)
                                       (create-encoded-time-from-date-string date-of-second)))))))
                   (setf *blog-entries*
                         (reduce
                          (lambda (accumulator next-item)
                            (append accumulator
                                    (list (first next-item))
                                    (list (second next-item))))
                          sorted-listing
                          :initial-value '()))
                   sorted-listing)
        collect (first item)))

(defun sorted-list-of-blog-listing-links (blog-directory)
  (generate-pages-and-listings
   (page-links (directory-files-sorted-by-blog-date blog-directory))))

(defun build ()
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
          (,(generate-page-header 1 "Blog - Jerry Zhu / Xpost2000")
           (:body
            (
             ,@(page-content
                "Jerry's Blog"
                (list "Welcome to the blog"
                      ""
                      "Whenever this gets updated, there's going to be some new content here."
                      "This blog listing should be generated by a Common Lisp program in the repository,"
                      "I'm probably going to just talk about whatever I find interesting."
                      ""
                      "Feel free to use the modeline as an alternate form of navigation."
                      )
                '(:p (:b "Listing: "))
                '(:br)
                listing-tags)
             (:div ((:id "ugly-ass-gutter")) "")
             ,(generate-modeline-and-minibuffer "welcome-to-my-website" links)
             ,(script-tag))))))))))

(build)
