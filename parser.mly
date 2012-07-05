%{
module LP = Litprog
module P  = Parsing
module L  = Lexing
module T  = Tangle

let position n = 
    let p = P.rhs_start_pos n in
        { T.file = p.L.pos_fname
        ; T.line = p.L.pos_lnum
        ; T.column = p.L.pos_cnum
        }
%}

%start litprog
%type <Litprog.chunk list> litprog

%token EOF AT
%token <string> REF
%token <string> DEF
%token <string> STR

%% /* rules below */

litprog     : /**/ chunks EOF               {List.rev $1}
            | STR  chunks EOF               {LP.Doc($1) :: List.rev $2}
            ;

chunks      : chunks chunk                  {$2::$1}
            | /**/                          {[]}
            ;
            
chunk       : code                          {$1}
            | doc                           {$1}
            ;
            
doc         : AT STR ;                      {LP.Doc($2)}

code        : DEF body ;                    {LP.Code($1, List.rev $2)}
            
body        : body STR                      {LP.Str(position 2, $2)::$1}
            | body REF                      {LP.Ref(position 2, $2)::$1}
            | /**/                          {[]}
            ;   
%%
