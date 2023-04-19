#|
	Common Lisp page generator for Xpost2000.github.io

	Makes the page generation less painful, mostly.

	This is reusable for generating other pages, although obviously don't
	use this for actual websites since this probably only works for my specific
	scenario. Please use something else, like Clojurescript which actually has good
	libraries to do this thing.

	It only really works with the requirements of this page, as this thing does not even try to pretty print
	correctly. Any attempts at using <PRE> may explode violently.

	I might try to do proper pretty printing later if I don't forget about this tomorrow.

	Basically use a hiccup like format, and common lisp acts as a convenient template engine. At least I don't need
	external html files. It's also easier to write than html itself...
|#

;; grr inclusion order. ASDF would solve this but I'll just order it like this for now
;; since it'll be fine enough.
(load "../generator/htmlify.cl")
(load "../generator/common.cl")

(load "../generator/blog-bro.cl")

(defun build ()
  (html->file
   "index.html"
   (let* ((blog-listing-and-links (install-blog))
          (links
            (map 'list #'text-link->page-link
                 (loop for item in blog-listing-and-links collect (getf item :link)))))
     (with-common-page-template
       :page-title "Art Gallery"
       :current-link-text "art.html"
       :modeline-links links
       :body
       `(,@(page-content
            "Jerry's Art Gallery"
            (list "I've taken to digital art, so stuff will appear here when I have something new to add!"
                  ""
                  "I am learning to illustrate anime characters, being heavily inspired by game/manga illustrators like Kousuke Fujishima for his works on the 'Tales of' franchise."
                  )
            '(:p (:b "Listing: "))
            '(:br)
            '(:p (:b "Will add later! I'm still getting ready!"))))))))
(build)
