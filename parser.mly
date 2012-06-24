%{
module S = Syntax
module P = Parsing
module L = Lexing
%}

%start litprog
%type <Syntax.chunk list> litprog

%token EOF AT
%token <string> REF
%token <string> DEF
%token <string> STR

%% /* rules below */

litprog     : /**/ chunks EOF               {List.rev $1}
            | STR  chunks EOF               {S.Doc($1) :: List.rev $2}
            ;

chunks      : chunks chunk                  {$2::$1}
            | /**/                          {[]}
            ;
            
chunk       : code                          {$1}
            | doc                           {$1}
            ;
            
doc         : AT STR ;                      {S.Doc($2)}

code        : DEF body ;        {   let p    = P.rhs_start_pos 2 in
                                    let pos  = { S.file = p.L.pos_fname
                                               ; S.line = p.L.pos_lnum
                                               ; S.column = p.L.pos_cnum
                                               }
                                    in S.Code($1, S.Sync(pos)::List.rev $2)
                                }
            
body        : body STR                      {S.Str($2)::$1}
            | body REF                      {S.Ref($2)::$1}
            | /**/                          {[]}
            ;   
%%
