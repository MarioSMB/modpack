#!/usr/bin/env bash
if [ -e $(dirname "$0")/result/csprogs.dat -o -e $(dirname "$0")/result/menu.dat -o -e $(dirname "$0")/result/progs.dat -o -e $(dirname "$0")/result/csprogs.lno -o -e $(dirname "$0")/result/menu.lno -o -e $(dirname "$0")/result/progs.lno -o -e $(dirname "$0")/csprogs.dat -o -e $(dirname "$0")/menu.dat -o -e $(dirname "$0")/progs.dat -o -e $(dirname "$0")/csprogs.lno -o -e $(dirname "$0")/menu.lno -o -e $(dirname "$0")/progs.lno ]; then
    read -r -p "There are compiled files here. The operation will delete the current compiled files in and out of the result directory, replace and get new compiled ones (*.dat, *.lno and *.pk3 files will be removed). Are you sure you want to continue?  [Y/n] " input
    case $input in
    	[yY][eE][sS]|[yY])
        # deletes any remaining compiled files that weren't moved to result directory
        tput bold; tput setaf 1
        rm -vf $(dirname "$0")/*.dat
        rm -vf $(dirname "$0")/*.lno
        rm -vf $(dirname "$0")/result/*.pk3  # deletes any *.pk3 file (in that case, csprogs-*.pk3)
        tput sgr0
    ;;
	[nN][oO]|[nN])
    tput bold; tput setaf 3; echo "Exiting..."
    exit 0
    ;;
    	*)
    tput bold; tput setaf 1; echo "Invalid input, exiting..."
    exit 1
    ;;
    esac
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

export QCCFLAGS_WATERMARK=$(git describe --tags --dirty='~')

relpath() {
    b=; s=$(cd $(readlink -f ${1%%/}); pwd); d=$(cd $2; pwd)
    while [ "${d#$s/}" == "${d}" ]; do s=$(dirname ${s}); b="../${b}"; done
    echo ${b}${d#${s}/}
}

export BUILD_MOD="$(relpath xonotic/qcsrc $PWD)"
export XONOTIC=1
make -C ${base}

tput bold; tput setaf 2; echo "Compiled successfully!"; tput sgr0
mkdir -vp $(dirname "$0")/result
mv -v $(dirname "$0")/xonotic/qcsrc/csprogs-*.pk3 $(dirname "$0")/result  # csprogs compiled and compressed as pk3 file for server, save it in .xonotic/data if you're running a server
mv -v *.lno $(dirname "$0")/result
mv -v *.dat $(dirname "$0")/result
tput bold; tput setaf 3; echo "Now you can look at the compiled files inside $(dirname "$0")/result directory."
