#!/usr/bin/env bash
cd ${0%[\\/]*}
set -eu

git submodule update --init --depth 100

declare qccDir='gmqcc'
declare qccRepo='https://github.com/graphitemaster/gmqcc.git'
declare qccBranch='master'

git pull

if [ ! -d "$qccDir" ]; then
    git clone ${qccRepo} -b ${qccBranch} ${qccDir}
else
    pushd ${qccDir} && git pull
    popd
fi

pushd ${qccDir} && make
popd
