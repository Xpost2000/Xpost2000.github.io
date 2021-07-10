;; for common htmling stuff and the html "compiler"

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

;; lazy
(defun script-tag (&optional (depth 1) (name "scripts/site.js"))
  `(:script ((:src ,(format nil "~a~a" (repeat "../" depth) name)) (:type "text/javascript")) ""))

(defun generate-page-header (&optional (depth 1) (title "Jerry Zhu / Xpost2000") extra)
  (let ((backslashes (repeat "../" depth)))
    `(:head
      (,(script-tag depth "scripts/site_theming.js")
       ;; TODO load base and default.css here.
       ;; this should be the bare minimum to allow no javascript.
       ;; the modeline also needs to be changed very slightly to allow noscript.
       (:link ((:rel "stylesheet") (:href ,(format nil "~astyles/common/theme_selector.css" backslashes))) "")
       ,@extra
       (:link ((:rel "shortcut icon") (:href ,(format nil "~afavicon.ico" backslashes)) (:type "image/x-icon")) "")
       (:meta ((:http-equiv "content-type") (:content "text/html; charset=utf-8")) "")
       (:meta ((:name "viewport") (:content "width=device-width, initial-scale=1")) "")
       (:title ,title)))))

(defun generate-modeline-and-minibuffer (text link-name &optional links current-link)
  `(:div ((:class "modeline-holder"))
         ((:div ((:id "mini-buffer-autocompletion"))
                ((:p "Click on a link to be taken to the page!")
                 (:br)
                 ,(generate-mini-buffer links current-link)
                 (:br)))
          (:div ((:class "mode-bar"))
                ,(format nil "          <pre>U--- <b>~a&lt<a href=\"../index.html\" style=\"text-decoration:none\">xpost2000.github.io</a>&gt</b> All (0, 0) [NORMAL] (HTML+)</pre>" link-name))
          (:div ((:class "mini-buffer") (:id "mini-buffer-main"))
                ;; For whatever reason, the string constants cannot take multibyte characters
                ;; weird.
                ((:pre ,(format nil "~a<span class=\"blinking-cursor\">~a</span>" text (code-char 9608))))))))

;; dummy
(defun generate-modeline-and-minibuffer2 (text link-name &optional links)
  `(:div ((:class "modeline-holder"))
         ((:div ((:id "mini-buffer-autocompletion"))
                ((:p "Click on a link to be taken to the page!")
                 (:br)
                 ,(generate-mini-buffer2 links)
                 (:br)))
          (:div ((:class "mode-bar"))
                ,(format nil "          <pre>U--- <b>~a&lt<a href=\"../index.html\" style=\"text-decoration:none\">xpost2000.github.io</a>&gt</b> All (0, 0) [NORMAL] (HTML+)</pre>" link-name))
          (:div ((:class "mini-buffer") (:id "mini-buffer-main"))
                ;; For whatever reason, the string constants cannot take multibyte characters
                ;; weird.
                ((:pre ,(format nil "~a<span class=\"blinking-cursor\">~a</span>" text (code-char 9608))))))))



;; needs to be able to properly reconstruct from a full relative path.
;; so we need to adjust this.
(defun %adjusted-pathname% (pathname &optional from)
  (format nil "~a.html"
          ;; hope this is always relative.
          (pathname-name pathname)))
; this is a terrible name. Your parents must really hate you.
;; this is stupid as hell.
(defun list-element-from-link (link entry text)
  (if (getf link entry)
      `(:li (:a ((:href ,(getf link entry))) ,text))))

;; this is technically blog only.
(defun generate-mini-buffer (&optional links current-link)
  `(:ul ((:id "mini-buffer-links"))
        ((:li (:a ((:href "#")) "./."))
         (:li (:a ((:href "../index.html")) "./.."))
         ,@(if current-link
               `(,(list-element-from-link current-link :next "./next_entry")
                 ,(list-element-from-link current-link :previous "./previous_entry"))
               (loop for link in links
                     collect
                     (let ((adjusted-pathname (getf link :current)))
                       `(:li (:a ((:href ,adjusted-pathname)) ,adjusted-pathname))))))))

;; dummy
(defun generate-mini-buffer2 (&optional links)
  `(:ul ((:id "mini-buffer-links"))
        ((:li (:a ((:href "#")) "./."))
         (:li (:a ((:href "../index.html")) "./.."))
         ,@(loop for link in links
                 collect
                 `(:li (:a ((:href ,link)) ,link))))))
