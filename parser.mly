%{
%}

%start litprog
%type <unit> litprog

%token EOF AT REF DEF 
%token <string> STR

%% /* rules below */

litprog 	: /**/ chunks EOF				{()}
			| STR  chunks EOF 				{()}
			;

chunks 		: chunks chunk					{()}
			| /**/							{()}
			;
			
chunk 		: code							{()}
			| doc							{()}
			;
			
doc 		: AT STR ;						{()}

code 		: DEF body ;					{()}
			
body 		: body STR						{()}
			| body REF						{()}
			| /**/							{()}
			;	
%%
