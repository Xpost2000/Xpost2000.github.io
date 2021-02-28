.PHONY: blog
generate.exe: generate_blog.c
	gcc generate_blog.c -o $@ -O2
blog: generate.exe
	./generate.exe
