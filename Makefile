# vim: set noet ts=8:
#
# This Makefile is not called from Opam but only used for 
# convenience during development
#

DUNE 	= dune
POD2MAN = pod2man $(PODOPTS)
PODOPTS = --center="Christian Lindig" --name="lipsum" --release="2017"

all: 	lipsum.1 
	$(DUNE) build -p lipsum

install:
	$(DUNE) install

profile:
	$(DUNE) build --profile=profile

clean:
	$(DUNE) clean

man: 	lipsum.1

%:
	$(DUNE) build $@

%.1: 	%.pod
	$(POD2MAN) $< > $@
