(* --------------------------------- *)
(* - Atelier 2                     - *)
(* - Parseur Fonctionnel           - *)
(* --------------------------------- *)

(** Type représentant un parseur *)
type 'a parser = P of (string -> ('a * string) option)

(** Appliquer un parseur sur une chaîne *)
let parse (P p) inp = p inp

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

(** Créer un parseur qui reconnait un motif, ou bien un autre *)
let alternative (p:'a parser) (q:'a parser) = P (fun inp ->
    (* à compléter *)
  )

(** Créer un parseur qui reconnait une ou plusieurs fois le motif 
    reconnu par un autre parser *)
let rec many (p:'a parser) = P (fun inp ->
    (* à compléter *)
  )

(** Créer un parseur qui reconnait zéro ou plusieurs fois le motif 
    reconnu par un autre parser *)
let some (p:'a parser) = P (fun inp ->
    (* à compléter *)
  )


(** Raccourcis "infix" pour la fonction [alternative].
    alternative p q = p <|> q *)
let (<|>) = alternative

(** Créer un parseur qui applique une fonction sur le résultat d'un 
    parseur existant *)
let fmap f p = P (fun inp ->
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
    (* à compléter *)
  )

(** Parseur pour un espace blanc *)
let pblank = () (* à compléter *)

(** Parseur pour un nombre *)
let pnumber = () (* à compléter *)

(** Parseur pour un caractère de l'alphabet *)
let palpha = () (* à compléter *)

(** Parseur pour un symbole mathématique *)
let pmath = () (* à compléter *)