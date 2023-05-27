#!/usr/bin/env bash
if [ -e $(dirname "$0")/compiled/csprogs.dat -o -e $(dirname "$0")/compiled/menu.dat -o -e $(dirname "$0")/compiled/progs.dat -o -e $(dirname "$0")/compiled/csprogs.lno -o -e $(dirname "$0")/compiled/menu.lno -o -e $(dirname "$0")/compiled/progs.lno -o -e $(dirname "$0")/compiled/*.pk3 -o -e $(dirname "$0")/csprogs.dat -o -e $(dirname "$0")/menu.dat -o -e $(dirname "$0")/progs.dat -o -e $(dirname "$0")/csprogs.lno -o -e $(dirname "$0")/menu.lno -o -e $(dirname "$0")/progs.lno ]; then
	tput bold; tput setaf 3; echo "There are compiled files here. The operation will proceed to delete the current compiled files in and out of the 'compiled' directory, replace and get new compiled ones (*.dat, *.lno, and *.pk3 files will be removed)."
	# deletes any remaining compiled files that weren't moved to 'compiled' directory
	tput bold; tput setaf 1

	rm -vf $(dirname "$0")/*.dat
	rm -vf $(dirname "$0")/*.lno
	rm -vf $(dirname "$0")/*.pk3

	rm -vf $(dirname "$0")/compiled/*.dat
	rm -vf $(dirname "$0")/compiled/*.lno
	rm -vf $(dirname "$0")/compiled/*.pk3

	tput sgr0
fi

cd ${0%[\\/]*}
set -eu

declare base=xonotic
if [ ! -d "$base" ]; then
    echo "RTFM (README.md)"
    exit 1
fi

: ${PROGS_OUT:=$PWD}
export PROGS_OUT

: ${QCC:=$PWD/gmqcc/gmqcc}
export QCC

export QCCFLAGS_WATERMARK=$(git describe --tags --dirty='~' --always)

relpath() {
    b=; s=$(cd $(readlink -f ${1%%/}); pwd); d=$(cd $2; pwd)
    while [ "${d#$s/}" == "${d}" ]; do s=$(dirname ${s}); b="../${b}"; done
    echo ${b}${d#${s}/}
}

export BUILD_MOD="$(relpath $base/qcsrc $PWD)"
export XONOTIC=0
export SPAWNFUNC_CHECK_FIELDS=0
make -C ${base}

tput bold; tput setaf 2; echo "Compiled successfully!"; tput sgr0
mkdir -vp $(dirname "$0")/compiled
mv -v *.lno $(dirname "$0")/compiled
mv -v *.dat $(dirname "$0")/compiled

#cp -v ./$base/qcsrc/csprogs-*.pk3 ./compiled

tput bold; tput setaf 3; echo "Now you can look at the compiled files inside $(dirname "$0")/compiled directory."
