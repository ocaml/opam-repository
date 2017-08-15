#!/bin/sh

# check that objdump is installed, if several objdumps are installed
# then collect all possible objdump targets, where a target of an
# objdump is defined syntactically <target>-objdump.
# all found targets are written into config file in OCaml list syntax
# Note: we specifically remove "llvm-objdump" as it is not a part of
# binutils.

TARGETS=
FOUND=
OBJDUMP=
CXXFILT=
OBJDUMPS=

check_objdump() {
    [ -n "$OBJDUMP" ] && FOUND=1
}


add_target() {
    if [ -z "$TARGETS" ]; then
        TARGETS="\\\"${1}\\\""
    else
        TARGETS="\\\"${1}\\\"; $TARGETS"
    fi
}


collect_targets() {
    IFS="
"
   for path in $OBJDUMPS; do
        file=`basename "${path}"`
        pref=${file%-objdump}
        if [ $pref -a -f $path -a -x $path -a "x${pref}" != "xllvm" -a "x${pref}" != "xobjdump" ]; then
            if [ `which ${file}`  ]; then
                FOUND=1
                add_target $pref
            fi
        fi
    done
}


if   [ "is_$1" = "is_linux" ]; then
    OBJDUMP=`which objdump`
    CXXFILT=`which c++filt`
    OBJDUMPS=`locate -r 'objdump$'`
elif [ "is_$1" = "is_darwin" ]; then
    OBJDUMP=`which gobjdump`
    CXXFILT=`which c++filt`
    OBJDUMPS=`mdfind -name objdump`
else
    echo "unsupported OS"
    exit 1
fi

check_objdump
collect_targets

if [ -z "$FOUND" ]; then
    echo "Failed to find objdump executable(s)"
    exit 1
fi




cat > conf-binutils.config <<EOF
cxxfilt: "${CXXFILT}"
objdump: "${OBJDUMP}"
targets: "[${TARGETS}]"
EOF
