#!/bin/sh

# Create a bap.cfg file for use in bap-ida-python based upon path to BAP
# passed to it as input as first argument

cat > bap.cfg <<EOF
.default
bap_executable_path	$1
EOF
