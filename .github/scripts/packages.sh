#!/bin/sh

set -e

PACKAGES=`git diff --name-only origin/master..HEAD | grep '^packages' | cut -d'/' -f 3 | while read i; do echo "\"$i\""; done`

echo "Packages to test: [$PACKAGES]"
echo "##[set-output name=packages][${PACKAGES}]"

