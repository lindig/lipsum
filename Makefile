#
# 
#

OCB 	= ocamlbuild -yaccflag -v
TARGET  = lipsum


all:	byte

native:
	$(OCB) $(TARGET).native

byte: 	
	$(OCB) $(TARGET).byte
	
clean:
	$(OCB) -clean


