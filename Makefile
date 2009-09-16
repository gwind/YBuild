VERSION=0.1
# SCM (Software Configuration Management)
# 就是软件版本控制意思（Version Control）
# 下面 shell 根据当前目录下是否有 .svn 或者 .git 目录设置 SCM 变量值
SCM=$(shell if test -d .svn; then echo svn; elif test -d .git; then echo git; fi)
DATE=$(shell date +%Y%m%d%H%M)
# 真的很讨厌把名字命名为 build ， 想想多少地方都用到这个词啊。
# 等我开始做大改变的时候，第一件事会是改变 build 名字
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
# DESTDIR 在很多 Makefile 文件中都有
# 指安装到的路径前缀，这样 make install 时可以临时定义
# 例如： make install DESTDIR=/tmp
DESTDIR=

all:

# 下面是安装：make install
# 都是脚本文件（shell或者perl），所以不需要编译
# 脚本文件权限为 755，配置文件为 644
# 注意：此 Makefile 没有 uninstall ，这是因为，通常我们用包管理安装卸载。
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

# 这里是打包 : make dist
# 我用 git 做版本控制
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
