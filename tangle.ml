
module LP = Litprog
module SM = Map.Make(String)

exception NoSuchFormat of string

type t = out_channel -> Litprog.position -> string -> unit

let fprintf = Printf.fprintf
let escaped = String.escaped
let (@@) f x = f x
    
let plain io pos str = 
    output_string io str

let cpp io pos str =
    ( fprintf io "# %d \"%s\"\n" pos.LP.line (escaped pos.LP.file)
    ; output_string io str
    )

let formats =
    List.fold_left (fun map (key,v) -> SM.add key v map) SM.empty
    [ "plain", plain
    ; "cpp", cpp
    ]

let lookup fmt = 
    try 
        SM.find fmt formats
    with
        Not_found -> raise (NoSuchFormat fmt)

let formats = List.map fst @@ SM.bindings formats     