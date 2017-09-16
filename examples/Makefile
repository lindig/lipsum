#
#

LIPSUM = 	../_build/default/src/main.exe
CC = 		gcc

all: 		echo sortlines

clean:
		rm -f echo.c echo
		rm -f sortlines.c sortlines
	
%.c: 		%.lp
		$(LIPSUM) tangle -f cpp $@ $< > $@
		
%:		%.c
		$(CC) -o $@ $<
		
