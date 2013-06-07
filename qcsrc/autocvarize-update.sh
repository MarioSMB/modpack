#!/bin/sh
set -ex
git checkout divVerent/autocvarizer_test
trap 'git reset --hard; git checkout divVerent/autocvarizer' EXIT
trap 'exit 1' INT
git merge --no-commit -s ours divVerent/autocvarizer
git read-tree -m -u divVerent/autocvarizer # "theirs"
find server \( -type f -a \( -name \*.c -o -name \*.qc -o -name \*.h -o -name \*.qh \) \) -print0 | AUTOCVARING_SVQC=1 xargs -0 perl autocvarize.pl > server/autocvars.qh.new
diff -Nu server/autocvars.qh server/autocvars.qh.new || true
mv server/autocvars.qh.new server/autocvars.qh
find client \( -type f -a \( -name \*.c -o -name \*.qc -o -name \*.h -o -name \*.qh \) \) -print0 | xargs -0 perl autocvarize.pl > client/autocvars.qh.new
diff -Nu client/autocvars.qh client/autocvars.qh.new || true
mv client/autocvars.qh.new client/autocvars.qh
if make -C .. FTEQCC=../../../../fteqcc/fteqcc.bin FTEQCCFLAGS=; then
	echo "Commit? ^C to not"
	read -r L
	git add server/autocvars.qh
	git add client/autocvars.qh
	git commit -a
else
	echo "FAILED. Exit this shell when done examining."
	sh -i
fi
