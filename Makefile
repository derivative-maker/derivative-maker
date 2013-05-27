SHELL := /bin/bash

all:
	@echo "purely optional makefile for Whonix developer convince:"
	@echo
	@echo "make lintian    - for lintian report in $(CURDIR)/lintian.log"
	@echo
	@echo "make cl-append  - to append a new line to changelog"
	@echo "make cl-release - to update timestamp and let edit the version"
	@echo
	@echo "make clean      - to remove the built packages"
	@echo
	@echo "Extra commands for Heikos convince:"
	@echo
	@echo "make update     - to convince glorious git to give me the current code"
	@echo "make commit/ci  - to convince glorious git to put my current code to GitHub"
	@echo "make status     - to convince glorious git to give me a meaningful status"
	@echo "make merge      - to convince glorious git to merge something"

package:
	dpkg-buildpackage -tc
	
lintian: debian/control
	-lintian -I -i `find $(CURDIR)/.. -name '*.dsc' -o -name '*.deb'` > $(CURDIR)/lintian.log
	
clean:
	-rm -v `find $(CURDIR)/../whonix* -name '*.dsc' -o -name '*.deb' -o -name '*.changes'`

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
