#|
	Common Lisp page generator for Xpost2000.github.io

	This is copy and pasted from the other file with changes. Will make it use less
	files later, or never.
|#
(load "../generator/htmlify.cl")
(load "../generator/common.cl")
(load "../generator/project-card.cl")

;; converting the old format to the new one which is specified
;; as code.
;; This does technically allow me to specify new projects in the old format
;; but I don't really want to do that lol.
(defun directory-file-structure->lisp-file ()
  (let ((project-subdirectories
          (map 'list
               #'enough-namestring
               (uiop:subdirectories "projects/"))))
    (loop for directory in project-subdirectories
          collect
          (let ((lines (file-lines (concatenate 'string directory "/info.txt"))))
            (project :title (first lines)
                     :description (reduce (lambda (result line)
                                            (concatenate 'string result " " line))
                                          (subseq lines 3))
                     :thumbnail (concatenate 'string directory "/" (second lines)))))))

(defun generate-project-cards (projects)
  (map 'list
       (lambda (project)
           `(
            (:div ((:class "project-description"))
                  (
                   ,(if (project-link-location project)
                        `(:b (:a ((:href ,(project-link-location project)) (:class "project-title")) ,(project-title project)))
                      `(:b (:p ((:class "project-title")) ,(project-title project))))
                   (:div 
                    (
                     (:a ((:href ,(project-link-location project)))
                         (:img ((:class "project-thumb")
                                (:src ,(project-thumbnail-location project))) ""))
                     (:p ,(project-description project))))
                   (:br)
                   (:b (:p ,(concatenate 'string "Technologies Used: " (technologies project))))
                   (:b (:p ,(concatenate 'string "Date: " (duration project))))
                   (:b (:p ,(concatenate 'string "Status: " (status project))))
                   (:br)))))
       projects))

;; a meta program to meta program a website.
;; this is only wrapped in a progn to "scope"
(defun build-preamble ()
  (load "projects-list.cl"))

(defun build () 
  (build-preamble)
  (html->file
   "index.html"
   (with-common-page-template
     :current-link-text "projects.html"
     :page-title "Projects"
     :body
     `((:h1 "My Projects / Portfolio")
       (:br)
       (:p "On this page you can find a brief summary of my projects, in varying states of completion.")
       (:br)
       (:p "<b>NOTE: unless specified, all of these projects are solo projects!")
       (:br)
       (:p "This is primarily for my technical projects as opposed to my itch.io page which includes my complete public projects.")
       (:br)
       (:p
        ("You can find my itch.io here: "
         (:a ((:href "http://xpost2000.itch.io")) "itch.io")))
       (:br)
       (:p "Click on the titles or thumbnails for each card to be taken to a relevant page (either GitHub or itch.io) for a more comprehensive breakdown through a README.md for a write-up or a gameplay demo.")
       (:br)
       (:ul
        ((:id "project-listing"))
        ,(generate-project-cards *projects*))))))

(build)
