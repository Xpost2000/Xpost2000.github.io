# This one will not commit like the other XCMS stuff.
# this is meant to be used while writing or something like
# that.

echo "Game Id(steamid) [ CTRL-C to leave ]"
read setup_entry_name

function entry_directory {
    printf "game_%s/" $setup_entry_name
}

function entry_screenshot_directory {
    printf "game_%s/screenshots" $setup_entry_name
}

mkdir $(entry_screenshot_directory)
echo "File Name Of Screenshot To Upload Over: "
read filename
cp $filename $(entry_screenshot_directory)
