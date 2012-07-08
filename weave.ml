
module SM = Map.Make(String)
module LP = Litprog

exception NoSuchFormat of string

type t = out_channel -> LP.chunk list -> unit

let (@@) f x = f x
let fprintf = Printf.fprintf

let output_strings io prefix strings postfix =
    let out s =
        ( output_string io prefix 
        ; output_string io s
        ; output_string io postfix
        )
    in
        List.iter out strings 
        
    
let plain_code io = function
    | LP.Str(_,strs) -> output_strings io "    " strs "\n"
    | LP.Ref(str)    -> fprintf io "<<%s>>" str   

let plain_chunk io = function
    | LP.Doc(strs)          -> output_strings io "" strs "\n"
    | LP.Code(name, code)   -> 
        ( fprintf io "<<%s>>=\n" name
        ; List.iter (plain_code io) code
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


