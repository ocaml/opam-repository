#!/bin/sh

camlp4orf -v || (cat install && exit 1)
