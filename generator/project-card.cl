;; The only reason this is in a file is because
;; it just so happens that the game diary listing
;; does require this, because the game info cards
;; are listed in a similar manner.

;; Addendum: actually due to unusual circumstances for the game journal,
;; this isn't super possible for me to do lol

;; oh well. I'll move this back later. If I don't forget.

;; whatever this is way faster to do lol
(defclass project ()
  ((title
    :initarg :title
    :accessor project-title
    :initform (error "Please give me a title sirrah!"))
   (description
    :initarg :description
    :accessor project-description
    :initform (error "Please give me a description sirrah!"))
   (short-description
    :initarg :short-description
    :accessor short-project-description
    :initform "")
   (technologies
    :initarg :technologies
    :accessor technologies
    :initform (error "Please give me a list of technologies used sirrah!"))
   (media
    :initarg :media
    :accessor media
    :initform (error "Please give me a list of media used sirrah!"))
   (yt-embeds
    :initarg :yt-embeds
    :accessor yt-embeds
    :initform '())
   (duration
    :initarg :duration
    :accessor duration
    :initform (error "Please give me a duration used sirrah!"))
   (status
    :initarg :status
    :accessor status
    :initform (error "Please give me a status sirrah!"))
   (thumbnail-source
    :initarg :thumbnail
    :accessor project-thumbnail-location
    :initform (error "Please give me a thumbnail sirrah!"))
   (code-samples
    :initarg :code-samples
    :accessor code-samples
    :initform '())
   (link-source
    :initarg :link
    :accessor project-link-location
    :initform "#")))

(defmethod print-object ((object project) stream)
  (print `(project :title ,(project-title object)
                   :description ,(project-description object)
                   :thumbnail ,(project-thumbnail-location object))
         stream))
(defun project (&key title description short-description thumbnail link technologies duration status media code-samples yt-embeds)
  (make-instance 'project
                 :title title
                 :description description
                 :short-description short-description
                 :duration duration
                 :technologies technologies
                 :status status
                 :media media
                 :yt-embeds yt-embeds
                 :code-samples code-samples
                 :thumbnail thumbnail
                 :link link))

(defparameter *projects* '())
(defun clear-projects ()
  (setf *projects* '()))

(defun find-project (name)
  (find-if
   #'(lambda (obj)
       (string= (project-title obj) name))
   *projects*))

(defun add-projects (&rest projects)
  (dolist (project projects)
    (push project *projects*)))

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
                       ;; ,@(when (yt-embeds project)
                       ;;     `((:b (:p "Videos"))
                       ;;       ,(yt-embeds project)))
                    (:p ,(project-description project))))
                  (:br)
                  (:b (:p ,(concatenate 'string "Technologies Used: " (technologies project))))
                  (:b (:p ,(concatenate 'string "Date: " (duration project))))
                  ;; (:b (:p ,(concatenate 'string "Status: " (status project))))
                  (:br)))))
       projects))

(defun safe-subseq (l a b)
  (let ((max-b (min b (length l))))
    (subseq l a max-b)))

(defun frontpage-generate-project-cards (projects)
  (map 'list
       (lambda (project)
         `(
           (:div ((:class "fp-project-description") (:id ,(project-title project)))
                 (
                  ,(if (project-link-location project)
                       `(:b (:a ((:href ,(project-link-location project)) (:class "project-title")) ,(project-title project)))
                     `(:b (:p ((:class "project-title")) ,(project-title project))))
                  (:div 
                   ,(list
                     `(
                       (:a ((:href ,(project-link-location project)))
                           ,(safe-subseq
                             `((:img ((:class "project-thumb")
                                      (:src ,(concatenate 'string "projects/" (project-thumbnail-location project)))) "")
                               ,@(map
                                  'list
                                  (lambda (s)
                                    `(:a ((:href ,(project-link-location project)))
                                         (:img ((:class "project-thumb")
                                                (:src ,(concatenate 'string "projects/" s))) ""))
                                    )
                                  (media project)
                                  ))
                             0 4)  ;; this is the max amount I found that actually fit on the page
                           )
                       ;; ,(when (media project) `(:b (:p "Screenshots / Media")))
                       ;; ,@(when (yt-embeds project)
                       ;;     `((:b (:p "Videos"))
                       ;;       ,(yt-embeds project)))
                       (:p ((:class "float-right")) ,(project-description project))
                       )
                     ))
                  (:br)

	          ;; ,@(if (code-samples project)
                  ;;     `((:b (:p "Select Code Samples: "))
                  ;;       (:ul
                  ;;        ,(map
                  ;;         'list
                  ;;         (lambda (sample)
                  ;;           `(:li (:a ((:href ,(second sample))) ,(first sample)))
                  ;;           )
                  ;;         (code-samples project)
                  ;;         ))))

                  (:b (:p ,(concatenate 'string "Technologies Used: " (technologies project))))
                  (:b (:p ,(concatenate 'string "Date: " (duration project))))
                  ;; (:b (:p ,(concatenate 'string "Status: " (status project))))
                  (:br)))))
       projects))

;; (defun frontpage-generate-project-cards (projects)
;;   (map 'list
;;        (lambda (project)
;;          `(
;;            (:div ((:class "fp-project-description") (:id ,(project-title project)))
;;                  (
;;                   ,(if (project-link-location project)
;;                        `(:b (:a ((:href ,(project-link-location project)) (:class "project-title")) ,(project-title project)))
;;                      `(:b (:p ((:class "project-title")) ,(project-title project))))
;;                   (:div 
;;                    ,(list
;;                      `(
;;                        (:a ((:href ,(project-link-location project)))
;;                            (:img ((:class "project-thumb")
;;                                   (:src ,(concatenate 'string "projects/" (project-thumbnail-location project)))) ""))
;;                        (:p ,(short-project-description project)))
;;                      ))
;;                   (:br)
;;                   (:br)))))
;;        projects))

