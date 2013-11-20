(*
   RE - A regular expression library

   Copyright (C) 2001 Jerome Vouillon
   email: Jerome.Vouillon@pps.jussieu.fr

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation, with
   linking exception; either version 2.1 of the License, or (at
   your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*)

exception Parse_error

val glob : ?anchored:unit -> string -> Re.t
   (* Implements the semantics of shells patterns. The returned regular
      expression is unanchored by default. If the [anchored] parameter
      is provided, the regular expression will only matches whole strings.

      Character '/' must be explicitely matched.  A dot at the
      beginning of a file name must be explicitely matched as well.
      Character '*' matches any sequence of characters and character
      '?' matches a single character, provided these restrictions are
      satisfied,
      A sequence '[...]' matches any of the enclosed characters.
      A backslash escapes the following character. *)

val glob' : ?anchored:unit -> bool -> string -> Re.t
   (* Same, but allows to choose whether dots at the beginning of a
      file name need to be explicitly matched (true) or not (false) *)

val globx : ?anchored:unit -> string -> Re.t
val globx' : ?anchored:unit -> bool -> string -> Re.t
    (* These two functions also recognize the pattern {..,..} *)
