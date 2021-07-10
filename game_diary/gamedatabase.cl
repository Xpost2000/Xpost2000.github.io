
;; I don't feel like annoying them with repeated requests from curl
;; so I'm going to cache them.
;; TODO save to disk and reload
(defparameter *game-database* nil)

(defun game-database-clear ()
  (setf *game-database* (make-hash-table :test 'equal)))

(defun game-database-add-cached (cached)
  (setf (gethash (appid cached) *game-database*) cached))

(defun game-database-add-multiple-cached (&rest items)
  (loop for item in items do
    (game-database-add-cached item)))

(defun game-database-add (appid)
  (or (gethash appid *game-database*)
      (setf (gethash appid *game-database*)
            (steam-game-info-of appid))))

(defun game-database-cache-to-disk (cache-location)
  (with-open-file (*standard-output* cache-location
                                     :direction :output
                                     :if-exists :supersede
                                     :external-format :utf-8)
    (format nil ";; Please don't edit this file! You might break things if you do!")
    (loop for key being the hash-keys of *game-database*
          do (print (gethash key *game-database*)))))

(defun game-database-load-from-disk (cache-location)
  (ignore-errors (load cache-location)))

(defun game-database-add-comment-to (appid comment)
  (setf (jerry-comments (game-database-add appid))
        comment))

(defclass steam-game-info ()
  ((appid
    :accessor appid
    :initarg :appid)
   (name
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

(defun steam-game-info-cached (&key appid name thumbnail detailed-description description comments developers publishers release-date)
  (setf (gethash appid *game-database*)
        (make-instance 'steam-game-info
                       :appid appid
                       :name name
                       :detailed-description detailed-description
                       :description description
                       :comments comments
                       :thumbnail thumbnail
                       :developers developers
                       :publishers publishers
                       :release-date release-date)))

(defmethod print-object ((object steam-game-info) stream)
  (print `(steam-game-info-cached
           :appid ,(appid object)
           :name ,(name object)
           :thumbnail ,(thumbnail object)
           :detailed-description ,(detailed-description object)
           :description ,(description object)
           :comments (list ,@(jerry-comments object))
           :developers (list ,@(developers object))
           :publishers (list ,@(publishers object))
           :release-date ,(release-date object))))
