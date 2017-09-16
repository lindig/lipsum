(** Command line evaluaton *)

(** This is the main module that evaluates the command line and drives
    the program. *)

module C  = Cmdliner
module S  = Scanner
module P  = Parser
module LP = Litprog
module T  = Tangle
module RX = Re      (** regular expression   *)
module G  = Re_glob (** shell-style globbing *)

exception Error of string
let error fmt = Printf.kprintf (fun msg -> raise (Error msg)) fmt
let eprintf   = Printf.eprintf
let printf    = Printf.printf
let giturl    = "https://github.com/lindig/lipsum.git"


let copyright () =
  List.iter print_endline
    [ giturl
    ; "Copyright (c) 2012, 2013, 2014, 2015"
    ; "Christian Lindig <lindig@gmail.com>"
    ; "All rights reserved."
    ; ""
    ; "Redistribution and use in source and binary forms, with or"
    ; "without modification, are permitted provided that the following"
    ; "conditions are met:"
    ; ""
    ; "(1) Redistributions of source code must retain the above copyright"
    ; "    notice, this list of conditions and the following disclaimer."
    ; "(2) Redistributions in binary form must reproduce the above copyright"
    ; "    notice, this list of conditions and the following disclaimer in"
    ; "    the documentation and/or other materials provided with the"
    ; "    distribution."
    ; ""
    ; "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND"
    ; "CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES,"
    ; "INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF"
    ; "MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE"
    ; "DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR"
    ; "CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,"
    ; "SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT"
    ; "LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF"
    ; "USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED"
    ; "AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT"
    ; "LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN"
    ; "ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE"
    ; "POSSIBILITY OF SUCH DAMAGE."
    ; ""
    ]

let finally opn cls =
  let res = try opn () with exn -> cls (); raise exn in
  cls ();
  res

(** Attach a file name to the input source that we are reading. This is
    most useful when we are reading from stdin and no file name
    was attached *)
let set_filename (fname:string) (lexbuf:Lexing.lexbuf)  =
  ( lexbuf.Lexing.lex_curr_p <-
      { lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = fname }
  ; lexbuf
  )

(** Open a named file (or stdin), setup a lexer and call f on the lexer for
    the result. If a file was opened, it is closed before the result
    is returned *)
let with_lexbuf path f = match path with
  | None -> 
    Lexing.from_channel stdin |> set_filename "stdin" |> f
  | Some path ->
    let io = open_in path in
    finally
      (fun () -> Lexing.from_channel io |> set_filename path |> f)
      (fun () -> close_in io)

let scan path =
  let rec loop lexbuf =
    match S.token' lexbuf with
    | P.EOF  -> print_endline @@ S.to_string P.EOF
    | tok  -> ( print_endline @@ S.to_string tok
              ; loop lexbuf
              )
  in
  with_lexbuf path loop


let escape path = with_lexbuf path (Escape.escape stdout) 
(** read input and emit it again, escaping characters where needed
    to turn this into a code chunk in a literate program *)

let litprog path = with_lexbuf path (P.litprog S.token') |> LP.make
(** create a literate program by parsing the input *)

let parse path = litprog path |> LP.print
(** emit a literate program for debugging *)

(** expand chunk from litprog into a file named like chunk, using format *)
let tangle_to_file (litprog:LP.t) (format:Tangle.t) (chunk:string) =
  let io = open_out chunk in
  finally 
    (fun () -> LP.tangle litprog format io chunk)
    (fun () -> close_out io)

let tangle_roots fmt path =
  let fmt   = T.lookup fmt in
  let lp    = litprog path in
  lp
  |> LP.code_roots 
  |> List.iter (tangle_to_file lp fmt) 

let compile glob =
  try
    RX.compile @@ RX.whole_string @@ G.globx glob
  with
    G.Parse_error -> error "syntax error in pattern '%s'" glob

let expand fmt glob path =
  (** only expand roots matching glob *)
  let rx    = compile glob in (* rx can be used for matching a string *)
  let fmt   = T.lookup fmt in
  let lp    = litprog path in
  lp
  |> LP.code_roots
  |> List.filter (RX.execp rx) 
  |> List.iter (tangle_to_file lp fmt) 

let tangle fmt chunk path =
  LP.tangle (litprog path) (T.lookup fmt) stdout chunk

let weave path =
  litprog path
  |> LP.doc
  |> (Weave.lookup "plain") stdout

let chunks path =
  litprog path
  |> LP.code_chunks
  |> List.iter print_endline

let roots path =
  litprog path
  |> LP.code_roots 
  |> List.iter print_endline

let undefined path =
  litprog path
  |> LP.unknown_references 
  |> List.iter print_endline

let formats () = 
  T.formats
  |> List.iter print_endline


module Command = struct
  let filename =
    C.Arg.(value
           & pos 0 (some file) None ~rev:true
           & info [] 
             ~docv:"file.lp" 
             ~doc:"Literate program file. Defaults to stdin."
          )

  let chunk =
    C.Arg.(required
           & pos 0 (some string) None
           & info [] 
             ~docv:"chunk" 
             ~doc:"Code chunk defined in literate program."
          )

  let format =
    C.Arg.(value 
           & opt string "plain"
           & info ["format"; "f"] 
             ~docv:"format" 
             ~doc:"Format of line number directives in output."
          )

  let glob =
    C.Arg.(required
           & pos 0 (some string) None
           & info [] 
             ~docv:"glob" 
             ~doc:"Glob pattern for code chunks in literate program."
          )

  let more_help =
    [ `S "MORE HELP"
    ; `P "Use `$(mname) $(i,COMMAND) --help' for help on a single command."
    ; `S "BUGS"
    ; `P "Check bug reports at https://github.com/lindig/lipsum/issues"
    ]

  let roots =
    let doc = "list all root code chunks defined in literate program." in
    let man =
      [ `S "DESCRIPTION"
      ; `P doc
      ; `Blocks more_help
      ] in
    C.Term.
      ( const roots $ filename
      , info "roots" ~doc ~man
      )

  let chunks =
    let doc = "List all code chunks defined in literate program." in
    C.Term.
      ( const chunks $ filename
      , info "chunks" ~doc
      )

  let undefined =
    let doc = "list all used but undefined code chunks." in
    C.Term.
      ( const undefined $ filename
      , info "undefined" ~doc
      )

  let copyright =
    let doc = "Emit copyright notice on standard output." in
    C.Term.
      ( const copyright $ const ()
      , info "copyright" ~doc
      )

  let tangle =
    let doc = "Extract code chunk from literate program." in
    C.Term.
      ( const tangle $ format $ chunk $ filename
      , info "tangle" ~doc
      )

  let expand =
    let doc = "Extract code chunks matching glob from literate program." in
    C.Term.
      ( const expand $ format $ glob $ filename
      , info "expand" ~doc
      )

  let weave =
    let doc = "Emit literate program." in
    C.Term.
      ( const weave $ filename
      , info "weave" ~doc
      )

  let scan =
    let doc = "For debugging, emit literate program as token sequence" in
    C.Term.
      ( const scan $ filename
      , info "scan" ~doc
      )

 let parse =
    let doc = "For debugging, emit literate program" in
    C.Term.
      ( const parse $ filename
      , info "parse" ~doc
      )


  let formats =
    let doc = "List formats available for option $(format)." in
    C.Term.
      ( const formats $ const ()
      , info "formats" ~doc
      )

  let lipsum =
    let doc = "literate programming tool" in
    let man =
      [ `S "DESCRIPTION"
      ; `P doc
      ; `Blocks more_help
      ] in
    C.Term.
      ( ret (const (fun _ -> `Help(`Pager, None)) $ const ())
      , info "lipsum" ~doc ~man
      )

  let all =
    [ copyright
    ; roots
    ; chunks
    ; undefined
    ; tangle
    ; expand
    ; weave
    ; scan
    ; formats
    ; parse
    ]
end

let main () =
  try match C.Term.eval_choice Command.lipsum Command.all ~catch:false with
    | `Error _  -> exit 1
    | _         -> exit 0
  with 
  | Error(msg)         -> eprintf "error: %s\n" msg; exit 1
  | Failure(msg)       -> eprintf "error: %s\n" msg; exit 1
  | Scanner.Error(msg) -> eprintf "error: %s\n" msg; exit 1
  | Sys_error(msg)     -> eprintf "error: %s\n" msg; exit 1
  | T.NoSuchFormat(s)  -> eprintf "unknown tangle format %s\n" s; exit 1
  | LP.NoSuchChunk(msg)-> eprintf "no such chunk: %s\n" msg; exit 1
  | LP.Cycle(s)        -> eprintf "chunk <<%s>> is part of a cycle\n" s;
    exit 1
  | exn                -> Printf.eprintf "error: %s\n" 
                            (Printexc.to_string exn); 
    exit 1

let () = if !Sys.interactive then () else main ()
