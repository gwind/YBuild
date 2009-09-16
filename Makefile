VERSION=0.1
SCM=$(shell if test -d .svn; then echo svn; elif test -d .git; then echo git; fi)
DATE=$(shell date +%Y%m%d%H%M)
BUILD=build

ifeq ($(SCM),svn)
SVNVER=_SVN$(shell LANG=C svnversion .)
endif

prefix=/usr
bindir=$(prefix)/bin
datadir=$(prefix)/share
libdir=$(prefix)/lib
pkglibdir=$(libdir)/$(BUILD)
mandir=$(datadir)/man
man1dir=$(mandir)/man1
sysconfdir=/etc
DESTDIR=

all:

install:
	install -m755 -d \
	    $(DESTDIR)$(pkglibdir)/{configs,Build} \
	    $(DESTDIR)$(bindir) \
	    $(DESTDIR)$(man1dir)
	install -m755 \
	    build \
	    vc \
	    createrpmdeps \
	    order \
	    expanddeps \
	    computeblocklists \
	    extractbuild \
	    getbinaryid \
	    killchroot \
	    xen.conf \
	    getmacros \
	    getoptflags \
	    getchangetarget \
	    common_functions \
	    init_buildsystem \
	    initscript_qemu_vm \
	    substitutedeps \
	    debtransform \
	    mkbaselibs \
	    createrepomddeps \
	    createyastdeps \
	    changelog2spec \
	    spectool \
	    $(DESTDIR)$(pkglibdir)
	install -m644 Build/*.pm $(DESTDIR)$(pkglibdir)/Build
	install -m644 *.pm baselibs_global*.conf $(DESTDIR)$(pkglibdir)
	install -m644 configs/* $(DESTDIR)$(pkglibdir)/configs
	rm -f $(DESTDIR)$(pkglibdir)/configs/default.conf
	cp -a configs/default.conf $(DESTDIR)$(pkglibdir)/configs/default.conf
	install -m644 build.1 $(DESTDIR)$(man1dir)
	install -m755 unrpm $(DESTDIR)$(bindir)
	ln -sf $(pkglibdir)/build $(DESTDIR)$(bindir)/build
	ln -sf $(pkglibdir)/vc    $(DESTDIR)$(bindir)/buildvc

dist:
ifeq ($(SCM),svn)
	rm -rf $(BUILD)-$(VERSION)$(SVNVER)
	svn export . $(BUILD)-$(VERSION)$(SVNVER)
	tar --force-local -cjf $(BUILD)-$(VERSION)$(SVNVER).tar.bz2 $(BUILD)-$(VERSION)$(SVNVER)
	rm -rf $(BUILD)-$(VERSION)$(SVNVER)
else
ifeq ($(SCM),git)
	git archive --prefix=$(BUILD)-$(VERSION)_git$(DATE)/ HEAD| bzip2 > $(BUILD)-$(VERSION)_git$(DATE).tar.bz2
endif
endif
