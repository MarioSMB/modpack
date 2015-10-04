#!/usr/bin/env bash
cd ${0%[\\/]*}
set -eu
declare repository="$(git config --get remote.origin.url)"
declare defaultbranch='xonotic-data.pk3dir/master'
declare base='xonotic'

declare qccDir='gmqcc'
declare qccRepo='https://github.com/graphitemaster/gmqcc.git'
declare qccBranch='master'

git pull

if [ ! -d "$base" ]; then
    git clone ${repository} -b ${defaultbranch} ${base}
else
    cd ${base} && git pull
fi

if [ ! -d "$qccDir" ]; then
    git clone ${qccRepo} -b ${qccBranch} ${qccDir}
    cd ${qccDir}
else
    cd ${qccDir} && git pull
fi
make
