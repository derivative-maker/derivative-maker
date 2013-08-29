SHELL := /bin/bash

all:
	@echo "Purely optional makefile for Whonix developer's convenience:"
	@echo
	@echo "make lintian    - for lintian report in $(CURDIR)/lintian.log"
	@echo "make package    - performs a full build"
	@echo "make contents   - shows dpkg --contents of all packages"
	@echo
	@echo "make cl-append  - to append a new line to changelog"
	@echo "make cl-release - to update timestamp and let edit the version"
	@echo
	@echo "make clean      - to remove the built packages and clean up the debian folder"
	@echo
	@echo "Extra git commands for $(USER)'s convenience:"
	@echo
	@echo "make update     - to convince glorious git to give me the current code"
	@echo "make commit/ci  - to convince glorious git to put my current code to GitHub"
	@echo "make status     - to convince glorious git to give me a meaningful status"
	@echo "make merge      - to convince glorious git to merge something"

package:
	$(CURDIR)/help-steps/make-tarball
	dpkg-buildpackage -F -Zxz -z9 -tc
	
unsignedpackage:
	$(CURDIR)/help-steps/make-tarball
	dpkg-buildpackage -F -Zxz -z9 -tc -us -uc
	
lintian: debian/control
	-lintian -I -i `find $(CURDIR)/.. -name '*.dsc' -o -name '*.deb'` > ../lintian.log

contents:
	@for i in `find $(CURDIR)/.. -name '*.deb'`; do \
		echo "dpkg --contents $$i"; \
		dpkg --contents $$i ; \
	done
	
clean:
	@for dp in `gawk '/^Package\:[[:space:]]*.*$$/ { match($$0, /^Package:[[:space:]]*(.*)$$/, m); print m[1]"*.deb" }' $(CURDIR)/debian/control`; do \
		rm -vf $(CURDIR)/../$$dp ; \
	done
	@rm -vf $(CURDIR)/../`gawk '/^Source\:[[:space:]]+.*$$/ { match($$0, /^Source:[[:space:]]+(.*)$$/, m); print m[1]"*.dsc" }' $(CURDIR)/debian/control`
	@rm -vf $(CURDIR)/../`gawk '/^Source\:[[:space:]]+.*$$/ { match($$0, /^Source:[[:space:]]+(.*)$$/, m); print m[1]"*.changes" }' $(CURDIR)/debian/control`
	@rm -vf $(CURDIR)/../`gawk '/^Source\:[[:space:]]+.*$$/ { match($$0, /^Source:[[:space:]]+(.*)$$/, m); print m[1]"*.tar.*" }' $(CURDIR)/debian/control`
	fakeroot debian/rules clean

update:
	git fetch origin
	git merge origin/master

ci: commit
	
commit:
	git commit -a
	git push

status:
	git status
	
merge:
	@if [ -n "$(RB)" ]; then \
		echo "git diff $(RB)"; \
		git diff $(RB); \
	else \
		echo "How about to give RB=\"remote/branch\"?"; \
	fi

cl-append:
	dch -pma

cl-release:
	dch -pmr
