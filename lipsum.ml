
module S = Scanner
module P = Parser

exception Error of string
let error fmt = Printf.kprintf (fun msg -> raise (Error msg)) fmt
let eprintf   = Printf.eprintf

let (@@) f x = f x

let scan file =
    let f       = open_in file in
    let lexbuf  = Lexing.from_channel f in
    let rec loop lexbuf =
        match S.token' lexbuf with
        | P.EOF  -> print_endline @@ S.to_string P.EOF
        | tok  -> ( print_endline @@ S.to_string tok
                  ; loop lexbuf
                  )
    in
        ( loop lexbuf
        ; close_in f
        )

let parse file =
    let f       = open_in file in
    let lexbuf  = Lexing.from_channel f in
    let ast     = P.litprog S.token' lexbuf in
    let doc     = Syntax.index ast in
        ( Syntax.print doc
        ; close_in f
        )

let help this =
    ( eprintf "%s scan file.lp\n" this
    ; eprintf "%s parse file.lp\n" this
    ; exit 1
    )  
      
let main () =
    let argv    = Array.to_list Sys.argv in
    let this    = Filename.basename (List.hd argv) in
    let args    = List.tl argv in
        match args with
        | "scan" ::file::[]     -> scan file
        | "parse"::file::[]     -> parse file
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
        | _                  -> Printf.eprintf "some unknown error occurred\n"; exit 1  