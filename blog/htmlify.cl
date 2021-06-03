;; for common htmling stuff and the html "compiler"

;; I do not know of a standard way to iterate through a plist which is what I originally
;; wanted to do. I know I could just skip by cddr while iterating... But I'll just make it an easier format
(load "common.cl")

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

(defun html-keyword-to-string (element-keyword)
  (symbol-name element-keyword))

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

(defun %adjusted-pathname% (pathname)
  (format nil "~a.html" (pathname-name pathname)))

(defun script-tag (&optional (depth 1))
  `(:script ((:src ,(format nil "~ascripts/site.js" (repeat "../" depth))) (:type "text/javascript")) ""))

(defun generate-page-header (&optional (depth 1))
  (let ((backslashes (repeat "../" depth)))
    `(:head
      ((:style ,(format nil "@font-face { font-family: GNUUnifont; src: url('~ashared-resources/unifont-13.0.04.ttf'); }" backslashes))
       (:link ((:rel "stylesheet") (:href ,(format nil "~astyles/common/theme_selector.css" backslashes))) "")
       (:link ((:rel "shortcut icon") (:href ,(format nil "~afavicon.ico" backslashes)) (:type "image/x-icon")) "")
       (:meta ((:http-equiv "content-type") (:content "text/html; charset=utf-8")) "")
       (:meta ((:name "viewport") (:content "width=device-width, initial-scale=1")) "")
       (:title "Jerry Zhu")))))

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

; this is a terrible name. Your parents must really hate you.
(defun list-element-from-link (link entry text)
  (if (getf link entry)
      `(:li (:a ((:href ,(%adjusted-pathname% (getf link entry)))) ,text))))

;; this is technically blog only.
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
