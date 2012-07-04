
exception NoSuchChunk of string
exception Cycle of string

type position = 
    { file : string
    ; line : int
    ; column : int; 
    }

type code = 
    | Str of position * string 
    | Ref of position * string
    
type chunk = 
    | Doc of string 
    | Code of string * code list
    
type doc = chunk list
type t 

val make : chunk list -> t
val code_chunks : t -> string list
val code_roots : t -> string list 
val expand : t -> string -> unit (* NoSuchChunk, Cycle *)
val print : t -> unit