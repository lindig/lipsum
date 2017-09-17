# vim: set noet ts=8:
#
# This Makefile is not called from Opam but only used for 
# convenience during development
#

JB 	= jbuilder
POD2MAN = pod2man $(PODOPTS)
PODOPTS = --center="Christian Lindig" --name="lipsum" --release="2017"

all: 	lipsum.1 
	$(JB) build

install:
	$(JB) install

clean:
	$(JB) clean

man: 	lipsum.1

%:
	$(JB) build $@

%.1: 	%.pod
	$(POD2MAN) $< > $@

# OPAM - the targets below help to publish this code via opam.ocaml.org

NAME     = lipsum
VERSION  = master
TAG      = $(VERSION)
GITHUB   = https://github.com/lindig/$(NAME)
ZIP      = $(GITHUB)/archive/$(TAG)/$(NAME)-$(TAG).zip
OPAM     = $(HOME)/Development/opam-repository/packages/$(NAME)/$(NAME).$(VERSION)

zip:
	curl -L -O $(ZIP)

lipsum.url:
	echo	"archive: \"$(ZIP)\"" > $@
	echo	"checksum: \"`curl -L $(ZIP)| md5 -q`\"" >> $@

