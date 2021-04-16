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

struct line_buffer {
    size_t count;
    char** lines;
};

static char* read_entire_file(const char* file_name, size_t* bytes) {
    char* file_buffer = NULL;
    FILE* file_handle = fopen( file_name, "rb" );

    if (file_handle) {
        fseek(file_handle, 0, SEEK_END);
        size_t file_size = ftell(file_handle);
        fseek(file_handle, 0, SEEK_SET);

        file_buffer = malloc(file_size + 1);

        if (file_buffer) {
            size_t read_bytes = fread(file_buffer, 1, file_size, file_handle);
            if (bytes) {
                *bytes = read_bytes;
            }
        }
        file_buffer[file_size] = 0;
    }

    return file_buffer;
}

// only taking unix line endings.
static struct line_buffer line_buffer_from_buffer(char* buffer, size_t buffer_length) {
    size_t amount_of_newlines = 0;
    for (size_t character_index = 0; character_index < buffer_length; ++character_index) {
        // stupid windows line endings
        if (buffer[character_index] == '\r') {
            amount_of_newlines++;
            buffer[character_index] = 0;
            if (character_index + 1 < buffer_length && character_index < buffer_length && buffer[character_index+1] == '\n') {
                buffer[character_index+1] = 0;
                character_index++;
            }
        } else if (buffer[character_index] == '\n') {
            amount_of_newlines++;
            buffer[character_index] = 0;
        }
    }

    struct line_buffer result = {
        .lines = malloc(amount_of_newlines * sizeof(char*)),
        .count = amount_of_newlines
    };
    for (size_t line_index = 0; line_index < amount_of_newlines; ++line_index) { result.lines[line_index] = NULL; }

    size_t line_index = 0;
    for (size_t character_index = 0; character_index < buffer_length && line_index < result.count; ++character_index) {
        if (buffer[character_index] == 0 && buffer[character_index+1] == 0) {
            character_index++;
            line_index++;
        } else if (result.lines[line_index] == NULL) {
            result.lines[line_index] = &buffer[character_index];
        }
    }

    return result;
}

int output_blog_html(char* blog_source, char* blog_output, char** out_blog_title) {
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
            FILE* html_document = fopen(blog_output, "w+");
            if (html_document) {
                fprintf(html_document, "<html>\n");
                fprintf(html_document, "<head>\n");
                fprintf(html_document, "<style>\n");
                {
                    char* font_faces[] = {
                        "OCR", "../../shared-resources/OCRAEXT.TTF",
                        "Orator", "../../shared-resources/OratorStd.otf",
                        "GNUUnifont", "../../shared-resources/unifont-13.0.04.ttf"
                    };
                    for (size_t font_face_index = 0; font_face_index < (sizeof(font_faces)/sizeof(*font_faces)) / 2; ++font_face_index) {
                        fprintf(html_document, "@font-face { font-family: %s; src: url(\'%s\'); }\n",
                                font_faces[font_face_index*2],
                                font_faces[font_face_index*2+1]);
                    }
                }
                fprintf(html_document, "</style>\n");
                // Eh, prettify output later if it runs I'll let it go.
                fprintf(html_document, STRINGIFY(<link rel="stylesheet" href="../../styles/common.css">));
                fprintf(html_document, STRINGIFY(<link rel="shortcut icon" href="../../favicon.ico" type="image/x-icon">));
                fprintf(html_document, STRINGIFY(<meta http-equiv="content-type" content="text/html; charset=utf-8">));
                fprintf(html_document, STRINGIFY(<meta name="viewport" content="width=device-width, initial-scale=1">));
                fprintf(html_document, STRINGIFY(<title>Jerry Zhu</title>));
                fprintf(html_document, "<body>\n");
                fprintf(html_document, "<div class=\"body-container\">\n");
                fprintf(html_document, "<h1>%s</h1>\n", blog_title);
                fprintf(html_document, "<p><b>Date Published:</b> <span style=\"background-color: yellow; color: black;\">(%s)</span></p>\n", date_created);
                fprintf(html_document, "<br>\n");
                {
                    int needs_opening_tag = 1;
                    for (size_t line_index = 2; line_index < lines.count; ++line_index) {
                        if ((lines.lines[line_index] == NULL)) {
                            fprintf(html_document, "</p>\n");
                            fprintf(html_document, "<br>\n");
                            needs_opening_tag = 1;
                        } else {
                            if (needs_opening_tag) {
                                fprintf(html_document, "<p>");
                                needs_opening_tag = 0;
                            }
                            fprintf(html_document, "%s ", lines.lines[line_index]);
                            /* fprintf(html_document, "<p>%s</p>\n", lines.lines[line_index]); */
                        }
                    }
                }
                fprintf(html_document, "<br>\n");
                fprintf(html_document, "<p>View the plaintext version <a href=\"../%s\">here</a></p>\n", blog_source);
                fprintf(html_document, "</div>\n");
                fprintf(html_document, "<br>\n");
                {
                    // Going to need a more advanced templating solution later.
                    // As in like within the next week.
                    // Expect to rewrite later.
                    fprintf(html_document,
                            STRINGIFY(
                                <div id="ugly-ass-gutter"> </div>
                                <div class="modeline-holder">
                                <div id="mini-buffer-autocompletion">
                                <p>Click on a link to be taken to the page!</p> <br>
                                <ul id="mini-buffer-links">
                                <li><a href="#">./.</a></li>
                                <li><a href="../index.html">./..</a></li>
                                <li><a href="#next?">./next_entry</a></li>
                                <li><a href="#previous?">./previous_entry</a></li>
                                </ul> <br>
                                </div>
                                <div class="mode-bar">
                                <pre>U\--- <b>index.html&lt<a href="../index.html" style="text-decoration:none">xpost2000.github.io</a>&gt</b>    All (0, 0) [NORMAL] (HTML+)</pre>
                                </div>
                                <div class="mini-buffer" id="mini-buffer-main">
                                <pre>welcome-to-my-website<span class="blinking-cursor">█</span></pre>
                                </div>
                                </div>
                                <script src="../../scripts/site.js" type="text/javascript"></script>
                            ));
                }
                fprintf(html_document, "</body>\n");
                fprintf(html_document, "\n</html>\n");
                fprintf(html_document, "\n</head>\n");
                fclose(html_document);
            }

        }
    }
    return 0;
}

#include "directory_utility.c"

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

        snprintf(mini_buffer_strings, 8192, "<li><a href=\"#\">./.</a></li>\n");
        snprintf(mini_buffer_strings, 8192, "<li><a href=\"../index.html\">./..</a></li>\n");

        char temporary_buffer[1024] = {};
        char other_temporary_buffer[1024] = {};

        for (size_t directory_entry_index = 2; directory_entry_index < directory.entry_count; ++directory_entry_index) {
            struct directory_listing_entry* entry = directory_listing_get_entry(&directory, directory_entry_index);
            snprintf(temporary_buffer, 1024, "text/%s", entry->name);

            struct directory_listing_entry_string filename_without_extension = directory_listing_entry_name_without_extension(entry);
            snprintf(other_temporary_buffer, 1024, "pages/%s.html", filename_without_extension.name);

            char* name_of_blog;
            output_blog_html(temporary_buffer, other_temporary_buffer, &name_of_blog);

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
