#!/bin/bash

opam_switch=`opam config var switch`

test $opam_switch = "system" && \
echo "opam system switch detected" && \
exit 1
