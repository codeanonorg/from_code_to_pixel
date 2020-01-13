# Atelier 1 - Introduction

Dans ce premier atelier, l'objectif est d'implémenter en [python3](https://python.org) un petit émulateur de console rétro. La console que nous allons émuler s'appelle [**CHIP8**](https://https://en.wikipedia.org/wiki/CHIP-8). A la fin de la séance, votre émulateur devrait être capable de lancer la cartouche de jeu `secret.rom`.


## Les outils

Avant de commencer à programmer, assurez vous de bien avoir tous les outils nécessaires. Nous allons avoir besoin de :
+ [**python3**](https://python.org) pour programmer l'émulateur
+ [**pygame**](https://www.pygame.org/wiki/GettingStarted) pour gérer l'affichage graphique de notre console.

Pour toute question relative à l'installation de ces outils, n'hésitez pas à poser des questions !

## L'atelier

Tout au long de cet atelier, vous allez programmer dans le fichier `CHP8.py`. Il contient déjà quelques fonctions utiles pour le bon fonctionnement de notre émulateur. Ici, nous nous intéressons seulement à la partie **décodage des instructions binaires**. Pour cela, il vous est demandé de compléter la fonction `execute_next_instruction`. Le reste du fichier peut rester inchangé.

## Documentation

En cas de besoin, différentes documentations peuvent-être utiles :

+ [**spécifications techniques de CHIP8**](http://devernay.free.fr/hacks/chip8/C8TECH10.HTM)
+ [**opérateurs python**](https://fr.wikibooks.org/wiki/Programmation_Python/Op%C3%A9rateurs)
+ [**opérateurs logiques bit à bit**](https://fr.wikipedia.org/wiki/Op%C3%A9ration_bit_%C3%A0_bit)