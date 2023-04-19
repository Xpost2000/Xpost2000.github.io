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
  '("Hello, and welcome to my personal/portfolio website!"
    "I'm Jerry Zhu, and I'm an aspiring software developer with focus in game programming! I enjoy working with various technologies, building projects, and generally being a tinkerer."
    "My skills primarily lie in C and C++, where I develop 2D game engines with OpenGL. I also have an interest in using Lisp (which was used for statically generating this website!) I also have
experience with frontend development, and Java."
    "On this site you can find a personal diary/blog, a game diary (which I should update with some of the stuff I've been touching), and a projects page."
    "You can use the modeline on the bottom of the page to navigate this website. This is probably not ARIA compliant in any form,
     and is designed to be highly stylized. I apologize if this is a problem."
    "Also, feel free to use the theme selector which is also used through the modeline!"
    "In the event the modeline is for some reason inaccessible you can use the quicklinks here."
    ))
(defparameter *display-list*
  '("C / C++ Game Programming"
    "Frontend Web Development"
    "Contact Me At: jerry.zhu@stonybrook.edu"))

(defparameter *quicklink-shortcuts*
  '(
    ("./blog/index.html" "Personal Diary/Blog")
    ("./projects/index.html" "Projects")
    ("./game_diary/index.html" "Game Diary")
    ("./art_gallery/index.html" "Art Hobby (please wait!)")
    ))

(defun build () 
  (html->file
   "index.html"
   `(:html
     (,(generate-page-header 0 "Home - Jerry Zhu / Xpost2000" '((:link ((:type "text/css") (:rel "stylesheet") (:href "style.css")) "")))
      (:body
       ((:div ((:id "head-container"))
              ((:h1 ((:id "header-title-id")) "Xpost2000")
               (:h1 ((:id "sub-sub-header-title-id")) "Interested in breaking into software development and/or game programmer roles.")
               (:h1 ((:id "sub-header-title-id")) "Jerry Zhu<br><a href=\"https://www.github.com/Xpost2000\">github</a> <a href=\"https://xpost2000.itch.io/\">itch.io</a> <a href=\"https://www.linkedin.com/in/jerry-zhu-220133215/\">linkedin</a> <a href=\"./resumes/Jerry_Zhu_Resume.pdf\">resume</a>")
               (:br)
               (:div ((:id "displays"))
                     ,(list (map 'list (lambda (s) `(:p ((:id "display")) (:b ,s))) *display-list*)))))
        (:div ((:id "info-container"))
              ((:div ((:id "info"))
                     ,@(list (map 'list (lambda (s) `((:p ,s) (:br))) *info-text*)))))
        (:div ((:id "quicklink-container"))
              ((:div ((:id "info"))
                     ,@(list (map 'list
                                  (lambda (s)
                                    `((:a ((:href ,(first s))) ,(second s)) (:br)))
                                  *quicklink-shortcuts*)))))
        (:div ((:id "ugly-ass-gutter")) "")
        ,(generate-modeline-and-minibuffer2 "welcome-to-my-website"
                                           "index.html"
                                           ;; TODO(jerry): make this not automatically append .html
                                           ;; too lazy to do it today.
                                            (list
                                             "./blog/index.html"
                                             "./game_diary/index.html"
                                             "./projects/index.html"
                                             "./art_gallery/index.html"
                                             ;; NOTE(jerry): un-updated link
                                             ;; "./web-projects/index.html"
                                             ))
        ,(script-tag 0)))))))

(build)
