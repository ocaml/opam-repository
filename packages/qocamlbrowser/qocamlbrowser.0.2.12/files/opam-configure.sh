#!/bin/sh
set -x

OS=unknown
MAKE=make
if [ "$#" -ge 2 ]; then
  OS=$1
  MAKE=$2
else
  echo "Usage: $0 OS make [OS-family] [OS-distrubution]" >&2
  exit 1
fi

if [ "$OS" = "macos"]; then
  export PATH=/usr/lib64/qt5/bin:/usr/lib/qt5/bin:$PATH
  ./configure  || exit 1
  $MAKE  || exit 1
else
  # a few GNU/Linux put executables there
  export PATH=/usr/local/opt/qt/bin:$PATH
  ./configure || exit 1
  $MAKE || exit 1
fi

exit 0
