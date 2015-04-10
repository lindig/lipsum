#
# Lipsum
#
# https://github.com/lindig/lipsum.git
#
# You can override the PREFIX from the command line: make PREFIX=/usr/local

PREFIX  = $(HOME)
BIN 	= $(PREFIX)/bin
MAN1DIR = $(PREFIX)/man/man1
POD2MAN = pod2man $(PODOPTS)
PODOPTS = --center="Christian Lindig" --name="lipsum" --release="2015"
INSTALL = install

# OCaml - we rely on ocamlbuild for compilation

OCB_OPTS = -use-ocamlfind -yaccflag -v
OCB 	 = ocamlbuild $(OCB_OPTS) -I src

# high-level targets

all:	lipsum lipsum.1

install: dir lipsum lipsum.1
	install lipsum $(BIN)
	install lipsum.1 $(MAN1DIR)

remove:	FORCE
	rm -f $(BIN)/lipsum
	rm -f $(MAN1DIR)/lipsum.1

dir:
	install -d $(BIN) $(MAN1DIR)

clean:
	$(OCB) -clean
	rm -f lipsum.1 lipsum
	rm -f url descr

lipsum.native: libs
	$(OCB) lipsum.native

lipsum.byte: libs
	$(OCB) lipsum.byte

lipsum: lipsum.native
	cp $< $@

%.1: 	%.pod
	$(POD2MAN) $< > $@

libs:
	# sanity check. If this fails, try "opam install re"
	ocamlfind query re re.glob


FORCE:

# OPAM - the targets below help to publish this code via opam.ocaml.org

NAME =		lipsum
VERSION =	0.2
TAG =		v$(VERSION)
GITHUB =	https://github.com/lindig/$(NAME)
ZIP =		$(GITHUB)/archive/$(TAG).zip
OPAM =		$(HOME)/Development/opam-repository/packages/$(NAME)/$(NAME).$(VERSION)

tag:
		git tag $(TAG)

descr:		README.md
		sed -n '/^# Opam/,$$ { /^#/n; p;}' $< >$@

url:		FORCE
		# echo	"archive: \"$(ZIP)\"" > url
		# echo	"checksum: \"`curl -L $(ZIP)| md5 -q`\"" >> url
		echo	'git: "git@github.com:lindig/lipsum.git"' > url

release:	url opam descr sanity
		test -d "$(OPAM)" || mkdir -p $(OPAM)
		cp opam url descr $(OPAM)

sanity:		descr opam
		grep -q 'version: "$(VERSION)"' opam
		sed -n 1p descr | grep -q $(NAME)
		# grep -q 'version = "$(VERSION)"' META

# pseudo target

FORCE:;
