#!/usr/bin/env bash
# update existing translation files to include new strings
# for those who need to translate offline by editing plain .po files

cwd="`pwd`"
cd "`dirname $0`/.."

for i in $(ls lang); do
    if [[ "${i%.po}" != "$i" ]] && [[ "$i" != "common.pot" ]]; then
        msgmerge -N -F -U lang/$i lang/common.pot
    fi
done

cd $cwd
