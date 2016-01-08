#!/usr/bin/env bash
cd ${0%[\\/]*}
set -eu

git submodule update --init --depth 100

declare qccDir='gmqcc'
declare qccRepo='https://gitlab.com/xonotic/gmqcc.git'
declare qccBranch='master'

git pull --tags

if [ -z "${CI-}" ]; then
    wget -P .cache https://github.com/MarioSMB/csprogs/raw/master/csprogs-$(git describe --tags --dirty=*).pk3
fi

if [ ! -d "$qccDir" ]; then
    git clone --depth=1 --branch=${qccBranch} ${qccRepo} ${qccDir}
else
    pushd ${qccDir} && git pull
    popd
fi

pushd ${qccDir} && make -j $(nproc)
popd
