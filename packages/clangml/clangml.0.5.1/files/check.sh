#!/bin/bash

opam_root=`opam config var root`
ocaml_version=`echo 'Printf.printf "%s\n" Sys.ocaml_version' | ocaml /dev/stdin`
pic_comp_switch=$opam_root'/'$ocaml_version'+PIC'

test -d $pic_comp_switch || \
(echo "the "$pic_comp_switch" opam compiler switch is missing" && exit 1)
