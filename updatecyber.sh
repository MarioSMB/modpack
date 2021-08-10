#!/usr/bin/env bash
cd ${0%[\\/]*}
set -eu

git fetch --tags
if [ -z "${CI-}" ]; then
    git pull
fi

#Xonotic assets and gamecode:

declare xonDir='xonotic'
declare xonRepo='https://gitlab.com/xonotic/xonotic-data.pk3dir.git'
declare xonBranch='LegendaryGuard/cyber'

#git submodule update --init --depth 100
#git submodule add -b LegendaryGuard/cyber https://gitlab.com/xonotic/xonotic-data.pk3dir.git $(dirname "$0")/xonotic

if [ ! -d "$xonDir" ]; then
    git clone -b ${xonBranch} ${xonRepo} ${xonDir}
else
    pushd ${xonDir} && git pull
    popd
fi

#gmqcc (compiler):

declare qccDir='gmqcc'
declare qccRepo='https://gitlab.com/xonotic/gmqcc.git'
declare qccBranch='master'

#if [ -z "${CI-}" ]; then
#    wget -P .cache -c https://github.com/MarioSMB/csprogs/raw/master/csprogs-$(git describe --tags --dirty=*).pk3
#fi

if [ ! -d "$qccDir" ]; then
    git clone --depth=1 --branch=${qccBranch} ${qccRepo} ${qccDir}
else
    pushd ${qccDir} && git pull
    popd
fi

pushd ${qccDir} && make -j $(nproc)
popd
