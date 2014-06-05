#!/bin/sh

if [ "$#" -lt 3 ]; then
	echo "Usage: $0 'float test() { if(fail) return 0; else if(good) return 1; else return -1; }' ./darkplaces-dedicated basement +sv_cheats 1"
	exit 125
fi

case "$0" in
	*/*)
		dir=${0%/*}
		;;
	*)
		dir=`pwd`
		;;
esac
testcase=$1; shift
engine=$1; shift
map=$1; shift
echo "$testcase" > "$dir/testcase.qc"
if ( cd $dir && fteqcc ); then
	set -- "$engine" -xonotic -basedir "$dir/../../.." +sv_progs progs-testcase.dat "$@" +map "$map"
	if [ -n "$GDB_ME" ]; then
		cmdfile=`mktemp`
		{
			echo "break VM_dprint"
			echo "run"
			echo "delete 1"
			echo "finish"
		} > "$cmdfile"
		gdb -x "$cmdfile" --args "$@"
		rm -f "$cmdfile"
		exit 0
	else
		r=`"$@" | tee /dev/stderr`
	fi
	case "$r" in
		*"TESTCASE: PASS"*)
			echo "PASS detected"
			exit 0
			;;
		*"TESTCASE: FAIL"*)
			echo "FAIL detected"
			exit 1
			;;
		*"TESTCASE: INVALID"*)
			echo "INVALID detected"
			exit 125
			;;
		*)
			echo "Running failed"
			exit 125
			;;
	esac
else
	echo "Compilation failed"
	exit 125
fi
