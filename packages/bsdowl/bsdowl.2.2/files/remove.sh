# Usage: remove PREFIX
#  Remove BSD OWl
find "$1/share/mk" -type f \
    | xargs grep -l 'This file is part of BSD Owl Scripts' \
    | xargs rm -v -f
