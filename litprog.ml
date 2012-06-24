

module SM = Map.Make(String)

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

(* print to stdout *)

let (@@) f x = f x

let empty =
    { code      = SM.empty 
    ; chunks    = []
    }

let enlarge key v map =
    if SM.mem key map
    then SM.add key ((SM.find key map)@v) map
    else SM.add key v map

let index chunks =
    let add t = function
        | Doc(str)   as d ->    { t with chunks = d :: t.chunks }
        | Code(n,cs) as c ->    { code   = enlarge n cs t.code
                                ; chunks = c::t.chunks
                                }
    in
    let t = List.fold_left add empty chunks in
        { t with chunks = List.rev t.chunks}

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
