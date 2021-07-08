.PHONY: all blog projects landing game_diary
all: blog projects landing game_diary
game_diary:
	make -C game_diary/
landing: testgen.cl
	sbcl --script testgen.cl
blog:
	make -C blog/
projects:
	make -C projects/
