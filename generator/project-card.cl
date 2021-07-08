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
   (thumbnail-source
    :initarg :thumbnail
    :accessor project-thumbnail-location
    :initform (error "Please give me a thumbnail sirrah!"))))

(defmethod print-object ((object project) stream)
  (print `(project :title ,(project-title object)
                   :description ,(project-description object)
                   :thumbnail ,(project-thumbnail-location object))
         stream))
(defun project (&key title description thumbnail)
  (make-instance 'project
                 :title title
                 :description description
                 :thumbnail thumbnail))

(defparameter *projects* '())
(defun clear-projects ()
  (setf *projects* '()))
(defun add-projects (&rest projects)
  (dolist (project projects)
    (push project *projects*)))
