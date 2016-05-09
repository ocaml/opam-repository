#!/bin/sh

# check that objdump is installed, if several objdumps are installed
# then collect all possible objdump targets, where a target of an
# objdump is defined syntactically <target>-objdump.
# all found targets are written into config file in OCaml list syntax
# Note: we specifically remove "llvm-objdump" as it is not a part of
# binutils.

TARGETS=
FOUND=
OBJDUMPS=

check_objdump() {
    [ `which objdump` ] && FOUND=1
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
                if [ -z $TARGETS ]; then
                    TARGETS="\\\"${pref}\\\""
                else
                    TARGETS="\\\"${pref}\\\"; $TARGETS"
                fi
            fi
        fi
    done

    if [ -z $FOUND ]; then
        exit 1
    fi
}


if   [ "is_$1" = "is_linux" ]; then
    OBJDUMPS=`locate -r 'objdump$'`
elif [ "is_$1" = "is_darwin" ]; then
    OBJDUMPS=`mdfind -name objdump`
else
    echo "unsupported OS"
    exit 1
fi

check_objdump
collect_targets

if [ -z $FOUND ]; then
    echo "Failed to find objdump executable(s)"
    exit 1
fi


cat > conf-binutils.config <<EOF
targets: "[${TARGETS}]"
EOF
