#!/bin/sh

# portmidi doesn't have an entry on my ubuntu pkg-config so fall back to
# probing for the header file

pkg-config --exists portmidi \
  || pkg-config --exists libportmidi \
  || ls /usr/include/portmidi.h
