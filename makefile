.PHONY: all blog projects
all: blog
blog:
	make -C blog/
projects:
	make -C projects/
