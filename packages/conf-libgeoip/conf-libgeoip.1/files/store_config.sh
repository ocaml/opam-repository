#!/bin/sh -ex

cflags=$(pkg-config --cflags geoip)
echo "cflags: \"$cflags\"" > conf-libgeoip.config
