%{


%}

%token <int> INTEGER
%token <string> NAME
%token EOF
%token PLUS STAR MINUS SLASH
%token LET EQ IN
%token LEFTANGLE
%token IF THEN ELSE
%token LPAR RPAR
%token NOT
%token GTEQ
%token MIN MAX COMMA
%token FST SND
%token MATCH WITH ARROW
%token FUN
%token COLON INTTY BOOLTY 

/* Precedence definitions: */
/* lowest precedence  */
%right ARROW      /* right assoc in type annotations. E.g. int -> int -> int */ 
%nonassoc IN ELSE
%left EQ
%nonassoc LEFTANGLE GTEQ
%left PLUS MINUS
%left STAR SLASH
/* highest precedence  */

%start main
%type <expr> main

%%

main:
    expression EOF                     { $1 }
;

expression:
    atomExpr                           { $1 }
  | expression PLUS expression         { Prim("+", $1, $3)  }
  | expression STAR expression         { Prim("*", $1, $3)  }
  | expression MINUS expression        { Prim("-", $1, $3) }
  | expression SLASH expression        { Prim("/", $1, $3) }
  | expression EQ expression           { Prim("=", $1, $3) }
  | expression LEFTANGLE expression    { Prim("<", $1, $3) }
  | expression GTEQ expression         { Unary("not", Prim("<", $1, $3)) }
  | LET NAME params EQ expression IN expression
                                       { Let($2, List.fold_right (fun (x,t) e -> Fun(x,t,e)) $3 $5, $7) }
  | IF expression THEN expression ELSE expression { If($2, $4, $6) }
  | MATCH expression WITH LPAR NAME COMMA NAME RPAR ARROW expression
                                       { MatchPair($2, $5, $7, $10) }
  | FUN LPAR NAME COLON aType RPAR params ARROW expression
                                       { Fun($3, $5, List.fold_right (fun (x,t) e -> Fun(x,t,e)) $7 $9) }
  | appExpr                            { $1 }
;

atomExpr:
    INTEGER                            { CstI $1 }
  | NAME                               { Var $1  }
  | LPAR expression RPAR               { $2 }
  | NOT LPAR expression RPAR           { Unary("not", $3) }
  | MIN LPAR expression COMMA expression RPAR { Prim("min", $3, $5) }
  | MAX LPAR expression COMMA expression RPAR { Prim("max", $3, $5) }
  | LPAR expression COMMA expression RPAR { Prim(",", $2, $4) }
  | FST LPAR expression RPAR           { Unary("fst", $3) }
  | SND LPAR expression RPAR           { Unary("snd", $3) }
;

appExpr:
    atomExpr atomExpr                  { App($1, $2) }
  | appExpr atomExpr                   { App($1, $2) }
;

params:
    /* empty */                        { [] }
  | LPAR NAME COLON aType RPAR params  { ($2,$4)::$6 }
;

aType:
    INTTY                              { IntTy }
  | BOOLTY                             { BoolTy }
  | aType ARROW aType                  { FunTy($1, $3) }
  | LPAR aType STAR aType RPAR         { PairTy($2, $4) }
  | LPAR aType RPAR                    { $2 }
;

%%
