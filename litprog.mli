
exception NoSuchChunk of string
exception Cycle of string

type code = 
    | Str of Tangle.position * string 
    | Ref of string
    
type chunk = 
    | Doc of string 
    | Code of string * code list
    
type doc = chunk list
type t 

val make : chunk list -> t
val code_chunks : t -> string list
val code_roots : t -> string list 
val tangle : t -> Tangle.t -> string -> unit (* NoSuchChunk, Cycle *)
val print : t -> unit