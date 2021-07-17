
# I may replace xcms with a real programming language instead of bash
# since I suck at writing bash scripts, but sbcl might take too long to run.
# using C might be even faster lol.
# Though the game cache is probably being done in lisp, so yeah... Who knows?
# it might just be another lisp script so I can avoid doing too much work. (reading the db would be easy)

# I don't really disallow invalid input, which is fine I guess.
echo "Game Entry Setup(steamid)[ CTRL-C to leave ]"
read setup_entry_name

function new_game_folder {
    printf "game_%s" $setup_entry_name
}

mkdir $(new_game_folder)
mkdir $(new_game_folder)/pages
mkdir $(new_game_folder)/text
cp xcms-setup/write-blog-entry.sh $(new_game_folder)/write-blog-entry.sh

echo "Setup new directory... Generating and rebuilding game cache."

make
