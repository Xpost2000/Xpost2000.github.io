/*
  This small program just generates the pages for the projects page statically.
  
  This likely shares ALOT of code with the blog page, and is currently a basically
  copy and pasted program.
*/
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <windows.h>

#include <utilities.c>
#include <directory_utility.c>

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

        fprintf(html_document, page_template_text, "empty listing", mini_buffer_strings);
        fclose(html_document);
    }
    free(page_template_text);

    directory_listing_free(&directory);
    return 0;
}
