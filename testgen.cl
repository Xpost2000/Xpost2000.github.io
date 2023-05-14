#|
	Common Lisp page generator for Xpost2000.github.io

	landing page... Cause why not?

	For the most part this is a literal transcription of the original version.

	This is an issue because this is the least patternized page, so I can't really generate
	this in a convenient way... Oh whatever.
|#
(load "generator/htmlify.cl")
(load "generator/common.cl")
(load "generator/project-card.cl")
(load "projects/projects-list.cl")

(defparameter *info-text*
  '("Hello, and welcome to my personal/portfolio website!"

    "I'm Jerry Zhu, and I'm a software developer with focus in game programming and specifically engine development! I have been programming games since middle school, I enjoy working with and learning about various technologies."
    "My skills primarily lie in C and C++, where I develop games with custom engines/technology completely from scratch with C++/C. Personally I love programming when I can fully understand my entire program and have as much control as possible over my creation."
    ""
    "Here are my highlighted projects for you to have an idea of what I typically work on. You can explore the project listing in the 'projects' page for a more comprehensive listing of my works, hacks, or experiments."
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

(defparameter *curated-highlights*
  (list
   (find-project "Legends RPG")
   (find-project "CrankLang - Programming Language")
   (find-project "ASCENSION")
   (find-project "2D Games Framework")
   (find-project "L4DRL - 7 Day Roguelike")))

(defparameter *itch-io-releases*
  (list
   "<iframe src=\"https://itch.io/embed/1105211?bg_color=31211a&amp;fg_color=ffffff&amp;link_color=5b80fa&amp;border_color=333333\" width=\"552\" height=\"167\" frameborder=\"0\"><a href=\"https://xpost2000.itch.io/fateless-challenge-minijam-83\">Fateless Challenge [minijam 83] by Xpost2000</a></iframe> <br>"
   "<iframe src=\"https://itch.io/embed/296634?bg_color=e7fecc&amp;fg_color=222222&amp;link_color=fa5c5c&amp;border_color=44a72e\" width=\"552\" height=\"167\" frameborder=\"0\"><a href=\"https://xpost2000.itch.io/killbot\">Killbot by Xpost2000</a></iframe> <br>"
   "<iframe src=\"https://itch.io/embed/615481?bg_color=000000&amp;fg_color=ffffff&amp;link_color=a16b00&amp;border_color=3f3f3f\" width=\"552\" height=\"167\" frameborder=\"0\"><a href=\"https://xpost2000.itch.io/treewatcher-ld46\">Treewatcher [For Ludum Dare 46 Compo] by Xpost2000</a></iframe> <br>"
   "<iframe src=\"https://itch.io/embed/952725?bg_color=000000&amp;fg_color=ffffff&amp;link_color=5bfa93&amp;border_color=384430\" width=\"552\" height=\"167\" frameborder=\"0\"><a href=\"https://xpost2000.itch.io/l4drl7drl\">L4DRL[7drl] by Xpost2000</a></iframe> <br>"
   "<iframe src=\"https://itch.io/embed/2004076\" width=\"552\" height=\"167\" frameborder=\"0\"><a href=\"https://xpost2000.itch.io/soul-walker\">Soul Walker by Xpost2000</a></iframe>"
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
<a href=\"./projects/index.html\">projects</a>
")
               (:br)
               (:div ((:id "displays"))
                     ,(list (map 'list (lambda (s) `(:p ((:id "display")) (:b ,s))) *display-list*)))))
        (:div ((:id "info-container"))
              ((:div ((:id "info"))
                     ,(list
                       ;; Main intro text 
                       (map 'list (lambda (s) `((:p ,s) (:br))) *info-text*)

                       "<b><p>Highlighted Projects:</p></b>"
                       (frontpage-generate-project-cards *curated-highlights*)
                       ;; "<b><p>Itch.IO Releases:</p></b>"
                       ;; *itch-io-releases*
                       ))))
        (:div ((:id "quicklink-container"))
              ((:div ((:id "info"))
                     ,@(list (map 'list
                                  (lambda (s)
                                    `((:a ((:href ,(first s))) ,(second s)) (:br)))
                                  *quicklink-shortcuts*)
                             ))))
        (:div ((:id "ugly-ass-gutter")) "")
        ,(generate-modeline-and-minibuffer2 "welcome-to-my-website"
                                           "index.html"
                                           ;; TODO(jerry): make this not automatically append .html
                                           ;; too lazy to do it today.
                                            (list
                                             ;; "./blog/index.html"
                                             ;; "./game_diary/index.html"
                                             "./projects/index.html"
                                            ; "./art_gallery/index.html"
                                             ;; NOTE(jerry): un-updated link
                                             ;; "./web-projects/index.html"
                                             ))
        ,(script-tag 0)))))))

(build)
