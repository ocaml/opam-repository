#!/bin/sh -ex

echo "bin: ["                                  > sibylfs-lem.install
echo "  \"src/main.native\" {\"lem\"}"        >> sibylfs-lem.install
printf "]\nlib: [\n"                          >> sibylfs-lem.install

ls -1 library/*.* hol-lib/*.* isabelle-lib/*.* coq-lib/*.* ocaml-lib/*.* \
| sed -e "s/\\(.*\\)/  \"\1\" \{ \"\1\" \}/"  >> sibylfs-lem.install
echo "]"                                      >> sibylfs-lem.install
