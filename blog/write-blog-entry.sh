#!/usr/bin/sh

# Unfortunately we need to set current directory first unfortunately.

pushd . > /dev/null
cd $(dirname "$0")

vcs_add_all="git add -A"
vcs_commit="git commit"
vcs_push_upstream="git push -u"
make=make
text_editor=vim

# Also this was harder than I'd like to admit.

# This is a stupid shell script that automates writing blog entries.
# It's like an ad-hoc CMS for this website.

function acceptable_date_string {
    date +"%m/%d/%Y %H:%M %p"
} 

blog_temporary_directory=".xcms"
blog_text_directory="text/"

if [ ! -d "$blog_temporary_directory" ]; then
   echo "Creating CMS for blog." 
   mkdir $blog_temporary_directory
   touch $blog_temporary_directory/CURRENT_BLOG_CONTENTS
fi

cat /dev/null > $blog_temporary_directory/CURRENT_BLOG_CONTENTS

echo "New Blog Entry[ CTRL-C to leave ]: "
read current_blog_title

# I've been told that this is POSIX compliant, so any working MSYS installation
# or POSIX environment should work fine with this.

function blog_file_location {
    printf "%s%s.txt" $blog_text_directory ${current_blog_title// /_} | tr '[:upper:]' '[:lower:]'
}

blog_file=$(blog_file_location)
printf "proceeding to edit with vim: %s\n" $blog_file

# vim does not appear to distinguish against file changes. Damn.
vim $blog_temporary_directory/CURRENT_BLOG_CONTENTS
printf "writing blog entry: %s\n" $blog_file

# I should probably use cat, since it's technically faster and simpler... But whatever.
printf "%s\n%s %s %s\n\n%s" "$current_blog_title" $(acceptable_date_string) "$(cat $blog_temporary_directory/CURRENT_BLOG_CONTENTS)" > $(blog_file_location)
$make blog

# weird pathspec error, too lazy to debug.
$vcs_add_all
$vcs_commit -am "[XCMS] Blog Entry: \"$current_blog_title\""
$vcs_push_upstream

print "XCMS written and pushed.\n"
pwd
popd > /dev/null
