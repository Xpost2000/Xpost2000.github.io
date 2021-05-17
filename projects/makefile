.PHONY: all blog
all: generate.exe blog
generate.exe: generate_blog.c ../c-vendor/utilities.c
	gcc generate_blog.c -o $@ -g  -I../c-vendor/
blog: generate.exe
	./generate.exe
