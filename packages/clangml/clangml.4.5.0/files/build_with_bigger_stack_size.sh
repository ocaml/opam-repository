#!/bin/bash
hard_limit="$(ulimit -H -s)"
if [ "$hard_limit" == "unlimited" ]; then
    hard_limit=65536
fi
ulimit -S -s "$hard_limit"
exec "$@"
