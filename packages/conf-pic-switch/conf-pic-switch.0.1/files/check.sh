#!/bin/bash

opam_root=`opam config var root`
ocaml_version=`opam config var ocaml-version`
pic_comp_switch=$opam_root'/'$ocaml_version'+PIC'

test -d $pic_comp_switch || \
(echo "the "$pic_comp_switch" opam compiler switch is not installed" && exit 1)
