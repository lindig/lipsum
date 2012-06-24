

module SM = Map.Make(String)
module SS = Set.Make(String)

type position =
    { file:     string
    ; line:     int
    ; column:   int
    }    

type code =
    | Str       of string
    | Ref       of string
    | Sync      of position

type chunk =
    | Doc       of string
    | Code      of string * code list

type doc = chunk list

type t = 
    { code:     (code list) SM.t
    ; chunks:   chunk list
    }


let (@@) f x = f x

let empty =
    { code      = SM.empty 
    ; chunks    = []
    }

let append key v map =
    if SM.mem key map
    then SM.add key ((SM.find key map)@v) map
    else SM.add key v map

let index chunks =
    let add t = function
        | Doc(str)   as d ->    { t with chunks = d :: t.chunks }
        | Code(n,cs) as c ->    { code   = append n cs t.code
                                ; chunks = c::t.chunks
                                }
    in
    let t = List.fold_left add empty chunks in
        { t with chunks = List.rev t.chunks}


let code_chunks t = 
    SM.fold (fun name _ names -> name::names) t.code []

let code_roots t = 
    let add name _ names = SS.add name names in
    let chunks = SM.fold add t.code SS.empty in
    chunks

(* Just for debugging during development
 *)

let code = function
    | Str(str)      -> Printf.printf "|%s|"     str
    | Ref(str)      -> Printf.printf "<|%s|>" str
    | Sync(pos)     -> Printf.printf "# %d \"%s\"\n" pos.line pos.file
            
let chunk map = function 
    | Doc(str)       -> Printf.printf "@ %s"  str
    | Code(name,cs)  -> 
            ( Printf.printf "<|%s|>=" name
            ; List.iter code cs
            )

let print litprog = List.iter (chunk litprog.code) litprog.chunks
