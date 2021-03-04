/*
  This small program just generates the pages for the blog statically.
  
  I do not free anything because I don't have to. Also cause I store pointers and
  keeping their lifetimes with freeing is kind of annoying.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

#include <dirent.h>

struct string_list {
    char** strings;
    size_t count;
};

// This is dumb cause I know I'm only going to push.
void string_list_push(struct string_list* list, char* str) {
    char** ptr = list->strings;
    if (list->strings) {
        list->strings = realloc(ptr, list->count);
     } else {
         list->strings = malloc(sizeof(char*));
     }
    list->strings[list->count++] = strdup(str);
}

int main(void) {
    DIR* directory;
    {
        directory = opendir("text/");
        struct dirent* directory_entry;
        {
            directory_entry = readdir(directory);
            directory_entry = readdir(directory);
        }

        struct string_list blog_entries = {};
        struct string_list blog_links = {};

        char temporary_buffer[1024] = {};
        char other_temporary_buffer[1024] = {};

        {
            FILE* html_document = fopen("index.html", "w+");
            if (html_document) {
                fprintf(html_document, "<html>\n");
                fprintf(html_document, "<head>\n");
                fprintf(html_document, "<style>\n");
                {
                    char* font_faces[] = {
                        "OCR", "../shared-resources/OCRAEXT.TTF",
                        "Orator", "../shared-resources/OratorStd.otf",
                        "GNUUnifont", "../shared-resources/unifont-13.0.04.ttf"
                    };
                    for (size_t font_face_index = 0; font_face_index < (sizeof(font_faces)/sizeof(*font_faces)) / 2; ++font_face_index) {
                        fprintf(html_document, "@font-face { font-family: %s; src: url(\'%s\'); }\n",
                                font_faces[font_face_index*2],
                                font_faces[font_face_index*2+1]);
                    }
                }
                fprintf(html_document, "</style>\n");
                // Eh, prettify output later if it runs I'll let it go.
                fprintf(html_document, STRINGIFY(<link rel="stylesheet" href="../styles/common.css">));
                fprintf(html_document, STRINGIFY(<link rel="shortcut icon" href="../favicon.ico" type="image/x-icon">));
                fprintf(html_document, STRINGIFY(<meta http-equiv="content-type" content="text/html; charset=utf-8">));
                fprintf(html_document, STRINGIFY(<meta name="viewport" content="width=device-width, initial-scale=1">));
                fprintf(html_document, STRINGIFY(<title>Jerry Zhu</title>));
                fprintf(html_document, "<body>\n");
                fprintf(html_document, "<div class=\"body-container\">\n");
                fprintf(html_document, "<h1>Jerry\'s Blog</h1>\n");
                fprintf(html_document, "<p>Welcome to the blog</p>\n");
                fprintf(html_document, "<br>\n");
                fprintf(html_document, "<p>Whenever this gets updated, there\'s going to be some new content here.</p>\n");
                fprintf(html_document, "<p>This blog listing should be generated by a C program in the repository,</p>\n");
                fprintf(html_document, "<p>I\'m probably going to just talk about whatever I find interesting.</p>\n");
                fprintf(html_document, "<br>\n");
                fprintf(html_document, "<p>Feel free to use the modeline as an alternative form of navigation.</p>\n");
                fprintf(html_document, "<p><b>Listing:</b></p>");
                while (directory_entry = readdir(directory)) {
                    snprintf(temporary_buffer, 1024, "text/%s", directory_entry->d_name);
                    // more evil truncation
                    {
                        char* start = directory_entry->d_name;
                        while (*start && *start != '.') {
                            start++;
                        }
                        *start = 0;
                    }
                    snprintf(other_temporary_buffer, 1024, "pages/%s.html", directory_entry->d_name);
                    char* name_of_blog;
                    output_blog_html(temporary_buffer, other_temporary_buffer, &name_of_blog);
                    string_list_push(&blog_entries, name_of_blog);
                    string_list_push(&blog_links, other_temporary_buffer);
                }
                for (size_t string_index = 0; string_index < blog_entries.count; ++string_index) {
                    fprintf(html_document, "<a href=\"%s\"><p>%s</p></a>\n", blog_links.strings[string_index], blog_entries.strings[string_index]); 
                }
                fprintf(html_document, "</div>\n");
                fprintf(html_document, "<br>\n");

                /* <li><a href="#">./.</a></li> */
                /*      <li><a href="../index.html">./..</a></li> */
                {
                    fprintf(html_document,
                            STRINGIFY(
                                <div id="ugly-ass-gutter"> </div>
                                <div class="modeline-holder">
                                <div id="mini-buffer-autocompletion">
                                <p>Click on a link to be taken to the page!</p> <br>
                                <ul id="mini-buffer-links">
                            ));
                    /* fprintf(html_document, STRINGIFY(<li><a href="#">./.</a></li> <li><a href="../index.html">./..</a></li>)); */
                    fprintf(html_document, "<li><a href=\"#\">./.</a></li>\n");
                    fprintf(html_document, "<li><a href=\"../index.html\">./..</a></li>\n");
                    for (size_t string_index = 0; string_index < blog_entries.count; ++string_index) {
                        fprintf(html_document, "<li><a href=\"%s\">%s</a></li>\n", blog_links.strings[string_index], blog_links.strings[string_index]);
                    }
                    fprintf(html_document,
                            STRINGIFY(
                                </ul> <br>
                                </div>
                                <div class="mode-bar">
                                <pre>U\--- <b>index.html&lt<a href="../index.html" style="text-decoration:none">xpost2000.github.io</a>&gt</b>    All (0, 0) [NORMAL] (HTML+)</pre>
                                </div>
                                <div class="mini-buffer" id="mini-buffer-main">
                                <pre>welcome-to-my-website<span class="blinking-cursor">█</span></pre>
                                </div>
                                </div>
                                <script src="../scripts/site.js" type="text/javascript"></script>
                            ));
                }
                fprintf(html_document, "</body>\n");
                fprintf(html_document, "\n</html>\n");
                fprintf(html_document, "\n</head>\n");
                fclose(html_document);
            }
        }
    }
    closedir(directory);
    return 0; 
}
