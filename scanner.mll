{ 
    module L = Lexing
    module B = Buffer
    module P = Parser (* defines tokens *)
    
    let get         = Lexing.lexeme
    let getchar     = Lexing.lexeme_char
    let new_line    = Lexing.new_line

    exception Error of string

    let position lexbuf =
        let p = lexbuf.L.lex_curr_p in
        Printf.sprintf "%s:%d:%d" 
            p.L.pos_fname p.L.pos_lnum (p.L.pos_cnum - p.L.pos_bol)

    let error lexbuf fmt = 
        let p = position lexbuf in
        Printf.kprintf (fun msg -> raise (Error (p^" "^msg))) fmt

    let return tok pos str = (tok,pos,B.contents str)
    let (@@) f x = f x

    (* col0 is true, iff a match starts at the beginning of a line *)
    let col0 lexbuf = 
        let p = lexbuf.L.lex_start_p
        in
            p.L.pos_cnum = p.L.pos_bol

}

rule token pos str = parse
      eof                       { return P.EOF pos str     }
    | "@<<"                     { B.add_string str "<<" 
                                ; token pos str lexbuf
                                }
    | "<<"                      { let x   = name (Buffer.create 40) lexbuf in
                                    return x pos str
                                }
    | "@ "                      { if col0 lexbuf                   
                                  then return P.AT pos str               
                                  else  ( B.add_string str (get lexbuf)     
                                        ; token pos str lexbuf         
                                        )                          
                                }                                 
    | "@\n"                     { new_line lexbuf;
                                  if col0 lexbuf                   
                                  then return P.AT pos str               
                                  else  ( B.add_string str (get lexbuf)
                                        ; token pos str lexbuf         
                                        )                          
                                }  
    | "@@"                      { (if col0 lexbuf
                                   then  B.add_char str '@' 
                                   else  B.add_string str "@@");
                                  token pos str lexbuf
                                }  
    | "@@<<"                    { B.add_string str "@<<" 
                                ; token pos str lexbuf }
    | '\n'                      { new_line lexbuf                  
                                ; B.add_char str '\n'              
                                ; token pos str lexbuf                 
                                }                                  
    | _                         { B.add_char str (getchar lexbuf 0)
                                ; token pos str lexbuf                 
                                }                                  
and name str = parse
      eof                       { error lexbuf "unexpected end of file in <<..>>" }
    | '\n'                      { error lexbuf "unexpected newline in <<..>>"}
    | "@<<"                     { B.add_string str "<<" ; name str lexbuf }
    | "@>>"                     { B.add_string str ">>" ; name str lexbuf }
    | "@>>="                    { B.add_string str ">>="; name str lexbuf }
    | "@@"                      { B.add_char str '@'     ; name str lexbuf }
    | "@@>>"                    { B.add_string str "@>>" ; name str lexbuf }
    | "@@<<"                    { B.add_string str "@<<" ; name str lexbuf }
    | "@@>>="                   { B.add_string str "@>>="; name str lexbuf }
    | ">>"                      { P.REF (B.contents str) }
    | ">>="                     { P.DEF (B.contents str) }
    (* special case - eat up newline. Is this a good idea? *)
    | ">>=\n"                   { new_line lexbuf; P.DEF (B.contents str)}
    | _                         { B.add_char str (getchar lexbuf 0)
                                ; name str lexbuf                 
                                }
 
                                                              
{

let excerpt s =
    let str = String.escaped s in
    let len = String.length str in
        if len < 40 then str 
        else
            String.sub str 0 20 ^ " ... " ^ String.sub str (len - 20) 20
            
let to_string = function
    | P.EOF         -> "EOF"  
    | P.DEF(s)      -> Printf.sprintf "<<%s>>=" s
    | P.REF(s)      -> Printf.sprintf "<<%s>>" s
    | P.AT          -> "@"
    | P.STR(_,s)    -> excerpt s


let next = ref None
let token' lexbuf =
    let pos = lexbuf.L.lex_curr_p in
    match !next with
    | None  -> let t,p,s = token pos (Buffer.create 256) lexbuf in
               ( next := Some t
               ; P.STR(p,s)
               )
    | Some t -> ( next := None
                ; t
                )       


}
