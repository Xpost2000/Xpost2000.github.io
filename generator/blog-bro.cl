#|
	Common Lisp page generator for Xpost2000.github.io

	this is used to help setup "blog-like" pages. Those that require

	previous / next entry functionality,
	page generation and a directory listing from text files, which are blog
	entries.

	For now all blogs are formatted as text files in the following format:

	Title
	M/D/YEAR HOUR:MINUTE AM/PM
	-- empty line to start entry
	{
          body here
        }

	Body is transcribed quite directly without any security, (so feel free to use
	HTML markup until I use an actual markup system.)

	Ideally this would work by simply doing

	(blog-bro-build (SOURCE-DIRECTORY "text/") (OUTPUT-DIRECTORY "pages/")) -> (BLOG ENTRIES)

	where (BLOG ENTRIES) ->
	(:TITLE
	 :DATE
	 :CONTENTS
	 :PREVIOUS
	 :NEXT)

	or something similar.
|#

;; Assume a list of lines.
(defun date-of-blog-entry (blog-lines) (elt blog-lines 1))
(defun title-of-blog-entry (blog-lines) (elt blog-lines 0))

(defun link-xform (original-link xformer)
  `(:current ,(funcall xformer (getf original-link :current))
    :previous ,(funcall xformer (getf original-link :previous))
    :next ,(funcall xformer (getf original-link :next))))

;; This is required because the link former isn't incredibly smart yet.
;; I don't need it to be super smart quite yet so I'm perfectly okay with special
;; casing these right now.

;; I would probably have to construct an actual blog builder as I need to maintain lots of
;; state to be intelligent
(defun -modeline-friendly-text-link->page-link (original-link)
  (link-xform original-link (lambda (original-link)
                              (when original-link
                                (format nil "~a.html" (pathname-name original-link))))))
(defun text-link->page-link (original-link)
  (link-xform original-link (lambda (original-link)
                              (when original-link
                                (format nil "pages/~a.html" (pathname-name original-link))))))

(defun generate-blog-page (out-directory entries path-to-source links link &key (depth 2))
  (let* ((file-lines (getf entries path-to-source))
         (title (title-of-blog-entry file-lines))
         (date-created (date-of-blog-entry file-lines)))
    (html->file
     (format nil "~a/~a.html" out-directory (pathname-name path-to-source))
     (with-common-page-template
       :depth depth
       :page-title title
       :body `((:h1 ,title)
               (:p ((:b "Date Published")
                    (:span ((:style "background-color: yellow; color: black;")) ,(format nil "(~a)" date-created))))
               ,@(map 'list
                      (lambda (x)
                        (if (empty-stringp x)
                            '(:br) (list :p x)))
                      (subseq file-lines 2))
               (:br)
               (:p ,(format nil "View the plaintext version <a href=\"../~a\">here</a>" path-to-source)))
       :current-link-text (concatenate 'string (remove-file-extension-from-string (getf link :current)) ".html") 
       :current-link link ; what does this do again?
       :modeline-text "blog-page"
       :modeline-links links))
    `(:title ,title :date-created ,date-created)))

(defun listing-with-contents (directory)
  (mapcar
   (lambda (item)
     (reverse (multiple-value-list (file-lines item))))	
   (relative-directory-listing directory)))

;; Do note this does more work than it says it does!
;; this is not usual for me to write! So whoops!
(defun list-of-blog-listing-links (blog-directory blog-entries)
  (generate-pages-and-listings
   blog-entries
   (page-links blog-entries)))

(defun install-blog (&key (text-directory "./text/") (out-directory "./pages/") (depth 2))
  (let* ((entries-with-names (listing-with-contents text-directory))
         (entries-with-names-plist
           (reduce
            (lambda (accumulator item)
              (append accumulator (list (first item)) (list (second item))))
            entries-with-names
            :initial-value '()))
         (links (page-links (loop for item in
                                           (sort entries-with-names
                                                 (sort-by-date-string
                                                  (lambda (x)
                                                    (date-of-blog-entry (second x)))))
                                  collect (first item)))))
    ;; generate-page-and-listings
    (loop for link in links
          collect
          (let* ((current-link (getf link :current))
                 (blog-page (generate-blog-page
                             out-directory
                             entries-with-names-plist
                             current-link ; original file
                             ;; or this otherwise.
                             links
                             ;; modeline links will be built from this
                             (-modeline-friendly-text-link->page-link link)
                             :depth depth)))
            (list :link link
                  :page blog-page)))))

;; this is a useful default for me anyways.
(defun generate-page-links (blog-listing-and-links)
    (loop for item in blog-listing-and-links
          collect
          (let* ((adjusted-path (text-link->page-link (getf item :link)))
                 (page (getf item :page))
                 (page-title (getf page :title)))
            `(:a ((:href ,(getf adjusted-path :current)))
                 (:p ,page-title)))))
