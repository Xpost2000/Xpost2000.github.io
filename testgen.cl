#|
	Common Lisp page generator for Xpost2000.github.io

	landing page... Cause why not?

	For the most part this is a literal transcription of the original version.

	This is an issue because this is the least patternized page, so I can't really generate
	this in a convenient way... Oh whatever.
|#
(load "generator/htmlify.cl")
(load "generator/common.cl")

(defparameter *info-text*
  '("I make no guarantees that this website will display properly. and if you're an old browser platform
     I'm likely not supporting it, sorry."
    "Hi, I kind of make video games and do random things in my spare time. I've been programming for some time,
     and I love playing video games. I have an interest in Lisp-like languages, and I do some Common Lisp and know a bit
     of Clojure (this site was generated with a Common Lisp program!)."
    "Although I'm most handy with C++, although predominately leaning on plain C these days. I do low-level programming primarily
     and web development if I'm ever asked to."
    "You can use the modeline on the bottom of the page to navigate this website. This is probably not ARIA compliant in any form,
     and is designed to be highly stylized. I apologize if this is a problem."))
(defparameter *display-list*
  '("Amateur Game Programming"
    "Student"
    "Other things"))

(defun build () 
  (html->file
   "index.html"
   `(:html
     (,(generate-page-header 0 "Home - Jerry Zhu / Xpost2000" '((:link ((:type "text/css") (:rel "stylesheet") (:href "style.css")) "")))
      (:body
       ((:div ((:id "head-container"))
              ((:h1 ((:id "header-title-id")) "Xpost2000")
               (:h1 ((:id "sub-header-title-id")) "Jerry Zhu")
               (:br)
               (:div ((:id "displays"))
                     ,(list (map 'list (lambda (s) `(:p ((:id "display")) (:b ,s))) *display-list*)))))
        (:div ((:id "info-container"))
              ((:div ((:id "info"))
                     ,@(list (map 'list (lambda (s) `((:p ,s) (:br))) *info-text*)))))
        (:div ((:id "ugly-ass-gutter")) "")
        ,(generate-modeline-and-minibuffer "welcome-to-my-website"
                                           "index.html"
                                           (list
                                            "test"
                                            ))
        ,(script-tag 0)))))))

(build)
