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
  '(
    ;; "I'm Jerry, and I've been programming specifically (and playing) video games for about as long as I could remember. I've worked on programming small games, demos, and participating in game jams for about 5 years."
    ;; "My skills are primarily in C and C++, where I develop games from scratch with custom game engines! I have graphics programming experience writing software renderers, and also APIs such as OpenGL."
    ;; "Below are some of my projects with a short description and thumbnail. You can learn more, or view more materials such as videos and code samples by clicking on the thumbnails!"
    "I'm Jerry, I am an avid gamer, and I am also an avid game programmer! I publish independent games on itch.io under the online alias Xpost2000."
    "I am currently an undergraduate student at Stony Brook University studying Computer Science."
    "I've been programming small games, demos, custom engines, and participating in various game jams for as long as I could remember."
    "I am primarily a C++ and C programmer, and I develop games from scratch with custom game engines and tools! I have graphics programming experience with building software renderers, or using APIs like OpenGL for hardware acceleration. I also have experience working with game engines like Unity and Unreal."
    "My projects are divided into:<ul><li><b>Projects</b>: C / C++ primarily showing technical abilities as a programmer. Gameplay is secondary, but still present!</li><li><b>Game Jam Projects</b>: C# or C++, Small complete experiences which are more gameplay oriented than technical.</li><li><b>Legacy Projects</b>: Older projects that I use to remind myself of how far I've come.</li></ul>"
    "Below are summaries of my projects. You can learn more, and view more materials such as videos and code samples by clicking on the thumbnails!")
)
(defparameter *display-list*
  '("Contact me at: jerry.zhu@stonybrook.edu"))

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
   (find-project "ASCENSION")
   (find-project "CrankLang - Programming Language")
   (find-project "2D Games Framework")
   ))
(defparameter *curated-gamejam-highlights*
  (list
   (find-project "Soul Walker - Dungeon Crawler Jam")
   (find-project "Fateless Challenge")
   (find-project "L4DRL - 7 Day Roguelike")
   (find-project "TreeWatcher - Ludum Dare 46")
   ))
(defparameter *curated-legacy-highlights*
  (list
   (find-project "Wanderer RPG")
   (find-project "KillBot")
   (find-project "SDL Pong")
   ))

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
               (:h1 ((:id "sub-sub-header-title-id")) "C / C++ Game Programmer")
               (:h1 ((:id "sub-header-title-id")) "
Jerry Zhu
<br>
<a href=\"https://www.github.com/Xpost2000\">github</a> <a href=\"https://xpost2000.itch.io/\">itch.io</a> <a href=\"https://www.linkedin.com/in/jerry-zhu-220133215/\">linkedin</a> <a href=\"./resumes/Jerry_Zhu_Resume.pdf\">resume</a>

")
               (:div ((:id "displays"))
                     ,(list (map 'list (lambda (s) `(:p ((:id "display")) (:b ,s))) *display-list*)))))
        (:div ((:id "info-container"))
              ((:div ((:id "info"))
                     ,(list
                       ;; Main intro text 
                       (map 'list (lambda (s) `((:p ((:style "margin: 1.5em")) ,s))) *info-text*)
                       "<h2 id=\"projects\" style=\"font-size: 32px;\">Projects:</h2>"
                       "These are my main-stay projects, which are representative of either my most technically interesting work, or best/polished work."
                       "<br>Usually, these are custom game engine projects, tech demos, and games written with C or C++. There are a few non-game projects from time to time."
                       (frontpage-generate-project-cards *curated-highlights*)
                       "<h2 id=\"game-jam-projects\" style=\"font-size: 32px;\">Game Jam Projects:</h2>"
                       "These are my game jam projects which are usually excursions to learn different technology. I also use these as opportunities to get creative with the jam themes and limited time."
                       "<br>Usually these projects are more about gameplay features rather than pure technical features like my main projects."
                       (frontpage-generate-project-cards *curated-gamejam-highlights*)
                       "<h2 id=\"legacy-projects\" style=\"font-size: 32px;\">Legacy Projects:</h2>"
                       "While this isn't my best work, I like to have a way to remind myself of how far I've gone :)"
                       "<br>These projects are also C / C++ much like my normal projects. The main difference is mostly that they are way too old to be relevant to my current ability!"
                       (frontpage-generate-project-cards *curated-legacy-highlights*)
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
