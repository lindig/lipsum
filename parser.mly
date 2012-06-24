%{
module LP = Litprog
module P  = Parsing
module L  = Lexing
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

code        : DEF body ;        {   let p    = P.rhs_start_pos 2 in
                                    let pos  = { LP.file = p.L.pos_fname
                                               ; LP.line = p.L.pos_lnum
                                               ; LP.column = p.L.pos_cnum
                                               }
                                    in LP.Code($1, LP.Sync(pos)::List.rev $2)
                                }
            
body        : body STR                      {LP.Str($2)::$1}
            | body REF                      {LP.Ref($2)::$1}
            | /**/                          {[]}
            ;   
%%
