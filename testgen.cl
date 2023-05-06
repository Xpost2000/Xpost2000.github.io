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

    "I'm Jerry Zhu, and I'm a software developer with focus in game programming and specifically engine development! I enjoy working with and learning about various technologies."
    "My skills primarily lie in C and C++, where I develop custom game engines and games with various technologies such as OpenGL or completely from scratch."

    "Outside of programming engines and technology in C++ I am also a solo game developer, and a consistent participant in game jams whenever I have time in between studies. Since I find them a good way to exercise my creativity muscles."

    "As a quick view of my work here are some of my released games. For a more in-depth look at my projects please visit the projects page for not only more information about some of these projects, but also a look at my technical projects as well!"
    "
<iframe src=\"https://itch.io/embed/1105211?bg_color=31211a&amp;fg_color=ffffff&amp;link_color=5b80fa&amp;border_color=333333\" width=\"552\" height=\"167\" frameborder=\"0\"><a href=\"https://xpost2000.itch.io/fateless-challenge-minijam-83\">Fateless Challenge [minijam 83] by Xpost2000</a></iframe>
<iframe src=\"https://itch.io/embed/296634?bg_color=e7fecc&amp;fg_color=222222&amp;link_color=fa5c5c&amp;border_color=44a72e\" width=\"552\" height=\"167\" frameborder=\"0\"><a href=\"https://xpost2000.itch.io/killbot\">Killbot by Xpost2000</a></iframe>
<iframe src=\"https://itch.io/embed/615481?bg_color=000000&amp;fg_color=ffffff&amp;link_color=a16b00&amp;border_color=3f3f3f\" width=\"552\" height=\"167\" frameborder=\"0\"><a href=\"https://xpost2000.itch.io/treewatcher-ld46\">Treewatcher [For Ludum Dare 46 Compo] by Xpost2000</a></iframe>
<iframe src=\"https://itch.io/embed/952725?bg_color=000000&amp;fg_color=ffffff&amp;link_color=5bfa93&amp;border_color=384430\" width=\"552\" height=\"167\" frameborder=\"0\"><a href=\"https://xpost2000.itch.io/l4drl7drl\">L4DRL[7drl] by Xpost2000</a></iframe>
<iframe src=\"https://itch.io/embed/2004076\" width=\"552\" height=\"167\" frameborder=\"0\"><a href=\"https://xpost2000.itch.io/soul-walker\">Soul Walker by Xpost2000</a></iframe>
"

    "I also have an interest in using Lisp (which was used for statically generating this website!) I also have experience with frontend development through technologies such as React, MongoDB, Express, and Node.JS (MERN)."

    "You can use the modeline on the bottom of the page to navigate this website. This website also features a theme selector you can try out in through the modeline!"
    ))
(defparameter *display-list*
  '("C / C++ Game Programming and Engine Programming"
    "Frontend Web Development"
    "Contact me at: jerry.zhu@stonybrook.edu"))

(defparameter *quicklink-shortcuts*
  '(
    ;; ("./blog/index.html" "Personal Diary/Blog")
    ;; ("./projects/index.html" "Projects")
    ;; ("./game_diary/index.html" "Game Diary")
   ; ("./art_gallery/index.html" "Art Hobby (please wait!)")
    ))

(defun build () 
  (html->file
   "index.html"
   `(:html
     (,(generate-page-header 0 "Home - Jerry Zhu / Xpost2000" '((:link ((:type "text/css") (:rel "stylesheet") (:href "style.css")) "")))
      (:body
       ((:div ((:id "head-container"))
              ((:h1 ((:id "header-title-id")) "Xpost2000")
               (:h1 ((:id "sub-sub-header-title-id")) "Software Development, Game Programming, Game Engine Programming")
               (:h1 ((:id "sub-header-title-id")) "
Jerry Zhu
<br>
<a href=\"https://www.github.com/Xpost2000\">github</a> <a href=\"https://xpost2000.itch.io/\">itch.io</a> <a href=\"https://www.linkedin.com/in/jerry-zhu-220133215/\">linkedin</a> <a href=\"./resumes/Jerry_Zhu_Resume.pdf\">resume</a>
<br>
<a href=\"./projects/index.html\">projects</a> <a href=\"./blog/index.html\">personal blog</a> 
")
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
                                             ;; "./game_diary/index.html"
                                             "./projects/index.html"
                                            ; "./art_gallery/index.html"
                                             ;; NOTE(jerry): un-updated link
                                             ;; "./web-projects/index.html"
                                             ))
        ,(script-tag 0)))))))

(build)
