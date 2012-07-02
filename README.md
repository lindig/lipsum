
### Lipsum - A Literate Programming Tool

Lipsum is a command-line utility for literate programming in the tradition of
[Noweb](http://www.cs.tufts.edu/~nr/noweb/). The idea of literate programming
is to keep documentation for programmers and program code in one file and to
arrange it in a way that helps understanding it. To actually compile or run
the code it needs to be extracted from the literate program and Lipsum is a
tool to do this.

Like Noweb, Lipsum employs a minimal markup to arrange documentation and code
in a file. Also like Noweb, Lipsum is language agnostic and can be used for
almost any programming language and documentation.

        Echo prints each command line argument on a line by itself. This 
        documentation chunk extends until the beginning of the named code
        chunk below. 

        <<echo.c>>=
        /* <<copyright>> */
        #include <stdio.h>

        int main(int argc, char** argv)
        {
                int i;
                for (i=0; i<argc; i++)
                        puts(argv[i]);
                return 0;
        }

        @ By keeping the copyright notice in a chunk by itself it is easy to
        include it in several files. This documenation chunk starts with 
        an @ followed by a space and extends until the beginning of the next 
        chunk.

        <<copyright>>=
        This code is in the public domain.

        <<copyright>>=
        This code is part of the documentation for Lipsum.

To extract the code for `echo.c` for compilation from the file `echo.lp` using
Lipsum, one would run Lipsum like this:

        $ lipsum expand echo.c echo.lp > echo.c
        $ cc -o echo echo.c
            
## Resources for Literate Programming

While literate programming isn't a mass phenomenon among programmers it has a
dedicated following. Here are some resources to learn about its concepts,
strengths, and weaknesses.

* [Noweb Homepage](http://www.cs.tufts.edu/~nr/noweb/)
* [Noweb on Wikipedia](http://en.wikipedia.org/wiki/Noweb)
* [Literate Programming on 
        Wikipedia](http://en.wikipedia.org/wiki/Literate_programming)

Literate programming enjoys popularity in the [R](www.r-project.org/)
community which uses a literate programming system called Sweave which is also
in the tradition of Noweb. R is a system for statistical analysis and Sweave
is mainly used to include statistical analysis into scientific papers that are
typeset with LaTeX.

## Why not using Noweb?

Noweb is a great tool with a flexible architecture that permits a user to plug
in filters to extend it. This also makes its installation depend on various
filters that are part of its distribution that are written in various
languages. While this is usually not a problem if you develop code mostly for
yourself, it makes adds one more dependency if you want to release code as
open source.

Lipsum is less ambitious: it is just one binary and almost all it does is
extracting code from a literate program. I am planning to use it in
combination with Markdown as a syntax for documentation and to include it with
literate programs that I release as open source.

## Implementation and Installation

Lipsum is implemented in [Objective Caml](http://caml.inria.fr/). While
Objective Caml is available on the Windows platform, this distribution assumes
a Unix environment. It is developed on Mac OS X but should compile equally
well on a Linux system. For compilation, the following tools are required:

* Objective Caml
* pod2man (part of standard Perl distributions)
* Make
* Unix tools called from the Makefile: install, cp

To compile Lipsum, adjust the Makefile and run `make`. In particular, you
might want to adjust the `PREFIX` variable that controls where the lipsum
binary and the manual are getting installed.

        $ make
        $ make install

## Documentation

Lipsum comes with a Unix manual page `lipsum.1` that is generated from
`lipsum.pod`. POD is a simple markup language, much like Markdown, that is
used by the Perl community. To view the manual page prior to installation use
`nroff`:

        $ nroff -man lipsum.1 | less
        
After installation it is available using `man lipsum` as usual.

## License

Lipsum is distributed under the BSD-2 license. See file `lipsum.ml` for details. The license can be also displayed by the program:

        $ lipsum copyright

## Author

Christian Lindig <lindig@gmail.com>
