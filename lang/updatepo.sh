#!/usr/bin/env bash
# update existing translation files to include new strings
# for those who need to translate offline by editing plain .po files

cwd="`pwd`"
cd "`dirname $0`/.."

for i in $(ls lang); do
    if [[ "${i%.po}" != "$i" ]] && [[ "$i" != "common.pot" ]]; then
        msgcat lang/common.pot lang/$i >lang/$i.new && mv lang/$i.new lang/$i
    fi
done

cd $cwd
