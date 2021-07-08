#|
	Common Lisp page generator for Xpost2000.github.io

	This is the game diary generator, which is extraordinarily similar to the
	code for the blog page. Since they are kind of the same thing. This is just a categorized
	blog page.	
|#
(load "../generator/htmlify.cl")
(load "../generator/common.cl")

(load "../generator/blog-bro.cl")
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
   (jerry-comments
    :accessor jerry-comments
    :initarg :comments)
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

(defun game-database-add-comment-to (appid comment)
  (setf (jerry-comments (game-database-add appid))
        comment))

(defun get-game-directories (&optional (root-where "./."))
  (remove-if-not
   (lambda (item)
     (search "game_" item))
   (map 'list #'enough-namestring (uiop:subdirectories root-where))))

(defun extract-id-from-game-directory (directory-string)
  (handler-case (parse-integer
                 (subseq directory-string
                         (+ (length "game_")
                            (search "game_" directory-string))
                         (1- (length directory-string))))
    ;; This is SBCL specific I suppose.
    (sb-int:simple-parse-error nil)))

(defun game-directory&id-mappings (directory)
  (loop for sub-directory in (get-game-directories directory) collect
        `(:id ,(extract-id-from-game-directory sub-directory)
          :directory ,sub-directory)))

(defun generate-game-cards ()
  `(:div
    ((:id "game-listing"))
    ,(loop for key being the hash-keys of *game-database*
          collect
          (let ((game (game-database-add key)))
            `(:div  ((:class "game-card"))
               ((:p ((:class "game-title")) ,(name game))
                (:div ((:class "game-description"))
                      ((:a ((:href ,(format nil "game_~a/index.html" key)))
                           ((:img ((:class "game-thumb")
                                   (:src ,(thumbnail game))) "")))
                       (:div ((:class "game-development-information"))
                             ((:h2 "Release Date:")
                              (:p ,(release-date game))
                              (:h2 "Developed By: ")
                              (:p ,(reduce (lambda (accumulator string)
                                             (concatenate 'string accumulator " " string))
                                           (developers game)))
                              (:h2 "Published By: ")
                              (:p ,(reduce (lambda (accumulator string)
                                             (concatenate 'string accumulator " " string))
                                           (publishers game)))))
                       (:p ,(description game))))))))))

;; TODO(jerry): may have to special case certain entries.
;; or change the way the page is formatted!
(defparameter *no-comments*
  '("I have either not played this yet, or I have no comments yet.
     Stay tuned though if you want!"
    ""))
(defun generate-game-page (directory id)
  (let* ((comments (file-lines (concatenate 'string directory "comment.txt")))
         (blog-listing-and-links (install-blog
                                  :depth 3
                                  :text-directory (format nil "~a/text/" directory)
                                  :out-directory (format nil "~a/pages/" directory)))
         (listing-tags (generate-page-links blog-listing-and-links))
         (links (map 'list #'text-link->page-link
                     (loop for item in blog-listing-and-links collect (getf item :link)))))
    (game-database-add-comment-to id comments)
    (html->file
     (format nil "~a/index.html" directory)
     (with-common-page-template
       :depth 2
       :page-title (name (game-database-add id))
       :modeline-links links
       :body `(
               (,@(page-content
                   (name (game-database-add id))
                   (or comments *no-comments*)
                   '(:p (:b "Listing: "))
                   '(:br)
                   listing-tags)))
       :modeline-text "game-dungeon"))))

(defun generate-pages-for (mapping)
  (let* ((id (getf mapping :id))
         (directory (getf mapping :directory)))
	(generate-game-page directory id)))

(defun mappings->links (mappings)
  (map 'list
       (lambda (item)
         `(:current ,(concatenate 'string (getf item :directory) "index.html")))
       mappings))

(defun build ()
  (loop for mapping in (game-directory&id-mappings "./.") do
    (game-database-add (getf mapping :id))
    (generate-pages-for mapping))

  (html->file
   "index.html"
   (with-common-page-template
     :page-title "Game Diary"
     :current-link-text "index.html"
     :modeline-links (mappings->links (game-directory&id-mappings "./."))
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
                ""
                "Click on any of the games to be taken to their respective diary pages if they exist!"
                "NOTE: these are obviously going to be lots of reading, so try to not read multiple of them. I may not be able to write"
                "fanfictions, but this is as close as I can get."
                ""
                )
          '(:p (:b "Listing: "))
          (generate-game-cards)
          '(:script ((:src "page.js")) "")
          '(:br))))))
(game-database-clear)
(build)
