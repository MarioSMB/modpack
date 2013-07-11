SCM := $(shell if [ -d .svn ]; then echo svn; elif [ -d ../.git ]; then echo git; fi)
PERL ?= perl
QCCFLAGS_WATERMARK ?= -DWATERMARK='"$(shell git describe)"' -DCVAR_POPCON=1
QCC ?= gmqcc

QCCVERSIONFILE := qccversion.$(shell $(QCC) --version > qccversion.txt && git hash-object qccversion.txt)

QCCFLAGS ?= \
	-std=fteqcc \
	-Werror -Wall \
	-Wcpp \
	-Wno-field-redeclared \
	-Wno-double-declaration \
	-Wno-uninitialized-global \
	-O3 \
	-fadjust-vector-fields \
	-fftepp \
	-fftepp-predefs \
	-frelaxed-switch \
	-fshort-logic \
	-fno-perl-logic \
	-ftranslatable-strings \
	-fno-initialized-nonconstants \
	-fno-assign-function-types \
	-DSTUFFTO_ENABLED \
	-flno \
	-fcorrect-ternary \
	-fno-single-vector-defs \
	-fcorrect-logic \
	-ftrue-empty-strings \
	-fno-false-empty-strings \
	-futf8 \
	-fno-bail-on-werror \
	-floop-labels \
	-funtyped-nil \
	-fno-permissive \
	-fvariadic-args \
	$(QCCFLAGS_EXTRA) $(QCCFLAGS_WATERMARK)

# xonotic build system overrides this by command line argument to turn off the update-cvarcount step
XON_BUILDSYSTEM =

all: qc

.PHONY: qc
qc:
	$(MAKE) qc-recursive

.PHONY: qc-recursive
qc-recursive: ../menu.dat ../progs.dat ../csprogs.dat

.PHONY: clean
clean:
	rm -f ../progs.dat ../menu.dat ../csprogs.dat server/precache-for-csqc.inc

$(QCCVERSIONFILE):
	$(RM) qccversion.*
	echo This file intentionally left blank. > $@

FILES_CSPROGS = $(shell find client common warpzonelib csqcmodellib -type f -not -name fteqcc.log -not -name qc.asm) $(wildcard server/w_*.qc)
../csprogs.dat: $(FILES_CSPROGS) $(QCCVERSIONFILE)
	@echo make[1]: Entering directory \`$(PWD)/client\'
	cd client && $(QCC) $(QCCFLAGS)

server/precache-for-csqc.inc: $(FILES_CSPROGS)
	sh collect-precache.sh

FILES_PROGS = $(shell find server common warpzonelib csqcmodellib -type f -not -name fteqcc.log -not -name qc.asm) $(wildcard server/w_*.qc)
../progs.dat: $(FILES_PROGS) $(QCCVERSIONFILE) server/precache-for-csqc.inc
	@echo make[1]: Entering directory \`$(PWD)/server\'
	cd server && $(QCC) $(QCCFLAGS)

FILES_MENU = $(shell find menu common warpzonelib -type f -not -name fteqcc.log -not -name qc.asm) $(wildcard server/w_*.qc)
../menu.dat: $(FILES_MENU) $(QCCVERSIONFILE)
	@echo make[1]: Entering directory \`$(PWD)/menu\'
	cd menu && $(QCC) $(QCCFLAGS)

.PHONY: testcase
testcase:
	cd testcase && $(QCC) $(QCCFLAGS) -DTESTCASE="$$TESTCASE"
