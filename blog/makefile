.PHONY: all blog
all: generate.exe blog
generate.exe: generate_blog.c
	gcc generate_blog.c -o $@ -g 
blog: generate.exe
	./generate.exe
