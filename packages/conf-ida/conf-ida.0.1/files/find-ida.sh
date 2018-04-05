#!/bin/sh

# find IDA PRO on a system
#
# Find IDA Pro and provide a path to its folder as a witness. The path
# is specifiend via a package variable `path`, and can be accessed
# with `opam config var conf-ida:path` command. This script also
# determines whether the environment is headless, and report it via
# `headless` variable. All variables are stored in `find-ida.config` file,
# that is installed by opam.

# The script respects IDA_PATH environment variable, if it is set,
# then nothing is searched and its value is blindly propagated to the
# package variable.

# The general approach is first try to find idaq64 executable in the
# PATH and then fallback to a slower solution, like locate or
# find. The slower solution make take some time especially on systems
# with many files but no IDA.

# IFS=$'\n' doesn't work on dash, although it is posix
IFS="
"

# fast and portable solution
find_command() {
    command=`which $1`

    if [ "$command" ]; then
        IDA_PATH=`dirname ${command}`
    fi
}

# can be very slow
locate_linux() {
    results=`locate -w -r 'idaq64$' | sort -n -r`

    for path in $results; do
        if [ -x $path ]; then
            IDA_PATH=`dirname ${path}`
            return
        fi
    done
}

# locate on mac os x doesn't accept -r and -w flags,
# moreover, we have a better alternative - mfind
locate_macos() {
    results=`mdfind -name idaq | sort -n -r`

    for path in $results; do
        echo "$path"
        app=`basename "${path}"`

        if [ "x$app" = "xidaq.app" ]; then
            IDA_PATH="${path}/Contents/MacOS/"
            return
        fi
    done
}


find() {
    if [ -z $IDA_PATH ]; then
        find_command "idaq64"
    fi
}

HEADLESS=false

case $1 in
    linux)
        find
        [ $IDA_PATH ] || locate_linux
        if [ -z $DISPLAY ]; then
            HEADLESS=true
        fi
        ;;
    darwin)
        find
        [ $IDA_PATH ] || locate_macos
        ;;
    *)
        echo "warning: we don't know how to find programs on $1"
    ;;
esac

if [ -z $IDA_PATH ]; then
    echo "warning: failed to locate IDA Pro"
    IDA_PATH="undefined"
fi

cat > conf-ida.config <<EOF
path: "$IDA_PATH"
headless: $HEADLESS
EOF
