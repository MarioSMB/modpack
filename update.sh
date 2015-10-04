#!/usr/bin/env bash
cd ${0%[\\/]*}
set -eu
declare repository='git@github.com:MarioSMB/modpack.git'
declare defaultbranch='xonotic-data.pk3dir/master'
declare base='xonotic'

git pull
if [ ! -d "$base" ]; then
    git clone ${repository} -b ${defaultbranch} ${base}
else
    cd ${base} && git pull
fi
