#!/bin/sh
cwd="`pwd`"
cd "`dirname $0`/.."

declare base=xonotic
if [ ! -d "$base" ]; then
    echo "RTFM (README.md)"
    cd $cwd
    exit 1
fi

git ls-files mod | sort -u | xgettext -LC -k_ -f- --from-code utf-8 -F -o common.pot.new >&2
# exclude vanilla strings
msgcomm xonotic/common.pot common.pot.new | msgcomm -u common.pot.new - >lang/common.pot
rm -f common.pot.new

cd $cwd
