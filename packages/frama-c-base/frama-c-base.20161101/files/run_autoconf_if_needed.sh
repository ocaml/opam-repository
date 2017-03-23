#!/bin/sh -eux

if [ ! -f "configure" ]; then
  autoconf
fi
