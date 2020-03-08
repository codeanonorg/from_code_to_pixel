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
  P (fun inp -> Some (cons a b, inp))

let rec parser_expression input = 
  let parser =
    (
      let* a = P parser_terme in
      let* _ = some (pblank) in
      let* _ = pchar '+' in
      let* _ = some (pblank) in
      let* b = P parser_expression in
      P (fun inp -> Some (Addition (a, b), inp))
    )
    <|>
    (
      let* a = P parser_terme in
      let* _ = some (pblank) in
      let* _ = pchar '-' in
      let* _ = some (pblank) in
      let* b = P parser_terme in
      P (fun inp -> Some (Soustraction (a, b), inp))
    )
    <|> P parser_terme
  in
  parse parser input
and parser_terme input =
  let parser =
    (
      let* a = P parser_facteur in
      let* _ = some (pblank) in
      let* _ = pchar '*' in
      let* _ = some (pblank) in
      let* b = P parser_terme in
      P (fun inp -> Some (Multiplication (a, b), inp))
    )
    <|>
    (
      let* a = P parser_facteur in
      let* _ = some (pblank) in
      let* _ = pchar '/' in
      let* _ = some (pblank) in
      let* b = P parser_terme in
      P (fun inp -> Some (Division (a, b), inp))
    )
    <|> P parser_facteur
  in
  parse parser input

and parser_facteur input =
  let parser =
    (
      let* _ = pchar '(' in
      let* _ = some (pblank) in
      let* e = P parser_expression in
      let* _ = some (pblank) in
      let* _ = pchar ')' in
      P (fun inp -> Some (e, inp))
    )
    <|> (pnumber |> fmap (fun x -> Number (int_of_char x - 48)))
  in
  parse parser input

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