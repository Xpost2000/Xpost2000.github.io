
(ADD-PROJECTS 
 (PROJECT :TITLE "Portfolio Site"
          :DESCRIPTION
          "This portfolio site is one of my web development projects, and has it's main defining feature being the fact it is made using a custom static site generator! It's changed a lot over the years, finally ending up like this. There's also a neat bash-based custom CMS for a blog system!"
          :LINK "https://github.com/Xpost2000/Xpost2000.github.io"
          :THUMBNAIL "projects/meta//thumb.png"
          :TECHNOLOGIES "Common Lisp HTML5 CSS3"
          :DURATION "2015 - Forever?"
          :STATUS "Always Evolving")
 
 (PROJECT :TITLE "SDL Pong" :DESCRIPTION
          "This was my first 2D game project, which is a polished game of Pong, there is a main menu and an AI driven player."
          :LINK "https://github.com/Xpost2000/SDL-Pong"
          :THUMBNAIL "projects/sdl-pong//pong.png"
          :TECHNOLOGIES "C++ SDL2"
          :DURATION "2015 - (a few days)"
          :STATUS "Complete")
 
 ;; (PROJECT :TITLE "Something To Cry About" :DESCRIPTION
 ;;          "This is my oldest technical game project. It's a simple top down shooter before I discovered the existance of delta-time. I thought it was really cool when I made it though. You could push crates and shoot enemies, along with loading levels from text files which were interpreted as tilemaps."
 ;; :LINK "https://github.com/Xpost2000/SomethingToCryAbout"
 ;;          :THUMBNAIL "projects/smtca//thumb.png")
 
 ;; (PROJECT :TITLE "Something To Cry About 2" :DESCRIPTION
 ;;          "This is the \"sequel\" to the previous project. It now sports an OpenGL renderer that used shaders to support a kind of wonky looking underwater effect. Also there was mouse aim and a basic camera/frustrum culling solution for things. Delta-time was also finally used so the game was roughly framerate independent."
 ;; :LINK "https://github.com/Xpost2000/SomethingToCryAbout2"
 ;;          :THUMBNAIL "projects/smtca2//thumb.png")

 (PROJECT :TITLE "ASCII RPG" :DESCRIPTION
          "This is mistakenly called an ASCII roguelike despite not being a roguelike, though ASCII it is. It was a small game to do with PDCurses, and it was kind of cool to make. It's not very complicated and rather simplistic. Would be repeated again in various different projects like Wanderer. It is a short dungeon crawling adventure where you beat the Orc \"Gorbalt the Cruel!\""
          :LINK "https://github.com/Xpost2000/ASCII-Roguelike"
          :THUMBNAIL "projects/ascii//ascii.png"
          :TECHNOLOGIES "C++ PDCurses"
          :DURATION "2016 - (1 month)"
          :STATUS "Complete")
 
 (PROJECT :TITLE "Wanderer RPG"
          :DESCRIPTION
          "An isometric RPG game/engine written in C. It uses OpenGL for rendering graphics and features a dialogue system that supported conditionals. There was also an grid-based inventory system, and a basic combat system. Inspired by Baldur's Gate/Infinity Engine era RPGs."
          :LINK "https://github.com/Xpost2000/wanderer-errata"
          :THUMBNAIL "projects/wanderer-rpg//wanderer.png"
          :TECHNOLOGIES "C99 SDL2 OpenGL"
          :DURATION "2018 - (3 months)"
          :STATUS "Incomplete") 

 (PROJECT :TITLE "KillBot"
          :DESCRIPTION
          "KillBot was an arena survival platformer, and was made with a custom game engine in C++, with a web-based UI powered by the Chromium Embedded Framework (CEF). The engine is simple but supports event-driven animations, and the game itself has 3 bosses with several stages. This was my first publically released game. While it is a demo, the final game is not much of a deviation beyond the shown preview. The preview is really more a release-candidate."
          :LINK "https://xpost2000.itch.io/killbot"
          :THUMBNAIL "projects/killbot//thumb.png"
          :TECHNOLOGIES "C++ SDL2 CEF OpenGL"
          :DURATION "2018"
          :STATUS "Released") 


 (PROJECT :TITLE "slideshow-rs" :DESCRIPTION
          "This is a slideshow program written in Rust. It is resolution and aspect ratio independent, and utilizes a custom text based format along with a handwritten parser vaguely inspired by MarkDown."
          ;; "This is a stupid slideshow program written in Rust. It is resolution and aspect ratio independent. It uses a text based format, as those are the most flexible format (just write a program to interpret them) as well as being extremely easy to share and transfer. It supports slide transitions and images, as well as basic layout. There is hot-reloading which alleviates that issue. The filebrowser included is primitive, and prone to breaking however the slideshow portion itself is fine. Some called it `jerry-slides`. I do not have many opportunities to use this as many presentations are often in group-work environments(as a student)."
          :LINK "https://github.com/Xpost2000/slideshow"
          :THUMBNAIL "projects/stupid-slideshow//thumb.png"
          :TECHNOLOGIES "Rust SDL2"
          :DURATION "November 2020 - December 2020"
          :STATUS "Complete")

 (PROJECT
  :TITLE "2D Games Framework"
  :LINK "https://github.com/Xpost2000/2D-Game-Framework/blob/main/README.md"
  :THUMBNAIL "projects/2dframework//thumb.png"
  :DESCRIPTION "A small 2D games framework with a plugin-based system that allows for quickly setting up 2D games in C, on Windows there are no dependencies! Features hot-reloading and a debug console. This project is intended to be used for game jams and features a high performance sprite batcher."
  :TECHNOLOGIES "C99 OpenGL"
  :DURATION "July 2021 - October 2021"
  :STATUS "Complete / Usable"
  )

 (PROJECT
  :TITLE "ASCENSION"
  :LINK "https://github.com/Xpost2000/ClockworkCity/blob/master/README.md"
  :THUMBNAIL "projects/ascension//thumb.png"
  :DESCRIPTION "A metroidvania platformer in vain of Hollow Knight style with a monochromatic visual style. Custom engine made from scratch in C99 with components from the 2D Games Framework. Features typical metroidvania movement mechanics such as wall jumping, dashing, and Hollow Knight style bouncing. Basis of some of the technologies that would appear in Legends."
  :TECHNOLOGIES "C99 OpenGL"
  :DURATION "February 2022 - March 2022"
  :STATUS "Gameplay Functional, but incomplete (Ran out of time in the jam)"
  )

 (PROJECT :TITLE "Soul Walker"
          :LINK "https://xpost2000.itch.io/soul-walker"
          :THUMBNAIL "projects/gamejamdungeoncrawler//thumb.png"
          :DESCRIPTION "This was a dungeon crawler made for the Dungeon Crawler Jam 2023. It was my first time learning Unity, and combining this with midterms whilst being a full-time student, and a solo developer was very challenging! It was designed as a surreal survival horror dungeon crawler under the jam theme \"Duality\"."
          :TECHNOLOGIES "Unity C#"
          :DURATION "April 2023 - (4 days)"
          :STATUS "Complete"
          )

 (PROJECT :TITLE "CrankLang - Programming Language"
          :DESCRIPTION "A custom statically typed programming language compiler with a handwritten recursive descent parser. The current frontend is written in C++, and the language compiles into C++, and supports an FFI. The frontend does all the parsing and static analysis before it ever reaches the C++ compiler!"
          :LINK "https://github.com/Xpost2000/cranklang/blob/master/README.md"
          :THUMBNAIL "projects/crank//thumb.png"
          :TECHNOLOGIES "C++"
          :DURATION "April 2023 - Present"
          :STATUS "In-development") 

 (PROJECT :TITLE "Legends RPG"
          :DESCRIPTION "A software rendered tactics JRPG game and engine. It is written in C completely from scratch with SDL2 as it's only dependency, and features a multithreaded software renderer to perform postprocessing in real time. There is also an integrated level editor, and many more features!"
          :LINK "https://github.com/Xpost2000/Legends-JRPG/blob/master/README.md"
          :THUMBNAIL "projects/legends-jrpg//thumb.png"
          :TECHNOLOGIES "C99 Emscripten SIMD SDL2"
          :DURATION "June 2022 - Present"
          :STATUS "In-development")) 
