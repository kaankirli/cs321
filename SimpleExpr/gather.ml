#use "simpleExpr.ml";;
#use "grammar.ml";;
#use "lexer.ml";;

let parse s = main tokenize (Lexing.from_string s)

let run s =
  let e = parse s in
  try
    let _ = typeOf e []
    in eval e []
  with Failure f ->
    failwith f

