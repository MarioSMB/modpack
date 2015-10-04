#!/bin/sh
cd ${0%[\\/]*}

SYNCDIR=github
SYNCREMOTE=git@github.com:MarioSMB/modpack.git
SYNCBRANCH=master

if [ ! -d "${SYNCDIR}" ]; then
    mkdir "${SYNCDIR}"
    pushd "${SYNCDIR}" > /dev/null
    git init
    git remote add origin "${SYNCREMOTE}"
    git fetch
    git checkout -b "${SYNCBRANCH}"
    popd > /dev/null
fi

function copy {
    src="${1}"
    dst="${SYNCDIR}/${2}"
    mkdir -p "$(dirname "${dst}")"
    git show "HEAD:./${src}" > "${dst}"
}

function prune {
    rm "${SYNCDIR}/${1}"
}

RELROOT=../..

pushd "${RELROOT}" > /dev/null
FILES=$(git ls-tree --name-only -r HEAD | egrep '^(qcsrc)/')
popd > /dev/null

pushd "${SYNCDIR}" > /dev/null
git rm -rf . > /dev/null
git clean -xdf
popd > /dev/null

for f in ${FILES}; do copy "${RELROOT}/${f}" "${f}"; done

prune "qcsrc/mod/sync.sh"
prune "qcsrc/mod/.gitignore"
prune "qcsrc/mod/.gitattributes"
prune "qcsrc/mod/README.md"
copy "${RELROOT}/.gitignore" ".gitignore"
copy "README.md" "README.md"
copy ".gitattributes" ".gitattributes"

REV=$(git describe)
LASTREV=$(git rev-parse "$(cd "${SYNCDIR}"; git log --format=%B -n 1 HEAD | head -n 1)")
CHANGES=$(git log --format=%B --reverse ${LASTREV}..HEAD)
NL='
'
MSG="Sync with ${REV}${NL}${NL}${CHANGES}"

pushd "${SYNCDIR}" > /dev/null
git add .
git commit -m "${MSG}"
git push -u origin "${SYNCBRANCH}"
popd > /dev/null
