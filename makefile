.PHONY: all blog projects landing
all: blog projects landing
landing: testgen.cl
	sbcl --script testgen.cl
blog:
	make -C blog/
projects:
	make -C projects/
