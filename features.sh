#!/usr/bin/env bash
cd ${0%[\\/]*}
set -eu

F=$(find . \( -iname "*.qc" -o -iname "*.qh" \) -exec grep -R "//FEATURE:" {} \; | awk -F "//FEATURE: " '{ print "* " $2 }')
echo -e "## Features\n\n${F}" > FEATURES.md
