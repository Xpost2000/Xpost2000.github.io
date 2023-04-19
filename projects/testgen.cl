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
         `(:li
           (
            ,(if (project-link-location project)
`(:a ((:href ,(project-link-location project)) (:class "project-title")) ,(project-title project))
`(:p ((:class "project-title")) ,(project-title project)))

            (:div ((:class "project-description"))
             ((:img ((:class "project-thumb")
                     (:src ,(project-thumbnail-location project))) "")
              (:p ,(project-description project)))))))
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
     `((:h1 "My Projects")
       (:br)
       (:p "Here is a card listing of my projects whether they be games or general software, they are summarized briefly on this page with a thumbnail.<br>Feel free to click on the card titles to learn more!")
       (:p "Do note that this is not a comprehensive or complete list! A more accurate listing can be found just by sifting through my GitHub, as I update this website periodically!")
       (:br)
       (:ul
        ((:id "project-listing"))
        ,(generate-project-cards *projects*))))))

(build)
