(* --------------------------------- *)
(* - Atelier 2                     - *)
(* - Expressions arithmétiques     - *)
(* --------------------------------- *)

open Parsing_solution

type expression =
  | Addition of expression * expression
  | Soustraction of expression * expression
  | Multiplication of expression * expression
  | Division of expression * expression
  | Number of int

let rec print_expression e =
  match e with
  | Number n -> print_int n
  | Addition (a, b) ->
    print_char '(';
    print_expression a;
    print_string " + ";
    print_expression b;
    print_char ')';
  | Soustraction (a, b) ->
    print_char '(';
    print_expression a;
    print_string " - ";
    print_expression b;
    print_char ')'
  | Multiplication (a, b) ->
    print_char '(';
    print_expression a;
    print_string " * ";
    print_expression b;
    print_char ')'
  | Division (a, b) ->
    print_char '(';
    print_expression a;
    print_string " / ";
    print_expression b;
    print_char ')'


let binop cons c p =
  let* a = p in
  let* _ = some (pblank) in
  let* _ = pchar c in
  let* _ = some (pblank) in
  let* b = p in
  pure (cons a b)

let wraped l r p =
  let* _ = l in
  let* v = p in
  let* _ = r in
  pure v


let rec parser_factor inp =
  let p =
    (fun x -> Number (int_of_char x - 48)) <$> pnumber
    <|>
    wraped (pchar '(') (pchar ')') (P parser_expression)
  in
  parse p inp
and parser_terme inp =
  let p =
    binop (fun a b -> Multiplication (a, b)) '*' (P parser_factor)
    <|>
    binop (fun a b -> Division (a, b)) '/' (P parser_factor)
    <|>
    P parser_factor
  in
  parse p inp
and parser_expression inp = 
  let p =
    binop (fun a b -> Addition (a, b)) '+' (P parser_terme)
    <|>
    binop (fun a b -> Soustraction (a, b)) '-' (P parser_terme)
    <|>
    P parser_terme
  in
  parse p inp


let result expr x =
  print_endline (expr ^ ":");
  print_char '\t';
  print_expression x |> print_newline

let test1 =
  let expr = "(1+2)*3" in
  match parser_expression expr with
  | Some(x, "") -> result expr x
  | _ -> failwith "parsing error"

let test2 =
  let expr = "1+2*3" in
  match parser_expression expr with
  | Some(x, "") -> result expr x
  | _ -> failwith "parsing error"

let test3 =
  let expr = "(2*3)+(2*3)" in
  match parser_expression expr with
  | Some(x, "") -> result expr x
  | _ -> failwith "parsing error"

let test4 =
  let expr = "(1 - 1) - 1" in
  match parser_expression expr with
  | Some(x, "") -> result expr x
  | _ -> failwith "parsing error"

let test5 =
  let expr = "1 - (1 - 1)" in
  match parser_expression expr with
  | Some(x, "") -> result expr x
  | _ -> failwith "parsing error"

let test6 =
  let expr = "(1 - 2) + 3" in
  match parser_expression expr with
  | Some(x, "") -> result expr x
  | _ -> failwith "parsing error"