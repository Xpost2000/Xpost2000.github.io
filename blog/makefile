.PHONY: all blog
blog: testgen.cl
	sbcl --script testgen.cl
# all: generate.exe blog
# generate.exe: generate_blog.c ../c-vendor/utilities.c
# 	gcc generate_blog.c -o $@ -g  -I../c-vendor/
# blog: generate.exe
# 	./generate.exe
