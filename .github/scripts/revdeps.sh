#!/bin/sh

set -e

PACKAGE=$1

REVDEPS=`(opam --cli=2.1 list -s --color=never --depends-on "${PACKAGE}" --coinstallable-with "${PACKAGE}" --installable --all-versions --recursive --depopts && opam --cli=2.1 list -s --color=never --depends-on "${PACKAGE}" --coinstallable-with "${PACKAGE}" --installable --all-versions --with-test --depopts) | sort -u | grep -v "${PACKAGE}" | while read i; do echo "\"$i\""; done | paste -sd ',' -`

echo "${PACKAGE} revdeps: [${REVDEPS}]"
echo "revdeps=[${REVDEPS}]" >> "${GITHUB_OUTPUT}"

