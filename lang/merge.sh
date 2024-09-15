#!/usr/bin/env bash
# Merge mod translation and vanilla translation to one file for distribution

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
    fail 0 "Not merging translation files because 'gettext' is not installed"
fi

pk3name=zzz-smb-l10n
dst=compiled/${pk3name}.pk3dir

if [ ! -d "$dst" ]; then
    mkdir -vp $dst
fi
if [ -d "$dst" ] && [ "$(ls -A $dst)" ]; then
    rm -v $dst/*
fi

echo "Merging localization files to $dst"
for i in $(ls lang); do
    if [ -f lang/$i ] && [ -f $base/$i ] && [[ "$i" != "common.pot" ]]; then
        msgcat --to-code UTF-8 $base/$i lang/$i > $dst/$i
    fi
done

if [ ! -n "${ZIP:-}" ]; then
    if [ -e "compiled/${pk3name}.*.pk3" ]; then
        rm -v compiled/${pk3name}.*.pk3
    fi
    # unique id for different versions of localization
    sha256=$(cat compiled/${pk3name}.pk3dir/* | sha256sum)
    pk3path=compiled/$pk3name.${sha256:0:8}.pk3
    echo "Making localization package $pk3path"
    echo "localization package for smb server" >$dst/${pk3name}.pk3.serverpackage
    zip -9 -j $pk3path $dst/*
fi

cd $cwd
