
module S  = Scanner
module P  = Parser
module LP = Litprog

exception Error of string
let error fmt = Printf.kprintf (fun msg -> raise (Error msg)) fmt
let eprintf   = Printf.eprintf
let printf    = Printf.printf

let (@@) f x = f x

let process f = function
    | Some path -> 
        let io = open_in path in 
            ( f io
            ; close_in io
            )
    | None -> f stdin
            
let scan io =
    let lexbuf  = Lexing.from_channel io in
    let rec loop lexbuf =
        match S.token' lexbuf with
        | P.EOF  -> print_endline @@ S.to_string P.EOF
        | tok  -> ( print_endline @@ S.to_string tok
                  ; loop lexbuf
                  )
    in
        loop lexbuf

let escape io =
    let lexbuf = Lexing.from_channel io in
        Escape.escape stdout lexbuf

let doc io =
    let lexbuf  = Lexing.from_channel io in
    let ast     = P.litprog S.token' lexbuf in
        LP.index ast
        

let parse io =
    LP.print @@ doc io


let print_chunk chunk doc =
    let rec loop = function
        | LP.Str(s)  -> print_string s
        | LP.Ref(s)  -> List.iter loop (LP.SM.find s doc.LP.code)
        | LP.Sync(p) -> printf "# %d \"%s\"\n" p.LP.line p.LP.file
    in
        List.iter loop (LP.SM.find chunk doc.LP.code)

let expand chunk io =
    print_chunk chunk @@ doc io

let chunks io =
    List.iter print_endline @@ LP.code_chunks @@ doc io

let roots io =
    List.iter print_endline @@ LP.code_roots @@ doc io

let help this =
    ( eprintf "%s scan [file.lp]\n" this
    ; eprintf "%s parse [file.lp]\n" this
    ; exit 1
    )  
      
let main () =
    let argv    = Array.to_list Sys.argv in
    let this    = Filename.basename (List.hd argv) in
    let args    = List.tl argv in
        match args with
        | "scan" ::path::[]     -> process scan  (Some path)
        | "parse"::path::[]     -> process parse (Some path)
        | "scan" ::[]           -> process scan   None
        | "parse"::[]           -> process parse  None
        | "expand"::s::path::[] -> process (expand s) (Some path)
        | "tangle"::s::path::[] -> process (expand s) (Some path)
        | "chunks"::path::[]    -> process chunks (Some path)
        | "roots"::path::[]     -> process roots (Some path)
        | "escape"::path::[]    -> process escape (Some path)
        
        | "help"::_             -> help this
        | "-help"::_            -> help this
        | []                    -> help this
        | _                     -> help this


let () = 
    try 
        main (); exit 0
    with 
        | Error(msg)         -> eprintf "error: %s\n" msg; exit 1
        | Failure(msg)       -> eprintf "error: %s\n" msg; exit 1
        | Scanner.Error(msg) -> eprintf "error: %s\n" msg; exit 1
        (*
        | _                  -> Printf.eprintf "some unknown error occurred\n"; exit 1  
        *)