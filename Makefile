# Make sure we have 'git' and it works OK:
ifeq ($(shell which git),)
    $(error 'git' is not installed on this system)
endif
GITVER ?= $(word 3,$(shell git --version))

NAME = lw
LIB = lib
LIBS = $(shell find $(LIB) -type f) \
	$(shell find $(LIB) -type l)
DOC = doc/$(NAME).swim
MAN = $(MAN1)/$(NAME).1
MAN1 = man/man1
SHARE = share

##
# User targets:
default: help

help:
	@echo 'Makefile rules:'
	@echo ''
	@echo 'test       Run all tests'
	@echo 'doc        Build the docs'

.PHONY: test
test:
ifeq ($(shell which prove),)
	@echo '`make test` requires the `prove` utility'
	@exit 1
endif
	prove $(PROVEOPT:%=% )test/

clean purge:
	git clean -fxd

##
# Build rules:

update: doc compgen

doc: $(MAN) ReadMe.pod
	perl tool/generate-help-functions.pl $(DOC) > \
	    $(LIB)/help-functions.bash

compgen:
	perl tool/generate-completion.pl $(DOC) > \
	    $(SHARE)/completion.bash

$(MAN1)/%.1: doc/%.swim swim-check
	swim --to=man $< > $@

ReadMe.pod: $(DOC) swim-check
	swim --to=pod --complete --wrap $< > $@

swim-check:
	@# Need to assert Swim and Swim::Plugin::badge are installed
