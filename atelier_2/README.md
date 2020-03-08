# Atelier 2 - Analyse syntaxique et programmation OCaml

L'objectif de cet atelier est d'initier les participants à la programmation fonctionnelle au travers de l'implémentation d'un module d'analyse syntaxique simple. Cet atelier sera l'occasion de découvrir le langage OCaml tout en explorant une technique rapide pour écrire des *parsers*.

## Prérequis

Aucune connaissance de la programmation fonctionnelle n'est supposée pour la réalisation de cet atelier.

Un environnement OCaml complet est indispensable pour réaliser l'atelier. Cependant, pour gagner du temps, l'atelier est accessible directement en ligne sur [replit]() !

## OCaml et Replit

Replit ne supporte pas encore bien OCaml, il faut passer par l'interpréteur interactif OCaml (*toplevel*). Voici une liste des commandes utiles :

+ **Executer un module** : `#use "monmodule.ml";;` dans la console replit
+ **Importer un module** : `#use "monmodule.ml";;` dans le fichier ocaml

## Les bases d'OCaml pour l'atelier

### "Variables" (bindings)

En OCaml, il n'y a pas de véritables variables (on ne peut pas changer le contenu d'une variable). On parle plutôt de **Liaisons** ou de bindings. Il faut réfléchir comme dans un énoncé de mathématique lorsque l'on introduit une variable en disant "Soit x un entier". Par ailleurs, il n'est pas nécessaire de préciser le type des variables, le compilateur le devine tout seul (il vaut mieux le laisser deviner, il est plus malin que nous).

```OCaml
let x = 3
(* val x : int = 3*)
let x = 3.
(* val x : float = 3*)
let x = "abcde"
(* val x : string = "abcde" *)
```

### Arithmétique

Le système de type d'OCaml est très exigeant (c'est ce qui permet au compilateur de deviner le type de toutes les expressions sans que l'on ait besoin de le préciser). En conséquence, il faut faire attention aux opérateurs arithmétiques qui diffèrent selon que les données soient des entiers ou des flottants.

```OCaml
let x = 1 + 2 (* addition entière *)
let x = 1. +. 2. (* addition flottante *)
```

### Fonctions

Qui dit programmation fonctionnelle dit fonction ! En OCaml, les fonctions sont des expressions comme les autres ! En particulier, on peut utiliser des opérateurs dessus, les traiter comme des valeurs, en faire des listes et même les passer en paramètres d'autres fonctions. Cela permet par exemple d'écrire des programmes très génériques.

```OCaml
let somme x y = x + y (* fonction simple *)
let somme = (+)  (* l'addition est une fonction aussi en fait ... *)

let somme = fun x y -> x + y (* fonction anonymes *)
```

```OCaml
let resultat = somme 1 2  (* application *)
let ajouter_1 = somme 1   (* application partielle *)
```

### Listes et chaînes

```OCaml
let liste = [1; 2; 3]
let somme = List.fold_left (+) 0 liste
let afficher_liste l = List.iter (Printf.printf "%d\n") l
let doubler = List.map (( * ) 2) liste (* <=> List.map (fun x -> 2*x) liste *)
let long = List.length liste
let liste' = 0::liste (* = [0; 1; 2; 3] *)
let liste'' = 0::1::2::3::[] (* = [0; 1; 2; 3] *)
let concat = [1; 2; 3] @ [4; 5; 6] (* = [1; 2; 3; 4; 5; 6] *)
```

```OCaml
let chaine = "hello"
let long = String.length "hello"
let substring = String.sub 0 2 "hello" (* "He" *)
let char_at = "hello".[0] (* 'h' *)
```

### Déclaration de types

```OCaml
(* types de base *)
int
char
string
float
'a list (* int list, char list ... *)

(* Variantes et types récursifs *)
type int_tree =
  | Node of int_tree * int_tree
  | Leaf of int

let mon_arbre = Node (Node (Leaf 1, Leaf 2), Node (Leaf 3, Leaf 4))

(* Types à paramètres *)
type 'a tree =
  | Node of tree * tree
  | Leaf of 'a
```

### Filtrage de motifs et fonctions récursives

On a pas de boucles en langage OCaml, par contre on a une structure très élégante pour écrire des fonctions récursives fiables : le filtrage de motif. Si on définit un type récursif (voir au dessus), on peut aussi définir des fonctions sur ce type. On raisonne comme une preuve par récurrence : on traite séparément le cas de base (sans appel récursif) et le cas récursif. Si on oublie un cas, le compilateur nous prévient et refuse de compiler !

```OCaml
(* filtrage sur les listes *)
let rec afficher_liste l =
  match l with
  (* Cas de base *)
  | []        -> ()
  (* Cas récursif *)
  | x::reste  -> Printf.printf "%d\n" x; afficher_liste reste

(* fonction sur nos arbres (voir ci dessus) *)
let rec somme_des_feuilles arbre =
  match arbre with
  | Leaf n -> n
  | Node (left, right) -> (somme_des_feuilles left) + (somme_des_feuilles right)
```




