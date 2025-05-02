#!/usr/bin/env bash
# Generate .pot (translation template) from strings in source code

cwd="`pwd`"
cd "`dirname $0`/.."
base=xonotic

fail() {
    echo $2
    cd $cwd
    exit $1
}

if [ ! -d "$base" ]; then
    fail 1 "Not proceeding because xonotic data is missing. See 'README.md'"
fi
if ! msgcat --version >>/dev/null; then
    fail 0 "Not generating translation files because 'gettext' is not installed"
fi

current_branch=$(git branch | awk '/^\*/ { print $2 }')
# gather new strings from all branches
branches=$(git branch --list -a | awk '/^\*/ { next } /remotes\/origin\/HEAD/ { next } /^  remotes\/origin\// { print substr($1, length("remotes/origin/") + 1, length($1)) }')
for i in $branches; do
    git checkout $i || { echo "Can't checkout to $i"; rm -f common.pot.new*; exit 1; }
    git ls-files mod | sort -u | grep -E '.qc$|.qh$' | xgettext -LC -k_ -f- --from-code UTF-8 -F -o - | sed 's/charset=CHARSET/charset=UTF-8/' >common.pot.new-`basename $i`
done
git checkout "$current_branch"
msgcat --to-code UTF-8 common.pot.new-* >common.pot.new
# exclude vanilla strings
msgcomm xonotic/common.pot common.pot.new | msgcomm -u common.pot.new - >lang/common.pot
if [ ! $SMB_KEEP_POT ]; then
    rm -f common.pot.new*
fi

echo "Translation files generated."
cd $cwd
