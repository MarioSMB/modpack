SCM := $(shell if [ -d .svn ]; then echo svn; elif [ -d ../.git ]; then echo git; fi)
PERL ?= perl
QCCFLAGS_WATERMARK ?= -DWATERMARK='"$(shell git describe)"'
QCC ?= gmqcc

QCCVERSIONFILE := qccversion.$(shell (cd server && $(QCC) --version) > qccversion.txt && git hash-object qccversion.txt)

# We eventually need to get rid of these.
QCCFLAGS_WTFS ?= \
	-Wno-field-redeclared \
	-Wno-double-declaration \

QCCFLAGS ?= \
	-std=gmqcc \
	-O3 -flno \
	-DSTUFFTO_ENABLED \
	-Werror -fno-bail-on-werror -Wall \
	-fftepp -fftepp-predefs -Wcpp -futf8 \
	$(QCCFLAGS_WTFS) \
	$(QCCFLAGS_EXTRA) $(QCCFLAGS_WATERMARK)

# xonotic build system overrides this by command line argument to turn off the update-cvarcount step
XON_BUILDSYSTEM =

all: qc
.PHONY: all

.PHONY: qc
qc: ../progs.dat ../csprogs.dat

.PHONY: clean
clean:
	rm -f ../progs.dat ../csprogs.dat server/precache-for-csqc.inc

$(QCCVERSIONFILE):
	$(RM) qccversion.*
	echo This file intentionally left blank. > $@

FILES_CSPROGS = $(shell find client common warpzonelib csqcmodellib -type f -not -name fteqcc.log -not -name qc.asm)
../csprogs.dat: $(FILES_CSPROGS) $(QCCVERSIONFILE)
	@echo make[1]: Entering directory \`$(PWD)/client\'
	cd client && $(QCC) $(QCCFLAGS)

server/precache-for-csqc.inc: $(FILES_CSPROGS)
	sh collect-precache.sh

FILES_PROGS = $(shell find server common warpzonelib csqcmodellib -type f -not -name fteqcc.log -not -name qc.asm)
../progs.dat: $(FILES_PROGS) $(QCCVERSIONFILE) server/precache-for-csqc.inc
	@echo make[1]: Entering directory \`$(PWD)/server\'
	cd server && $(QCC) $(QCCFLAGS)

.PHONY: testcase
testcase:
	cd testcase && $(QCC) $(QCCFLAGS) -DTESTCASE="$$TESTCASE"
