SHELL := /bin/sh
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

.PHONY: help test install uninstall build

help:
	@printf '%s\n' 'AniWatch development targets:' '  make test      Run smoke tests' '  make build     Build dist/aniwatch' '  make install   Install to $(BINDIR)' '  make uninstall Remove installed command'

test:
	@sh tests/run.sh

build:
	@sh scripts/build.sh

install:
	@mkdir -p "$(DESTDIR)$(BINDIR)"
	@install -m 755 bin/aniwatch "$(DESTDIR)$(BINDIR)/aniwatch"

uninstall:
	@rm -f "$(DESTDIR)$(BINDIR)/aniwatch"
