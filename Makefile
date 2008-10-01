# Makefile for osh-current (20080914)
#
# @(#)$Id$
#
# Begin CONFIGURATION
#
# See the INSTALL file for build and install instructions.
#

#
# Choose where and how to install the binaries and manual pages.
#
DESTDIR?=
PREFIX?=	/usr/local
BINDIR?=	$(PREFIX)/bin
MANDIR?=	$(PREFIX)/man/man1
SYSCONFDIR?=	$(PREFIX)/etc
#BINGRP=		-g bin
BINMODE=	-m 0555
#MANGRP=		-g bin
MANMODE=	-m 0444

#
# Build utilities (SHELL must be POSIX-compliant)
#
INSTALL?=	/usr/bin/install
SHELL=		/bin/sh

#
# Preprocessor, compiler, and linker flags
#
#	If the compiler gives errors about any of flags specified
#	by `OPTIONS=' or `WARNINGS=' below, comment the appropriate
#	line(s) with a `#' character to fix the compiler errors.
#	Then, try to rebuild by doing a `make clean ; make'.
#
#CPPFLAGS=
OPTIONS=	-std=c99 -pedantic
WARNINGS=	-Wall -W
#CFLAGS+=	-g
CFLAGS+=	-O2 $(OPTIONS) $(WARNINGS)
#LDFLAGS+=	-static

#
# End CONFIGURATION
#
# !!! ================= Developer stuff below... ================= !!!

#
# Adjust CFLAGS and LDFLAGS for MOXARCH if needed.
#
MOXARCH?=
CFLAGS+=	$(MOXARCH)
LDFLAGS+=	$(MOXARCH)

#
# The following specifies the osh date and version:
#	osh-current (YYYYMMDD)	== development snapshot
#	osh-YYYYMMDD		== official release
#
OSH_DATE=	September 14, 2008
OSH_VERSION=	osh-current (20080914)

OSH=	osh
SH6=	sh6 glob6
UTILS=	if goto fd2
PEXSRC=	pexec.h pexec.c
SIGSRC=	sasignal.h sasignal.c
OBJ=	version.o pexec.o sasignal.o osh.o sh6.o glob6.o if.o goto.o fd2.o
MANSRC=	osh.1.in sh6.1.in glob6.1.in if.1.in goto.1.in fd2.1.in
MANDST=	osh.1 sh6.1 glob6.1 if.1 goto.1 fd2.1

DEFS=	-DOSH_VERSION='"$(OSH_VERSION)"' -DSYSCONFDIR='"$(SYSCONFDIR)"'

.c.o:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(DEFS) $<

#
# Build targets
#
all: oshall sh6all

oshall: $(OSH) utils man

sh6all: $(SH6) utils man

utils: $(UTILS)

osh: config.h rcsid.h version.c $(PEXSRC) $(SIGSRC) osh.c
	@$(MAKE) $@bin

sh6: config.h rcsid.h version.c $(PEXSRC) $(SIGSRC) sh6.c
	@$(MAKE) $@bin

glob6: config.h rcsid.h version.c $(PEXSRC) glob6.c
	@$(MAKE) $@bin

if: config.h rcsid.h version.c $(PEXSRC) if.c
	@$(MAKE) $@bin

goto: config.h rcsid.h version.c goto.c
	@$(MAKE) $@bin

fd2: config.h rcsid.h version.c $(PEXSRC) fd2.c
	@$(MAKE) $@bin

$(OBJ): config.h rcsid.h
pexec.o: $(PEXSRC)
sasignal.o: $(SIGSRC)
osh.o sh6.o glob6.o if.o fd2.o: pexec.h
osh.o sh6.o: sasignal.h

config.h: mkconfig
	$(SHELL) ./mkconfig

oshbin: version.o pexec.o sasignal.o osh.o
	$(CC) $(LDFLAGS) -o osh version.o osh.o pexec.o sasignal.o $(LIBS)

sh6bin: version.o pexec.o sasignal.o sh6.o
	$(CC) $(LDFLAGS) -o sh6 version.o sh6.o pexec.o sasignal.o $(LIBS)

glob6bin: version.o pexec.o glob6.o
	$(CC) $(LDFLAGS) -o glob6 version.o glob6.o pexec.o $(LIBS)

ifbin: version.o pexec.o if.o
	$(CC) $(LDFLAGS) -o if version.o if.o pexec.o $(LIBS)

gotobin: version.o goto.o
	$(CC) $(LDFLAGS) -o goto version.o goto.o $(LIBS)

fd2bin: version.o pexec.o fd2.o
	$(CC) $(LDFLAGS) -o fd2 version.o fd2.o pexec.o $(LIBS)

#
# Manual-page targets
#
man: $(MANDST)
$(MANDST): $(MANSRC)
	@for file in $(MANSRC) ; do \
		sed -e 's|@OSH_DATE@|$(OSH_DATE)|' \
			-e 's|@OSH_VERSION@|$(OSH_VERSION)|' \
				-e 's|@SYSCONFDIR@|$(SYSCONFDIR)|' \
					<$$file >$${file%.in} ; \
	done

#
# Install targets
#
install: install-oshall install-sh6all

install-oshall: oshall install-osh install-utils

install-sh6all: sh6all install-sh6 install-utils

install-osh: $(OSH) man install-dest
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) osh     $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) osh.1   $(DESTDIR)$(MANDIR)

install-sh6: $(SH6) man install-dest
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) sh6     $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) sh6.1   $(DESTDIR)$(MANDIR)
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) glob6   $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) glob6.1 $(DESTDIR)$(MANDIR)

install-utils: utils man install-dest
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) if      $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) if.1    $(DESTDIR)$(MANDIR)
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) goto    $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) goto.1  $(DESTDIR)$(MANDIR)
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) fd2     $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) fd2.1   $(DESTDIR)$(MANDIR)

install-dest:
	test -d $(DESTDIR)$(BINDIR) || { \
		umask 0022 ; mkdir -p $(DESTDIR)$(BINDIR) ; \
	}
	test -d $(DESTDIR)$(MANDIR) || { \
		umask 0022 ; mkdir -p $(DESTDIR)$(MANDIR) ; \
	}

#
# Cleanup targets
#
clean-obj:
	rm -f $(OBJ)

clean: clean-obj
	rm -f $(OSH) $(SH6) $(UTILS) $(MANDST) config.h
