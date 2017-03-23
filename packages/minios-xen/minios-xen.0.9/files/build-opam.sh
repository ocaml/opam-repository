#!/bin/sh -ex

# The MiniOS build is sensitive to some external variables
# like EXTRA_DEPS being set, even to blank values.
# See: https://github.com/mirage/mirage-xen-minios/issues/15
# This wrapper script explicitly unexports them from the
# environment before invoking Make

unset EXTRA_DEPS

make debug=n CONFIG_VERBOSE_BOOT=n
