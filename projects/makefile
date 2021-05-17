.PHONY: all projects
all: generate.exe projects
generate.exe: generate_projects.c ../c-vendor/utilities.c
	gcc generate_projects.c -o $@ -g  -I../c-vendor/
projects: generate.exe
	./generate.exe
