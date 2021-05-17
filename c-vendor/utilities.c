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

/*
 * This line buffer is fucking horrendous.
 */
static struct line_buffer line_buffer_from_buffer(char* buffer, size_t buffer_length) {
    size_t amount_of_newlines = 0;
    for (size_t character_index = 0; character_index < buffer_length; ++character_index) {
        if (buffer[character_index] == '\r') {
            amount_of_newlines++;
            if (character_index + 1 < buffer_length && buffer[character_index+1] == '\n') {
                character_index++;
            }
        } else if (buffer[character_index] == '\n') {
            amount_of_newlines++;
        }
    }

    struct line_buffer result = {
        .lines = malloc(amount_of_newlines * sizeof(char*)),
        .count = amount_of_newlines
    };
    for (size_t line_index = 0; line_index < amount_of_newlines; ++line_index) { result.lines[line_index] = NULL; }

    size_t line_index = 0;
    size_t character_index = 0;

    while (character_index < buffer_length && line_index < result.count) {
        size_t current_line = line_index++;
        result.lines[current_line] = &buffer[character_index];

        /*
          I still use dangerous string manipulation here, as I don't want
          to spend too much work to fix this...
         */
        while (character_index < buffer_length) {
            if (buffer[character_index] == '\r') {
                buffer[character_index] = 0;
                character_index++;
                if (buffer[character_index] == '\n') {
                    buffer[character_index] = 0;
                    break;
                }
            } else if (buffer[character_index] == '\n') {
                buffer[character_index] = 0;
                break;
            }
            character_index++;
        }

        if (result.lines[current_line][0] == 0) {
            result.lines[current_line] = 0;
        }

        character_index++;
    }

    printf("%d lines written (%d wanted)\n", line_index, amount_of_newlines);

    printf("-- line buffer\n");
    for (size_t line_index = 0; line_index < result.count; ++line_index) {
        printf("(%d): %s\n", line_index, result.lines[line_index]);
    }
    printf("-- end line buffer\n");

    return result;
}
