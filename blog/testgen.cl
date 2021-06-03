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

(defun generate-page-list (page-entries)
  `(:ul
    ,(loop for item in page-entries collect
           `(:li ,item))))

(defun html-keyword-to-string (element-keyword)
  (symbol-name element-keyword))

;; I do not know of a standard way to iterate through a plist which is what I originally
;; wanted to do. I know I could just skip by cddr while iterating... But I'll just make it an easier format
(defun compile-attributes (attributes)
  (with-output-to-string (stream)
    (loop for attribute-pair in attributes do
      (let ((attribute (first attribute-pair))
            (value (second attribute-pair)))
          (if (or (= (length attribute-pair) 1)
                  (not (listp attribute-pair)))
              (format stream "~a " (string-downcase (symbol-name attribute)))
              (format stream "~a = ~w "
                      (string-downcase (symbol-name attribute))
                      value))))))

;; I should probably make this also generate html text instead
;; of having this weird 50/50 thing...
(defun generate-tag-string (tag-name inner-content &key attributes)
  (with-output-to-string (stream)
    (if attributes
        (format stream "<~a ~a>~%" tag-name (compile-attributes attributes))
        (format stream "<~a>~%" tag-name))
    (format stream inner-content)
    (format stream "</~a>~%" tag-name)))

(defun compile-html (root)
  (with-output-to-string (stream)
    (cond
      ((atom root) (and root (format stream "~a" root)))
      ((listp root)
       (if (symbolp (first root))
           (let* ((element-name (first root)))
             (case (length root)
               (1 (format stream "<~a/>~%" (html-keyword-to-string element-name)))
               (2 (let ((children (second root)))
                    (format stream "~a~%" (generate-tag-string (html-keyword-to-string element-name)
                                                             (compile-html children)))))
               (3 (let ((attributes (second root))
                        (children (third root)))
                    (format stream "~a~%" (generate-tag-string (html-keyword-to-string element-name)
                                                             (compile-html children)
                                                             :attributes attributes))))))
           (loop for child-item in root do
             (format stream "~a~%" (compile-html child-item))))))))

;; Avoid <PRE> this generator will crap itself since that requires real pretty printing...
(defun page-content (title lines &rest list-elements)
  `((:div ((:class "body-container"))
          ((:h1 ,title)
           ,@(concatenate 'list
              (map 'list
               (lambda (x)
                 (if (string= x "")
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
                  (if (string= x "")
                      '(:br) (list :p x)))
                lines)
           (:br)
           (:p "View the plantext version <a href=\"#\">here</a>")))))

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

; this is a terrible name. Your parents must really hate you.
(defun %adjusted-pathname% (pathname)
  (format nil "~a.html" (pathname-name pathname)))

(defun list-element-from-link (link entry text)
  (if (getf link entry)
      `(:li (:a ((:href ,(%adjusted-pathname% (getf link entry)))) ,text))))

(defun generate-mini-buffer (links &optional current-link)
  `(:ul ((:id "mini-buffer-links"))
        ((:li (:a ((:href "#")) "./."))
         (:li (:a ((:href "../index.html")) "./.."))
         ,@(if current-link
               `(,(list-element-from-link current-link :next "./next_entry")
                 ,(list-element-from-link current-link :previous "./previous_entry"))
               (loop for link in links
                     collect
                     (let ((adjusted-pathname (concatenate 'string "pages/" (%adjusted-pathname% (getf link :current)))))
                       `(:li (:a ((:href ,adjusted-pathname)) ,adjusted-pathname))))))))

(defun generate-modeline-and-minibuffer (text links &optional current-link)
  `(:div ((:class "modeline-holder"))
         ((:div ((:id "mini-buffer-autocompletion"))
                ((:p "Click on a link to be taken to the page!")
                 (:br)
                 ,(generate-mini-buffer links current-link)
                 (:br)))
          (:div ((:class "mode-bar"))
                "          <pre>U--- <b>index.html&lt<a href=\"../index.html\" style=\"text-decoration:none\">xpost2000.github.io</a>&gt</b> All (0, 0) [NORMAL] (HTML+)</pre>"
                )
          (:div ((:class "mini-buffer") (:id "mini-buffer-main"))
                ((:pre ,(format nil "~a<span class=\"blinking-cursor\">█</span>" text)))))))

(defun generate-page (path-to-source links link)
  (let* ((file-lines (with-open-file (file-stream path-to-source)
                      (loop for line = (read-line file-stream nil nil)
                            while line collect line)))
         (title (elt file-lines 0))
         (date-created (elt file-lines 1)))
    (with-open-file (*standard-output* (format nil "pages/~a.html" (pathname-name path-to-source)) :direction :output :if-exists :supersede :external-format :utf-8)
      (write-string
       (compile-html
        `(:html
          ((:head
            ((:style "@font-face { font-family: GNUUnifont; src: url('../../shared-resources/unifont-13.0.04.ttf'); }")
             (:link ((:rel "stylesheet") (:href "../../styles/common/theme_selector.css")) "")
             (:link ((:rel "shortcut icon") (:href "../../favicon.ico") (:type "image/x-icon")) "")
             (:meta ((:http-equiv "content-type") (:content "text/html; charset=utf-8")) "")
             (:meta ((:name "viewport") (:content "width=device-width, initial-scale=1")) "")
             (:title "Jerry Zhu")))
           (:body
            (,@(blog-page-content title date-created (subseq file-lines 2))
             (:div ((:id "ugly-ass-gutter")) "")
             ,(generate-modeline-and-minibuffer "blog-page" links link)
             (:script ((:src "../../scripts/site.js") (:type "text/javascript")) ""))))))))
    `(:title ,title :date-created ,date-created)))

(defun generate-pages-and-listings (links)
  (loop for link in links
         collect
         (let* ((current-link (getf link :current))
                (adjusted-pathname (concatenate 'string "pages/" (%adjusted-pathname% current-link)))
                (blog-page (generate-page current-link links link)))
           `(:a ((:href ,adjusted-pathname)) (:p ,(getf blog-page :title))))))

(defun file-compare-by-write-date (a b)
  (< (file-write-date a) (file-write-date b)))

(with-open-file (*standard-output* "test-index.html" :direction :output :if-exists :supersede :external-format :utf-8)
  (write-string
   (compile-html
    (let ((links (page-links (map 'list #'enough-namestring (sort (uiop:directory-files "./text/") #'file-compare-by-write-date)))))
      `(:html
        ((:head
          ((:style "@font-face { font-family: GNUUnifont; src: url('../shared-resources/unifont-13.0.04.ttf'); }")
           (:link ((:rel "stylesheet") (:href "../styles/common/theme_selector.css")) "")
           (:link ((:rel "shortcut icon") (:href "../favicon.ico") (:type "image/x-icon")) "")
           (:meta ((:http-equiv "content-type") (:content "text/html; charset=utf-8")) "")
           (:meta ((:name "viewport") (:content "width=device-width, initial-scale=1")) "")
           (:title "Jerry Zhu")))
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
              (generate-pages-and-listings links))
           (:div ((:id "ugly-ass-gutter")) "")
           ,(generate-modeline-and-minibuffer "welcome-to-my-website" links)
           (:script ((:src "../scripts/site.js") (:type "text/javascript")) "")))))))))
