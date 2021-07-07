;; I'm not going to use ASDF for something this small.

;; I would do this in a more robust way, but this'll just handle the cases I use this.
;; I'm just going to load the two combinations I'm usually invoking.
(ignore-errors (load "./generator/htmlify.cl"))
(ignore-errors (load "../generator/htmlify.cl"))

;; I could make this script replace the makefile but it's more annoying to do this.
