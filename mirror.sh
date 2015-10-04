#!/bin/sh
declare SYNCDIR=xonotic
declare SYNCREMOTE=git@github.com:MarioSMB/modpack.git
declare SYNCBRANCH=xonotic-data.pk3dir/master

set -eu
if [ "$#" -ne 1 ]; then
    echo "Usage: ${0} /path/to/xonotic-data.pk3dir"
    exit 1
fi

pushd ${1} > /dev/null
    declare qcsrc=${PWD}/qcsrc
popd > /dev/null

cd ${0%[\\/]*}

if [ ! -d "${SYNCDIR}" ]; then
    mkdir "${SYNCDIR}" && pushd "${SYNCDIR}" > /dev/null
        git init
        git remote add origin "${SYNCREMOTE}"
        git fetch
        git checkout -b "${SYNCBRANCH}"
    popd > /dev/null
fi

pushd "${SYNCDIR}" > /dev/null
    git rm -rf . > /dev/null 2> /dev/null || true
    git clean -xdf
popd > /dev/null

function copy {
    local src="${1}"
    local dst="${PWD}/${SYNCDIR}/${2}"
    mkdir -p "$(dirname "${dst}")"
    pushd $(dirname ${src}) > /dev/null
        git show "HEAD:./$(basename ${src})" > "${dst}"
    popd > /dev/null
}

pushd "${qcsrc}" > /dev/null
    declare FILES=$(git ls-tree --name-only -r HEAD)
popd > /dev/null

for f in ${FILES}; do copy "${qcsrc}/${f}" "${f}"; done

declare lastsyncmsg=$(cd ${SYNCDIR}; git log --format=%B -n 1 HEAD | head -n 1)
pushd "${qcsrc}" > /dev/null
    declare rev=$(git describe)
    declare lastrev=$(git rev-parse ${lastsyncmsg})
    declare range=${lastrev}..HEAD
    if [ -z "$lastrev" ]; then
        declare range=
    fi
    declare changes="$(git log --format=%B --reverse ${range})"
popd > /dev/null

declare NL='
'
declare msg="Sync with ${rev}${NL}${NL}${changes}"
pushd "${SYNCDIR}" > /dev/null
    git add .
    echo "${msg}" | git commit --file -
    git tag ${rev} -m "${rev}"
    git push --follow-tags -u origin "${SYNCBRANCH}"
popd > /dev/null
