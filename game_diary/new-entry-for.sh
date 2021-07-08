echo "Game Id(steamid)[ CTRL-C to leave ]"
read setup_entry_name

function entry_script {
    printf "game_%s/write-blog-entry.sh" $setup_entry_name
}

function entry_directory {
    printf "game_%s/" $setup_entry_name
}

cd $(entry_directory)
./write-blog-entry.sh
