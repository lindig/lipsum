
exception NoSuchFormat of string

type position = 
    { file : string
    ; line : int
    ; column : int; 
    }
    
type t = out_channel -> position -> string -> unit

val lookup  : string -> t (* NoSuchFormat *)
val formats : string list

val plain   : t
