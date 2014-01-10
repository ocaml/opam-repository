#!/bin/bash
LLVM_VERSION=$1

HERE=$(dirname "$0")
HERE=$(cd "$HERE" ; echo $PWD)
PACKAGE=$HERE/llvm-$LLVM_VERSION.tar.gz
TEMP=$(mktemp -d /tmp/llvm_XXXXXX)
LLVM_SRC_TAR=llvm-$LLVM_VERSION.src.tar.gz
CLANG_SRC_TAR=clang-$LLVM_VERSION.src.tar.gz
COMPILER_RT_SRC_TAR=compiler-rt-$LLVM_VERSION.src.tar.gz 
LLVM_SRC_LINK=http://llvm.org/releases/$LLVM_VERSION/$LLVM_SRC_TAR
CLANG_SRC_LINK=http://llvm.org/releases/$LLVM_VERSION/$CLANG_SRC_TAR
COMPILER_RT_SRC_LINK=http://llvm.org/releases/$LLVM_VERSION/$COMPILER_RT_SRC_TAR

LLVM_OBJECTS=/tmp/llvm-objects 
mkdir -p $TEMP/llvm-$LLVM_VERSION/tools/clang
mkdir -p $TEMP/llvm-$LLVM_VERSION/project/compiler-rt 

wget "$LLVM_SRC_LINK" -O - | tar --strip-components=1 -x -z -f - -C $TEMP/llvm-$LLVM_VERSION  || exit
wget "$CLANG_SRC_LINK" -O - | tar --strip-components=1 -x -z -f - -C $TEMP/llvm-$LLVM_VERSION/tools/clang || exit
wget "$COMPILER_RT_SRC_LINK" -O - | tar --strip-components=1 -x -z -f - -C $TEMP/llvm-$LLVM_VERSION/project/compiler-rt  || exit

cd $TEMP/ || exit
tar cfz $PACKAGE llvm-$LLVM_VERSION || exit
rm -rf $TEMP
echo $PACKAGE created
