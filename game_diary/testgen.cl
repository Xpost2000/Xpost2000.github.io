#|
	Common Lisp page generator for Xpost2000.github.io

	This is the game diary generator, which is extraordinarily similar to the
	code for the blog page. Since they are kind of the same thing. This is just a categorized
	blog page.	
|#
(load "../generator/htmlify.cl")
(load "../generator/common.cl")

;; I can't be arsed to write a json parser today
(load "external/json.asd")
(asdf:load-system 'JSON)

;; this was a devil to figure out how to do...
;; all of Valve's shit is underdocumented!

;; We're going to use curl cause that seems to be the only thing I have that can actually make the request...
;; UNIX mode engage!
(defun steam-app-info-request (id)
  (format nil "https://store.steampowered.com/api/appdetails?appids=~a" id))

(defclass steam-game-info ()
  ((name
    :accessor name
    :initarg :name)
   (detailed-description
    :accessor detailed-description
    :initarg :detailed-description
    :documentation "This is the extended description. I don't know what I'll do with this.")
   (short-description
    :accessor description
    :initarg :description)
   (thumbnail
    :accessor thumbnail
    :initarg :thumbnail)
   (developers
    :accessor developers
    :initarg :developers)
   (publishers
    :accessor publishers
    :initarg :publishers)
   (release-date
    :accessor release-date
    :initarg :release-date)))

(defmethod print-object ((object steam-game-info) stream)
  (print-unreadable-object (object stream :type 'steam-game-info)
    (princ (name object) stream)
    (princ (format nil " DEVELOPERS: ~a " (developers object)) stream)
    (princ (format nil " PUBLISHERS: ~a " (publishers object)) stream)))

(defun _json-getf-nested (object places-list)
  (if places-list
      (_json-getf-nested (json:json-getf object (car places-list))
       (cdr places-list)) 
      object))

(defun json-getf-nested (object places-string)
  (_json-getf-nested object (uiop:split-string places-string :separator '(#\.))))

(defun curl-request->json-data (id)
  (json:json-decode
   (with-output-to-string (stringstream)
     (uiop:run-program (list "curl" (steam-app-info-request id)) :output stringstream))))

(defun make-curl-request-game (id)
  (_json-getf-nested (curl-request->json-data id) (list (format nil "~a" id) "data")))

(defun steam-game-info-of (appid)
  (let ((data (make-curl-request-game appid)))
    (labels (($ (s) (json-getf-nested data s)))
      (make-instance 'steam-game-info
                     :name ($ "name")
                     :description ($ "short_description")
                     :detailed-description ($ "detailed_description")
                     :thumbnail ($ "header_image")
                     :developers ($ "developers")
                     :publishers ($ "publishers")
                     :release-date ($ "release_date.date")))))

;; I don't feel like annoying them with repeated requests from curl
;; so I'm going to cache them.
;; TODO save to disk and reload
(defparameter *game-database* nil)
(defun game-database-clear ()
  (setf *game-database* (make-hash-table :test 'equal)))

(defun game-database-add (appid)
  (or (gethash appid *game-database*)
      (setf (gethash appid *game-database*)
            (steam-game-info-of appid))))
(game-database-clear)

;; make game cards based off my directory.

(defparameter *blog-entries* '())

;; Assume a list of lines.
(defun date-of-blog-entry (blog-lines) (elt blog-lines 1))
(defun title-of-blog-entry (blog-lines) (elt blog-lines 0))

(defun generate-blog-page (path-to-source links link)
  (let* ((file-lines (getf *blog-entries* path-to-source))
         (title (title-of-blog-entry file-lines))
         (date-created (date-of-blog-entry file-lines)))
    (html->file
     (format nil "pages/~a.html" (pathname-name path-to-source))
     (with-common-page-template
       :depth 2
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
       :current-link link
       :modeline-text "blog-page"
       :modeline-links links))
    `(:title ,title :date-created ,date-created)))


(defun generate-pages-and-listings (links)
  (loop for link in links
         collect
         (let* ((current-link (getf link :current))
                (adjusted-pathname (concatenate 'string "pages/" (%adjusted-pathname% current-link)))
                (blog-page (generate-blog-page current-link links link)))
           (list
            :link link
            :tag `(:a ((:href ,adjusted-pathname)) (:p ,(getf blog-page :title)))))))

(defun directory-files-sorted-by-blog-date (directory)
  (loop for item in
                 (let* ((listing-with-contents
                          (mapcar
                           (lambda (item)
                             (reverse (multiple-value-list (file-lines item))))	
                           (relative-directory-listing directory)))
                        (sorted-listing
                          (sort listing-with-contents
                                (sort-by-date-string (lambda (x) (date-of-blog-entry (second x)))))))
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

(defun game-directory&id-mappings (directory)
  (loop for sub-directory in (map 'list #'enough-namestring (uiop:subdirectories directory))
        collect
        `(:id ,(parse-integer (subseq (subseq sub-directory 0 ; Frankly this is unsafe,
                                            (1- (length sub-directory))) ; but thankfully it's well defined to have invalid subsequences apparently.
                                    (1+ (position #\/ sub-directory ; I can fix this later though I guess.
                                                  :from-end t
                                                  :end (1- (length sub-directory))))))
          :directory ,sub-directory)))

;; build game database
(loop for mapping in (game-directory&id-mappings "games/") do
  (game-database-add (getf mapping :id)))

(loop for key being the hash-keys of *game-database* do
  (print (game-database-add key))
  (print key))

(defun build ()
  (game-database-clear)
  (html->file
   "index.html"
   (let* (;; (blog-listing-and-links
          ;;   (sorted-list-of-blog-listing-links "./text/"))
          (dum 0)
          ;; (listing-tags
          ;;   (loop for item in blog-listing-and-links collect (getf item :tag)))
          ;; (links
          ;;   (loop for item in blog-listing-and-links collect (getf item :link)))
          )
     (with-common-page-template
       :page-title "Game Diary"
       :current-link-text "index.html"
       ;; :modeline-links links
       :body
       `(,@(page-content
            "Jerry's Game Diary"
            (list "Welcome to the Game Diary"
                  ""
                  "Remember when I said I love playing video games?"
                  "This is a secondary blog that is categorized by games I've played. Some I've finished"
                  "and simply replaying them again. Or some are completely fresh that I'm playing fresh."
                  "This is kind of going to be like those old school RPG game journal things, but with just random"
                  "games, since I recording let's plays is hard, and this is much more easier."
                  ""
                  "Since I will write down whatever happens. It is likely I will start the diary with games in the middle of playthroughs"
                  "because for obvious reasons I'm not going to replay the game just to get a more honest overview."
                  )
            '(:p (:b "Listing: "))
            #|
            	Considering all I use the API key for is, is simply to just query basic game information
		since scraping Steam is difficult (and probably not allowed anyhow...)
            
		I'm not extremely concerned with losing it since there's very little harm it can do, considering
		how easy it is to obtain one.
            |#
            '(:script ((:src "page.js")) "")
            '(:br)
            ;; listing-tags
            ))))))
(build)
