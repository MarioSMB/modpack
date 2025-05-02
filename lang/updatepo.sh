#!/usr/bin/env bash
# Execute this to update your translated .po files, to include new strings in common.pot
# Helpful for those who translate by editing .po files
# Code maintainers don't have to run this, Transifed handles updates well

cwd="`pwd`"
cd "`dirname $0`"

if ! msgcat --version >>/dev/null; then
    echo "Please install 'gettext' to run this script"
    cd $cwd
    exit 1
fi

for i in $(ls); do
    if [[ "${i%.po}" != "$i" ]] && [[ "$i" != "common.pot" ]]; then
        msgmerge -N -F -U --backup=none $i common.pot
    fi
done

cd $cwd
