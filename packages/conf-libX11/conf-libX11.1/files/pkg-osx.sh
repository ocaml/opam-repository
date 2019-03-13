#!/bin/sh

if [ -n "$PKG_CONFIG_PATH" ] ; then
  PKG_CONFIG_PATH=$PKG_CONFIG_PATH:
fi

PKG_CONFIG_PATH=$PKG_CONFIG_PATH/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig pkg-config x11
