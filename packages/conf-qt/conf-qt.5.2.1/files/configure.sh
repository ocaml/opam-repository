#!/bin/sh
set -x

MINVERSION=unknown
if [ "$#" -eq 2 ]; then
  MINVERSION=$1
  SUFFIX=$2
elif [ "$#" -eq 1 ]; then
  MINVERSION=$1
  SUFFIX=
else
  echo "Usage: $0 version [prefix]" >&2
  exit 1
fi

QMAKE=qmake$SUFFIX

which $QMAKE || exit 1
$QMAKE --version || exit 1
#echo "Your Qt version is `qmake -query QT_VERSION`"

cur=`$QMAKE -query QT_VERSION`;
res=`printf "$MINVERSION\\n$cur\\n" | sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -n | head -n 1`;
echo $res
if [ "$res" = "$MINVERSION" ]; then
  exit 0
else
  exit 1
fi
