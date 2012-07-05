
exception NoSuchFormat of string
type t = out_channel -> Litprog.position -> string -> unit

val lookup  : string -> t (* NoSuchFormat *)
val formats : string list
