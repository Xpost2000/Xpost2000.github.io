/*
  This small program just generates the pages for the blog statically.
  
  I do not free anything because I don't have to. Also cause I store pointers and
  keeping their lifetimes with freeing is kind of annoying.
*/
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <windows.h>

#define STRINGIFY(x) #x

#include "utilities.c"
#include "directory_utility.c"

int output_blog_html(char* blog_source, char* blog_output, char** out_blog_title, char* previous, char* next) {
    size_t file_buffer_size;
    char* file_buffer = read_entire_file(blog_source, &file_buffer_size);

    struct line_buffer lines = line_buffer_from_buffer(file_buffer, file_buffer_size);

    if (lines.count <= 2) {
        fprintf(stderr, "This seems like an ill-formatted blog file.\n");
        return 1;
    } else {
        char* blog_title = lines.lines[0];
        if (out_blog_title) {*out_blog_title = blog_title;}
        char* date_created = lines.lines[1];

        {
            char* template_text = read_entire_file("template.html", NULL);
            FILE* html_document = fopen(blog_output, "wb+");

            size_t written_blog_text = 0;
            char blog_text[8192] = {};

            {
                int needs_opening_tag = 1;
                for (size_t line_index = 2; line_index < lines.count; ++line_index) {
                    if ((lines.lines[line_index] == NULL)) {
                        written_blog_text += snprintf(blog_text + written_blog_text, 8192 - written_blog_text, "</p>\n");
                        written_blog_text += snprintf(blog_text + written_blog_text, 8192 - written_blog_text, "<br>\n");
                        needs_opening_tag = 1;
                    } else {
                        if (needs_opening_tag) {
                            written_blog_text += snprintf(blog_text + written_blog_text, 8192 - written_blog_text, "<p>\n");
                            needs_opening_tag = 0;
                        }
                        written_blog_text += snprintf(blog_text + written_blog_text, 8192 - written_blog_text, "%s ", lines.lines[line_index]);
                    }
                }
                written_blog_text += snprintf(blog_text + written_blog_text, 8192 - written_blog_text, "<br>\n");
                written_blog_text += snprintf(blog_text + written_blog_text, 8192 - written_blog_text, "<p>View the plaintext version <a href=\"../%s\">here</a></p>\n", blog_source);
            }
        
            size_t written_mini_buffer_strings = 0;
            char mini_buffer_strings[8192] = {};
            {
                written_mini_buffer_strings += snprintf(mini_buffer_strings + written_mini_buffer_strings, 8192 - written_mini_buffer_strings, "<li><a href=\"%s\">%s</a></li>\n", "#", "./.");
                written_mini_buffer_strings += snprintf(mini_buffer_strings + written_mini_buffer_strings, 8192 - written_mini_buffer_strings, "<li><a href=\"%s\">%s</a></li>\n", "../index.html", "./..");
                if (next) {
                    written_mini_buffer_strings += snprintf(mini_buffer_strings + written_mini_buffer_strings, 8192 - written_mini_buffer_strings, "<li><a href=\"%s.html\">%s</a></li>\n", next, "./next_entry");
                }
                if (previous) {
                    written_mini_buffer_strings += snprintf(mini_buffer_strings + written_mini_buffer_strings, 8192 - written_mini_buffer_strings, "<li><a href=\"%s.html\">%s</a></li>\n", previous, "./previous_entry");
                }
            }

            fprintf(html_document, template_text,
                    blog_title, date_created,
                    blog_text,
                    mini_buffer_strings,
                    "../index.html", "xpost2000.github.io");
            free(template_text);
        }
    }
    return 0;
}

int main(void) {
    struct directory_listing directory = directory_listing_build("text/");
    directory_listing_sort_by(&directory, DIRECTORY_LISTING_SORT_BY_DATE_ASCENDING_ORDER);
    char* page_template_text = read_entire_file("index_template.html", NULL);
    {
        FILE* html_document = fopen("index.html", "w+");

        size_t written_listing_strings = 0;
        char listing_strings[8192] = {};
        
        size_t written_mini_buffer_strings = 0;
        char mini_buffer_strings[8192] = {};

        written_mini_buffer_strings += snprintf(mini_buffer_strings + written_mini_buffer_strings, 8192 - written_mini_buffer_strings, "<li><a href=\"#\">./.</a></li>\n");
        written_mini_buffer_strings += snprintf(mini_buffer_strings + written_mini_buffer_strings, 8192 - written_mini_buffer_strings, "<li><a href=\"../index.html\">./..</a></li>\n");

        char temporary_buffer[1024] = {};
        char other_temporary_buffer[1024] = {};

        for (size_t directory_entry_index = 2; directory_entry_index < directory.entry_count; ++directory_entry_index) {
            struct directory_listing_entry* entry = directory_listing_get_entry(&directory, directory_entry_index);
            snprintf(temporary_buffer, 1024, "text/%s", entry->name);

            struct directory_listing_entry_string filename_without_extension = directory_listing_entry_name_without_extension(entry), previous_entry_name, next_entry_name;
            snprintf(other_temporary_buffer, 1024, "pages/%s.html", filename_without_extension.name);

            char* name_of_blog;
            char* next = NULL;
            char* previous = NULL;
            if (directory_entry_index - 1 >= 2) {
                previous_entry_name = directory_listing_entry_name_without_extension(directory_listing_get_entry(&directory, directory_entry_index-1));
                previous = previous_entry_name.name;
            }
            if (directory_entry_index + 1 < directory.entry_count) {
                next_entry_name = directory_listing_entry_name_without_extension(directory_listing_get_entry(&directory, directory_entry_index+1));
                next = next_entry_name.name;
            }
            if(!output_blog_html(temporary_buffer, other_temporary_buffer, &name_of_blog, previous, next)) {
                printf("\"%s\" was successfully outputted!\n", name_of_blog);
            } else {
                printf("Something went wrong??\n");
            }

            written_listing_strings += snprintf(listing_strings + written_listing_strings, 8192 - written_listing_strings, "<a href=\"%s\"><p>%s</p></a>\n", other_temporary_buffer, name_of_blog);
            written_mini_buffer_strings += snprintf(mini_buffer_strings + written_mini_buffer_strings, 8192 - written_mini_buffer_strings, "<li><a href=\"%s\">%s</a></li>\n", other_temporary_buffer, other_temporary_buffer);
        }

        fprintf(html_document, page_template_text, listing_strings, mini_buffer_strings);
        fclose(html_document);
    }
    free(page_template_text);

    directory_listing_free(&directory);
    return 0;
}
