
module S = Scanner

exception Error of string
let error fmt = Printf.kprintf (fun msg -> raise (Error msg)) fmt
let eprintf   = Printf.eprintf

let (@@) f x = f x

let scan file =
	let f  		= open_in file in
	let lexbuf 	= Lexing.from_channel f in
	let rec loop lexbuf =
		match S.token' lexbuf with
		| S.EOF  -> print_endline @@ S.to_string S.EOF
		| tok  -> ( print_endline @@ S.to_string tok
				  ; loop lexbuf
				  )
	in
		( loop lexbuf
		; close_in f
		)

let main () =
	let argv    = Array.to_list Sys.argv in
	let this    = Filename.basename (List.hd argv) in
	let args    = List.tl argv in
		match args with
		| [file] -> scan file
		| []     -> error "%s: missing filename" this
		| _::_   -> error "%s: too many file names" this


let () = 
	try 
		main (); exit 0
	with 
		| Error(msg)         -> eprintf "error: %s\n" msg; exit 1
		| Failure(msg)       -> eprintf "error: %s\n" msg; exit 1
		| Scanner.Error(msg) -> eprintf "error: %s\n" msg; exit 1
		| _ 		         -> Printf.eprintf "some unknown error occurred\n"; exit 1	