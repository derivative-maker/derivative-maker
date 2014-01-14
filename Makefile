## This file is part of Whonix.
## Copyright (C) 2012 - 2014 Patrick Schleizer <adrelanos@riseup.net>
## See the file COPYING for copying conditions.

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
	$(CURDIR)/help-steps/cleanup-files

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
