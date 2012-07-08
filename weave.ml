
module SM = Map.Make(String)
module LP = Litprog

exception NoSuchFormat of string

type t = out_channel -> LP.doc -> unit

let (@@) f x = f x
let fprintf  = Printf.fprintf


let output_code io =
    String.iter (function
        | '\n' -> output_string io "\n    "
        |  c   -> output_char io c
        )        
            
let plain_code io = function
    | LP.Str(_,str) -> output_code io str
    | LP.Ref(str)   -> fprintf io "<<%s>>" str   

let plain_chunk io = function
    | LP.Doc(str)           -> output_string io str
    | LP.Code(name, code)   -> 
        ( fprintf io "    <<%s>>=" name
        ; List.iter (plain_code io) code
        ; output_char io '\n'
        )
        
let plain io chunks = List.iter (plain_chunk io) chunks
    
let formats =
    List.fold_left (fun map (key,v) -> SM.add key v map) SM.empty
    [ "plain", plain
    ]

let lookup fmt = 
    try 
        SM.find fmt formats
    with
        Not_found -> raise (NoSuchFormat fmt)

let formats = List.map fst @@ SM.bindings formats    


