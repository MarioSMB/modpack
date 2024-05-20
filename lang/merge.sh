#!/usr/bin/env bash
cwd="`pwd`"
cd "`dirname $0`/.."

base=xonotic
if [ ! -d "$base" ]; then
    echo "RTFM (README.md)"
    cd $cwd
    exit 1
fi

pk3name=zzz-smb-l10n
dst=compiled/${pk3name}.pk3dir
mkdir -vp $dst
rm -v compiled/zzz-smb-l10n.pk3dir/*

echo "Merging localization files to $dst"
for i in $(ls lang); do
    if [ -f lang/$i ] && [ -f $base/$i ] && [[ "$i" != "common.pot" ]]; then
        msgcat --to-code UTF-8 $base/$i lang/$i > $dst/$i
    fi
done

if [ ! -n "${ZIP:-}" ]; then
    # unique id for different versions of localization
    sha256=$(cat compiled/zzz-smb-l10n.pk3dir/* | sha256sum)
    pk3path=compiled/$pk3name.${sha256:0:8}.pk3
    echo "Making localization package $pk3path"
    echo "localization package for smb server" >$dst/${pk3name}.pk3.serverpackage
    zip -9 -j $pk3path $dst/*
fi

cd $cwd
