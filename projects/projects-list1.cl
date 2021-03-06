
(ADD-PROJECTS 
(PROJECT :TITLE "ASCII RPG" :DESCRIPTION
         "This is mistakenly called an ASCII roguelike despite not being a roguelike, though ASCII it is. It was a small game to do with PDCurses, and it was kind of cool to make. It's not very complicated and rather simplistic. Would be repeated again in various different projects like Wanderer."
         :THUMBNAIL "projects/ascii//ascii.png")
              
(PROJECT :TITLE "This Site." :DESCRIPTION
         "Yes, this is definitely meta. This is one of my web development projects. The website went through older iterations and such, generally which shows my growth as a web developer (which is not much as I don't actively really do it.) A retro computing aesthetic to resemble an EMACS/VI session was chosen as I really like using those editors, and I think most websites look too generic. The best experience for this website is to go fullscreen, and use keyboard. Due to the odd design, it is difficult to work this on mobile (much how mobile VI is not a fun time.)"
         :THUMBNAIL "projects/meta//thumb.png")
              
(PROJECT :TITLE "SDL Pong" :DESCRIPTION
         "A polished Pong game made with SDL2. There's literally nothing else to say about this. It was made in the most naive way possible."
         :THUMBNAIL "projects/sdl-pong//pong.png")
              
(PROJECT :TITLE "Something To Cry About" :DESCRIPTION
         "This is my oldest technical game project. It's a simple top down shooter before I discovered the existance of delta-time. I thought it was really cool when I made it though. You could push crates and shoot enemies, along with loading levels from text files which were interpreted as tilemaps."
         :THUMBNAIL "projects/smtca//thumb.png")
              
(PROJECT :TITLE "Something To Cry About 2" :DESCRIPTION
         "This is the \"sequel\" to the previous project. It now sports an OpenGL renderer that used shaders to support a kind of wonky looking underwater effect. Also there was mouse aim and a basic camera/frustrum culling solution for things. Delta-time was also finally used so the game was roughly framerate independent."
         :THUMBNAIL "projects/smtca2//thumb.png")
              
(PROJECT :TITLE "stupid-slideshow" :DESCRIPTION
         "This is a stupid slideshow program written in Rust. It is resolution and aspect ratio independent. It uses a text based format, as those are the most flexible format (just write a program to interpret them) as well as being extremely easy to share and transfer. It supports slide transitions and images, as well as basic layout. There is hot-reloading which alleviates that issue. The filebrowser included is primitive, and prone to breaking however the slideshow portion itself is fine. Some called it `jerry-slides`. I do not have many opportunities to use this as many presentations are often in group-work environments(as a student)."
         :THUMBNAIL "projects/stupid-slideshow//thumb.png")
              
(PROJECT :TITLE "Wanderer RPG" :DESCRIPTION
         "An incomplete isometric RPG game/engine written in C. This was never hosted on GitHub. It was hosted on a private Mercurial server instead, because I still think Mercurial is more easily usable than Git. That's just a personal choice though. It supported an OpenGL based isometric renderer, a custom config reader, and had a editor for \"sprites\". It also had a handwritten GUI system that did basic layout, and rendering was sorted as you would expect. It uses a directed graph for a dialogue system that was also able to query game state for conditionals."
         :THUMBNAIL "projects/wanderer-rpg//wanderer.png") ) 