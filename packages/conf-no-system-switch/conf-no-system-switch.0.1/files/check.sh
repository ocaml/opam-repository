#!/bin/bash

opam_switch=`opam config var switch`

test $opam_switch != "system" || exit 1

