
exception NoSuchFormat of string

type position = 
    { file : string
    ; line : int
    ; column : int 
    ; offset: int
    }
    
type t = out_channel -> position -> string list -> unit

val lookup  : string -> t (* NoSuchFormat *)
val formats : string list

val plain   : t
