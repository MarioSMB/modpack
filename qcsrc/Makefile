SCM := $(shell if [ -d .svn ]; then echo svn; elif [ -d ../.git ]; then echo git; fi)
PERL ?= perl
QCCFLAGS_WATERMARK ?= -DWATERMARK='"$(shell git describe)"' -DCVAR_POPCON=1
QCC ?= gmqcc

VERSION_MESSAGE = $(shell cd server && $(QCC) --version --help)
ifneq (,$(findstring GMQCC,$(VERSION_MESSAGE)))
# this is gmqcc
QCCFLAGS ?= \
	-std=fteqcc \
	-Werror -Wall \
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
else
# this. is. fteqccccccccccccccccccc!
QCCFLAGS ?= -Werror -Wno-Q302 -O3 -Ono-return_only -fno-fastarrays $(QCCFLAGS_EXTRA) $(QCCFLAGS_WATERMARK)
endif

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
	rm -f ../progs.dat ../menu.dat ../csprogs.dat

FILES_CSPROGS = $(shell find client common warpzonelib csqcmodellib -type f -not -name fteqcc.log -not -name qc.asm) $(wildcard server/w_*.qc)
../csprogs.dat: $(FILES_CSPROGS)
	@echo make[1]: Entering directory \`$(PWD)/client\'
	cd client && $(QCC) $(QCCFLAGS)

FILES_PROGS = $(shell find server common warpzonelib csqcmodellib -type f -not -name fteqcc.log -not -name qc.asm) $(wildcard server/w_*.qc)
../progs.dat: $(FILES_PROGS)
	@echo make[1]: Entering directory \`$(PWD)/server\'
	cd server && $(QCC) $(QCCFLAGS)

FILES_MENU = $(shell find menu common warpzonelib -type f -not -name fteqcc.log -not -name qc.asm) $(wildcard server/w_*.qc)
../menu.dat: $(FILES_MENU)
	@echo make[1]: Entering directory \`$(PWD)/menu\'
	cd menu && $(QCC) $(QCCFLAGS)

.PHONY: testcase
testcase:
	cd testcase && $(QCC) $(QCCFLAGS) -DTESTCASE="$$TESTCASE"
