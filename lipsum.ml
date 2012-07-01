
module S  = Scanner
module P  = Parser
module LP = Litprog

exception Error of string
let error fmt = Printf.kprintf (fun msg -> raise (Error msg)) fmt
let eprintf   = Printf.eprintf
let printf    = Printf.printf

let (@@) f x = f x

type 'a result = Success of 'a | Failed of exn

let finally f x cleanup = 
    let result =
        try Success (f x) with exn -> Failed exn
    in
        cleanup x; 
        match result with
        | Success y  -> y 
        | Failed exn -> raise exn

let process f = function
    | Some path -> finally f (open_in path) close_in
    | None      -> f stdin
            
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

let expand chunk io =
    LP.expand (doc io) chunk

let chunks io =
    List.iter print_endline @@ LP.code_chunks @@ doc io

let roots io =
    List.iter print_endline @@ LP.code_roots @@ doc io

let help this =
    let this = "lipsum" in
    List.iter print_endline 
    [ this^" is a utility for literate programming"
    ; ""
    ; this^" help                       emit help to stdout"
    ; this^" roots [file.lp]            list root chunks"
    ; this^" chunks [file.lp]           list all chunks"
    ; this^" tangle chunk [file.lp]     extract chunk from file"
    ; this^" prepare [file.ip]          prepare file.lp to be used as chunk"
    ; ""
    ; "See the manual lipsum(1) for documentation."
    ; ""
    ; "Debugging commands:"
    ; this^" scan [file.lp]             tokenize file and emit tokens"
    ; this^" parse [file.lp]            parse file and emit it"
    ; ""
    ; "Copyright (c) 2012 Christian Lindig <lindig@gmail.com>"
    ]

 
let path = function 
    | []        -> None 
    | [path]    -> Some path 
    | args      -> error "expected a single file name but found %d" 
                        (List.length args) 
      
let main () =
    let argv    = Array.to_list Sys.argv in
    let this    = Filename.basename (List.hd argv) in
    
    let args    = List.tl argv in
        match args with
        | "scan" ::args     -> process scan  @@ path args
        | "parse"::args     -> process parse @@ path args
        | "expand"::s::args -> process (expand s) @@ path args
        | "tangle"::s::args -> process (expand s) @@ path args
        | "chunks"::args    -> process chunks @@ path args
        | "roots"::args     -> process roots @@ path args
        | "escape"::args    -> process escape @@ path args
        
        | "help"::_             -> help this; exit 0
        | "-help"::_            -> help this; exit 0
        | []                    -> help this; exit 1
        | _                     -> help this; exit 1


let () = 
    try 
        main (); exit 0
    with 
        | Error(msg)         -> eprintf "error: %s\n" msg; exit 1
        | Failure(msg)       -> eprintf "error: %s\n" msg; exit 1
        | Scanner.Error(msg) -> eprintf "error: %s\n" msg; exit 1
        | Sys_error(msg)     -> eprintf "error: %s\n" msg; exit 1
        | LP.NoSuchChunk(msg)-> eprintf "no such chunk: %s\n" msg; exit 1
        | LP.Cycle(s)        -> eprintf "chunk <<%s>> is part of a cycle\n" s
        (*
        | _                  -> Printf.eprintf "some unknown error occurred\n"; exit 1  
        *)