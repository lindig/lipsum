#
# Lipsum
#
# https://github.com/lindig/lipsum.git
#

PREFIX  = $(HOME)
BIN 	= $(PREFIX)/bin
MAN1DIR = $(PREFIX)/man/man1
POD2MAN = pod2man $(PODOPTS)
PODOPTS = --center="Christian Lindig" --name="lipsum" --release="2012"
INSTALL = install

# OCaml - we rely on ocamlbuild for compilation

OCB 	= ocamlbuild -yaccflag -v -cflag -annot


# high-level targets

all:	lipsum lipsum.1


install: dir lipsum lipsum.1
	install lipsum $(BIN)
	install lipsum.1 $(MAN1DIR)

dir:	
	install -d $(BIN) $(MAN1DIR)

clean:
	$(OCB) -clean
	rm -f lipsum.1 lipsum

#


lipsum.native: FORCE
	$(OCB) lipsum.native

lipsum.byte: FORCE
	$(OCB) lipsum.byte

lipsum: lipsum.native
	cp $< $@
	
%.1: 	%.pod
	$(POD2MAN) $< > $@

FORCE:

