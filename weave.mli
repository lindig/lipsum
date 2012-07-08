
exception NoSuchFormat of string

type t = out_channel -> Litprog.doc -> unit

val lookup  : string -> t (* NoSuchFormat *)
val formats : string list

val plain   : t
