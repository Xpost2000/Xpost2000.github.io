#include <windows.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef enum directory_listing_sort_mode {
    DIRECTORY_LISTING_SORT_NONE,
    DIRECTORY_LISTING_SORT_BY_DATE_ASCENDING_ORDER,
    DIRECTORY_LISTING_SORT_MODE_COUNT,
} directory_listing_sort_mode;

// This should arguably be a dynamic string, but we'll follow what win32 defines
// as max. If this goes wrong I'll fix it later.
#define FILE_NAME_MAX_LENGTH (260)
typedef enum directory_listing_entry_type {
    DIRECTORY_LISTING_ENTRY_FILE,
    DIRECTORY_LISTING_ENTRY_DIRECTORY,
    /* DIRECTORY_LISTING_ENTRY_SYMBOLIC_LINK ??*/
} directory_listing_entry_type;

// This keeps date out of the struct, which is most certainly a mistake...
struct directory_listing_entry_string {
    char name[FILE_NAME_MAX_LENGTH]; 
};
struct directory_listing_entry {
    directory_listing_entry_type type;
    size_t size;

    char name[FILE_NAME_MAX_LENGTH];
};

struct directory_listing_entry_string directory_listing_entry_name_without_extension(struct directory_listing_entry* entry) {
    struct directory_listing_entry_string result = {};

    for (size_t character_index = 0;
         character_index < FILE_NAME_MAX_LENGTH;
         ++character_index) {
        if (entry->name[character_index] == '.') {
            break;
        }
        result.name[character_index] = entry->name[character_index];
    }

    return result;
}

    struct win32_directory_listing_entry {
        struct directory_listing_entry general_info;

        union {
            FILETIME filetime;
            uint64_t filetime_as_qword;
        };
    };

struct directory_listing {
    void* entries;
    size_t entry_count;
};

size_t count_entries_in_directory(const char* directory_string) {
    WIN32_FIND_DATA find_file_data = {}; 
    HANDLE file_handle = FindFirstFileA(directory_string, &find_file_data);
    size_t entry_count = 0;
    do {entry_count++;} while (FindNextFile(file_handle, &find_file_data));
    return entry_count;
}

struct directory_listing_entry* directory_listing_get_entry(struct directory_listing* listing, size_t index) {
    void* pointer = listing->entries + (index*sizeof(struct win32_directory_listing_entry));
    return (struct directory_listing_entry*)pointer;
}

// this is only for windows right now.
struct directory_listing directory_listing_build(const char* directory_string) {
    char temporary_directory_name_match_buffer[FILE_NAME_MAX_LENGTH*2] = {};
    strncat(temporary_directory_name_match_buffer, directory_string, FILE_NAME_MAX_LENGTH);
    strncat(temporary_directory_name_match_buffer, "/*", FILE_NAME_MAX_LENGTH);

    struct directory_listing result = {};

    size_t directory_listing_count = count_entries_in_directory(temporary_directory_name_match_buffer);
    result.entries = malloc(sizeof(struct win32_directory_listing_entry) * directory_listing_count);
    result.entry_count = directory_listing_count;
    memset(result.entries, 0, sizeof(struct win32_directory_listing_entry) * directory_listing_count);

    // worry about the Wide versions later?
    // also same with error handling.
    // also because of directory_listing_count this does mean we find twice, which is true.
    // TODO: provide streaming version with iterator style.
    {
        WIN32_FIND_DATA find_file_data = {};
        HANDLE file_handle = FindFirstFileA(temporary_directory_name_match_buffer, &find_file_data);

        for (size_t directory_entry_index = 0;
             directory_entry_index < directory_listing_count;
             ++directory_entry_index) {
            struct win32_directory_listing_entry* entry = directory_listing_get_entry(&result, directory_entry_index);
            if (find_file_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                entry->general_info.type = DIRECTORY_LISTING_ENTRY_DIRECTORY;
            } else {
                entry->general_info.type = DIRECTORY_LISTING_ENTRY_FILE;
                LARGE_INTEGER file_size = {
                    .LowPart = find_file_data.nFileSizeLow,
                    .HighPart = find_file_data.nFileSizeHigh,
                };
                entry->general_info.size = file_size.QuadPart;
            }
            entry->filetime = find_file_data.ftCreationTime;
            strncpy(entry->general_info.name, find_file_data.cFileName, FILE_NAME_MAX_LENGTH);
            FindNextFile(file_handle, &find_file_data);
        }

        FindClose(file_handle);
    }

    return result;
}

void directory_listing_free(struct directory_listing* listing) {
    free(listing->entries);
}

// unfortunately needs to change based on OS. So whoops, I'll change it back later then...
typedef int (*qsort_predicate)(const void*, const void*);

static int _directory_listing_sort_predicate_ascending_order(const void* first, const void* second) {
    struct win32_directory_listing_entry* first_entry = first;
    struct win32_directory_listing_entry* second_entry = second;

    if (first_entry->filetime_as_qword < second_entry->filetime_as_qword) {
        return -1;
    } else if (first_entry->filetime_as_qword > second_entry->filetime_as_qword) {
        return 1;
    }

    return 0;
}

void directory_listing_sort_by(struct directory_listing* listing, directory_listing_sort_mode mode) {
    qsort_predicate comparison_function = 0;
    switch (mode) {
        case DIRECTORY_LISTING_SORT_NONE:
        {
            return;
        }
        break;
        case DIRECTORY_LISTING_SORT_BY_DATE_ASCENDING_ORDER:
        {
            comparison_function = _directory_listing_sort_predicate_ascending_order;
        }
        break;
        default:
        {
            return; 
        }
        break;
    }

    // On windows it appears the first two directories are "./" and "../".
    // Which don't make sense for me to sort.
    qsort(listing->entries + (sizeof(struct win32_directory_listing_entry) * 2),
          listing->entry_count-2,
          sizeof(struct win32_directory_listing_entry), comparison_function);
}
