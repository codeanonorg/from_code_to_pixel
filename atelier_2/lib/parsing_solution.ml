(* --------------------------------- *)
(* - Atelier 2                     - *)
(* - Parseur Fonctionnel           - *)
(* --------------------------------- *)

(** Type représentant un parseur *)
type 'a parser = P of (string -> ('a * string) option)

(** Appliquer un parseur sur une chaîne *)
let parse (P p) inp = p inp

let pure v = P (fun inp -> Some (v, inp))

(* ------------------------------------------------- *)
(* Utils                                             *)
(* ------------------------------------------------- *)

(** Récupérer la queue d'une chaîne *)
let rest s =
  match s with
  | ""  -> ""
  | _   -> String.sub s 1 ((String.length s) - 1)

(* ------------------------------------------------- *)
(* Combinators                                       *)
(* ------------------------------------------------- *)

(** Créer un parseur qui reconnait une ou plusieurs fois le motif 
    reconnu par un autre parser *)
let rec many p = P (fun inp ->
    match parse p inp with
    | None -> None
    | Some (x, next) ->
      match parse (many p) next with
      | None -> Some ([x], next)
      | Some (l, next) -> Some (x::l, next)
  )

(** Créer un parseur qui reconnait zéro ou plusieurs fois le motif 
    reconnu par un autre parser *)
let some p = P (fun inp ->
    match parse p inp with
    | None -> Some ([], inp)
    | Some (x, next) ->
      match parse (many p) next with
      | None -> Some ([x], next)
      | Some (l, next) -> Some (x::l, next)
  )

(** Créer un parseur qui reconnait un motif, ou bien un autre *)
let alternative p q = P (fun inp ->
    match parse p inp with
    | None  -> parse q inp
    | x     -> x
  )

(** Raccourcis "infix" pour la fonction [alternative].
    alternative p q = p <|> q *)
let (<|>) = alternative

(** Créer un parseur qui applique une fonction sur le résultat d'un 
    parseur existant *)
let (<$>) f p = P (fun inp ->
    match parse p inp with
    | None -> None
    | Some(x, r) -> Some (f x, r)
  )

(** Operator de séquence *)
let (>>=) p f = P (fun inp ->
    match parse p inp with
    | Some (x, next) -> parse (f x) next
    | None -> None
  )

(** Syntaxe plus agréable pour l'opérateur de séquence.
    Exemple d'un parseur qui reconnait un nombre, puis une lettre et 
    retourne un couple :
    {
      let* nombre = parser_nombre in
      let* lettre = parser_lettre in
      P (fun inp -> Some (lettre, nombre, inp))
    } *)
let (let*) p f = p >>= f

(* ------------------------------------------------- *)
(* Parseurs de base                                  *)
(* ------------------------------------------------- *)

(** Parseur pour un caractère précis *)
let pchar c = P (fun inp ->
    match inp with
    | ""  -> None
    | s when s.[0] = c -> Some(s.[0], rest s)
    | _   -> None
  )

(** Parseur pour un espace blanc *)
let pblank = pchar ' ' <|> pchar '\n' <|> pchar '\t'

(** Parseur pour un nombre *)
let pnumber =
  let num = List.init 9 (fun i -> i + 48 |> char_of_int |> pchar) in
  List.fold_left (<|>) (pchar '9') num

(** Parseur pour un caractère de l'alphabet *)
let palpha =
  let alpha_lower = List.init 25 (fun i -> i + 49 |> char_of_int |> pchar) in
  let alpha_upper = List.init 25 (fun i -> i + 98 |> char_of_int |> pchar) in
  List.fold_left (<|>) (pchar 'a') alpha_lower
  <|>
  List.fold_left (<|>) (pchar 'A') alpha_upper

(** Parseur pour un symbole mathématique *)
let pmath = pchar '+'
            <|> pchar '-'
            <|> pchar '*'
            <|> pchar '/'
            <|> pchar '^'
            <|> pchar '('
            <|> pchar ')'
