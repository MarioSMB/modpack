#!/bin/sh
cd ${0%[\\/]*}

if [ ! -d "github" ]; then
    mkdir github
    pushd github
    git init
    git remote add origin git@github.com:MarioSMB/modpack.git
    git fetch
    git checkout -b master
    popd
fi

cat << EOF > github/.gitignore
.DS_Store
EOF

cp README.md github

rsync -Pha --delete \
    --exclude 'github' --exclude 'sync.sh' --exclude '.git' --exclude '.gitignore' \
    ../mod ../qcsrc \
    github

REV=$(git describe)

pushd github
git add .
git commit -m "Sync with ${REV}"
git push -u origin master
popd
