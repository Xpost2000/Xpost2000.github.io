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
    struct directory_listing directory = directory_listing_build("projects/");
    directory_listing_sort_by(&directory, DIRECTORY_LISTING_SORT_BY_DATE_ASCENDING_ORDER);
    char* page_template_text = read_entire_file("index_template.html", NULL);
    {
        FILE* html_document = fopen("index.html", "w+");

        size_t written_listing_strings = 0;
        char listing_strings[8192*2] = {};
        
        size_t written_mini_buffer_strings = 0;
        char mini_buffer_strings[8192] = {};

        written_mini_buffer_strings += snprintf(mini_buffer_strings + written_mini_buffer_strings, 8192 - written_mini_buffer_strings, "<li><a href=\"#\">./.</a></li>\n");
        written_mini_buffer_strings += snprintf(mini_buffer_strings + written_mini_buffer_strings, 8192 - written_mini_buffer_strings, "<li><a href=\"../index.html\">./..</a></li>\n");

        {
            for (size_t directory_entry_index = 2;
                 directory_entry_index < directory.entry_count;
                 ++directory_entry_index) {
                struct directory_listing_entry* entry = directory_listing_get_entry(&directory, directory_entry_index);
                char info_text_file_location[512];
                snprintf(info_text_file_location, 512, "projects/%s/info.txt", entry->name);
                printf("reading: %s\n", info_text_file_location);

                size_t file_buffer_size;
                char* file_buffer = read_entire_file(info_text_file_location, &file_buffer_size);

                struct line_buffer lines = line_buffer_from_buffer(file_buffer, file_buffer_size);
                char* title = lines.lines[0];
                char* thumbnail = lines.lines[1];
                /*
                  <li>
                  <p class="project-title"><u><b>Something To Cry About</b></u></p>
                  <img class="project-thumb" src="shooter.png" alt="preview"> </img>
                  <div class="project-description">
                  <br>
                  <p>
                  This project description goes here. It's some pretty impressive and cool text about stuff... Let's just see how long it takes til it fills up,
                  game programming is really hard.
                  game programming is really hard.
                  </p>
                  </div>
                  </li>
                */

                // flat text output, No spacing allowed. It's really supposed to just
                // be a short description. A stronger page generation will be made for
                // more indepth looks at pages.
                written_listing_strings += snprintf(listing_strings + written_listing_strings, 8192*2 - written_listing_strings, "<li>\n");
                written_listing_strings += snprintf(listing_strings + written_listing_strings, 8192*2 - written_listing_strings, "\t<p class=\"project-title\"><u><b>%s</b></u></p>\n", title);
                if (thumbnail[0] != '-') {
                    written_listing_strings += snprintf(listing_strings + written_listing_strings, 8192*2 - written_listing_strings, "\t<img class=\"project-thumb\" src=\"projects/%s/%s\" alt=\"preview\"></img>\n", entry->name, thumbnail);
                }
                written_listing_strings += snprintf(listing_strings + written_listing_strings, 8192*2 - written_listing_strings, "\t<div class=\"project-description\">\n");
                written_listing_strings += snprintf(listing_strings + written_listing_strings, 8192*2 - written_listing_strings, "<p>\n");
                for (size_t line_index = 3; line_index < lines.count; ++line_index) {
                    written_listing_strings += snprintf(listing_strings + written_listing_strings, 8192*2 - written_listing_strings, "%s\n", lines.lines[line_index]);
                }
                written_listing_strings += snprintf(listing_strings + written_listing_strings, 8192*2 - written_listing_strings, "</p>\n");
                written_listing_strings += snprintf(listing_strings + written_listing_strings, 8192*2 - written_listing_strings, "\t</div>\n");
                written_listing_strings += snprintf(listing_strings + written_listing_strings, 8192*2 - written_listing_strings, "</li>\n");

                free(file_buffer);
            }
            printf("---- output\n%s\n---- tuptuo\n", listing_strings);
        }


        fprintf(html_document, page_template_text, listing_strings, mini_buffer_strings);
        fclose(html_document);
    }
    free(page_template_text);

    directory_listing_free(&directory);
    return 0;
}
