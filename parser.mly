%{
module S = Syntax
%}

%start litprog
%type <Syntax.chunk list> litprog

%token EOF 
%token <string> AT
%token <string> REF
%token <string> DEF
%token <string> STR

%% /* rules below */

litprog     : /**/ chunks EOF               {List.rev $1}
            | STR  chunks EOF               {S.Doc("",$1) :: List.rev $2}
            ;

chunks      : chunks chunk                  {$2::$1}
            | /**/                          {[]}
            ;
            
chunk       : code                          {$1}
            | doc                           {$1}
            ;
            
doc         : AT STR ;                      {S.Doc($1,$2)}

code        : DEF body ;                    {S.Code($1, List.rev $2)}
            
body        : body STR                      {S.Str($2)::$1}
            | body REF                      {S.Ref($2)::$1}
            | /**/                          {[]}
            ;   
%%
