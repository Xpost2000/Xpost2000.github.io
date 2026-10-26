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

(defun get-image-listings (image-directory)
	(relative-directory-listing image-directory))

(defun image-anchor (img)
	`(:li (:a ((:href ,img)) 
						((:p ,img)
						 (:img ((:src ,img)) " " )))))

(defun build ()
	(let* ((inktober2026-images (get-image-listings "inktober2026/")))
		(print inktober2026-images)
		(html->file
			"index.html"
			(with-common-page-template
				:page-title "Art"
				:current-link-text "art.html"
				:modeline-links (page-links inktober2026-images)
				:body
				`(,@(page-content
							"Art"
							(list "Sometimes I draw, and it goes here.")
							'(:p (:b "Inktober 2026 Listing: "))
							'(:br)
							`(:ul ,(mapcar #'image-anchor inktober2026-images))
							'(:p (:b "Listing: "))
							'(:br)))))))
(build)
