PREFIX=/usr
EPREFIX=${PREFIX}
SBINDIR=${PREFIX}/sbin
BINDIR=${PREFIX}/bin
DATADIR=${PREFIX}/share
LIBEXECDIR=${EPREFIX}/lib/bee
SYSCONFDIR=/etc

BEEDIR=${SYSCONFDIR}/xdg/bee

TEMPLATEDIR=${BEEDIR}/templates
MAGICDIR=${BEEDIR}/beesh.d

DESTDIR=

SHELLS=bee beesh
TOOLS=bee-init bee-check bee-remove bee-install bee-list bee-query
PERLS=beefind.pl
PROGRAMS=beeversion beesep beecut

TEMPLATES=fallback
MAGIX=configure cmake perl-module perl-module-makemaker make python-module 
CONFIGS=skiplist beerc
BEELIB=beelib.config


.SUFFIXES: .in .sh .sh.in

all: build

build: shells perls programs

perls: $(PERLS)

programs: $(PROGRAMS)

shells: $(addsuffix .sh,$(SHELLS) $(TOOLS) $(BEELIB))

beesep: src/beesep/beesep.c
	gcc -Wall -o $@ $^

beeversion: src/beeversion/beeversion.c
	gcc -Wall -o $@ $^

beecut: src/beecut/beecut.c
	gcc -Wall -o $@ $^

%.sh: src/%.sh.in
	sed -e 's,@PREFIX@,$(PREFIX),g' \
	    -e 's,@EPREFIX@,$(EPREFIX),g' \
	    -e 's,@BINDIR@,$(BINDIR),g' \
	    -e 's,@SBINDIR@,$(SBINDIR),g' \
	    -e 's,@SYSCONFDIR@,$(SYSCONFDIR),g' \
	    -e 's,@LIBEXECDIR@,$(LIBEXECDIR),g' \
	    -e 's,@DATADIR@,$(DATADIR),g' \
	    $< > $@
	
beefind.pl: src/beefind.pl
	cp $< $@

clean:
	rm -f $(addsuffix .sh,$(SHELLS) $(TOOLS))
	rm -f $(PERLS)
	rm -f $(PROGRAMS)

install: install-core install-config

install-core: build
	@mkdir -vp ${DESTDIR}${BINDIR}
	@for i in $(SHELLS) ; do \
	     install -v -m 0755 $${i}.sh ${DESTDIR}${BINDIR}/$${i} ; \
	 done
	
	@for i in $(PERLS) $(PROGRAMS) ; do \
	     install -v -m 0755 $${i} ${DESTDIR}${BINDIR} ; \
	 done
	@mkdir -vp ${DESTDIR}${LIBEXECDIR}
	@for i in $(TOOLS) ; do \
	     install -v -m 0755 $${i}.sh ${DESTDIR}${LIBEXECDIR}/$${i} ; \
	 done
	@for i in $(BEELIB) ; do \
	     install -v -m 0755 $${i}.sh ${DESTDIR}${LIBEXECDIR}/$${i}.sh ; \
	 done

install-config:
	@mkdir -vp ${DESTDIR}${BEEDIR}
	@for i in ${CONFIGS} ; do \
	     install -v -m 0644 conf/$${i} ${DESTDIR}${BEEDIR}/$${i}.sample; \
	 done
	@mkdir -vp ${DESTDIR}${TEMPLATEDIR}
	@for t in ${TEMPLATES} ; do \
	     install -v -m 0644 conf/templates/$${t} ${DESTDIR}${TEMPLATEDIR} ; \
	 done
	@mkdir -vp ${DESTDIR}${MAGICDIR}
	@for t in ${MAGIX} ; do \
	     install -v -m 0644 conf/beesh.d/$${t}.sh ${DESTDIR}${MAGICDIR}/$${t}.sh ; \
	 done
