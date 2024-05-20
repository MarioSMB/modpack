#!/usr/bin/env bash
cwd="`pwd`"
cd "`dirname $0`/.."

base=xonotic
if [ ! -d "$base" ]; then
    echo "RTFM (README.md)"
    cd $cwd
    exit 1
fi

current_branch=$(git branch | awk '/^\*/ { print $2 }')
# gather new strings from all branches
branches=$(git branch --list -a | awk '/^\*/ { next } /remotes\/origin\/HEAD/ { next } /^  remotes\/origin\// { print substr($1, length("remotes/origin/") + 1, length($1)) }')
for i in $branches; do
    git checkout $i || { echo "Can't checkout to $i"; rm -f common.pot.new*; exit 1; }
    git ls-files mod | sort -u | xgettext -LC -k_ -f- --from-code utf-8 -F -o common.pot.new-`basename $i` >&2
done
git checkout "$current_branch"
msgcat common.pot.new-* >common.pot.new
# exclude vanilla strings
msgcomm xonotic/common.pot common.pot.new | msgcomm -u common.pot.new - >lang/common.pot
if [ ! $SMB_KEEP_POT ]; then
    rm -f common.pot.new*
fi

echo "Complete."

cd $cwd
