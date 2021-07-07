.PHONY: all blog projects
all: blog projects
blog:
	make -C blog/
projects:
	make -C projects/
