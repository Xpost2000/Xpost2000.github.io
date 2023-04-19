.PHONY: all blog projects landing game_diary art
all: blog projects landing game_diary art
game_diary:
	make -C game_diary/
landing: testgen.cl
	sbcl --script testgen.cl
blog:
	make -C blog/
projects:
	make -C projects/
art:
	make -C art_gallery/
