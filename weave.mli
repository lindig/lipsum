
exception NoSuchFormat of string

type t = out_channel -> Litprog.chunk list -> unit

val lookup  : string -> t (* NoSuchFormat *)
val formats : string list

val plain   : t
