# Usage: remove PREFIX
#  Remove BSD Owl Scripts
find "$1/share/bsdowl" "$1/bin" -type f \
    | xargs grep -l 'This file is part of BSD Owl Scripts' \
    | xargs rm -v -f
