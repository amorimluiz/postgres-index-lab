# Challenge 07 — Dicas

## Dica 1

A consulta sempre filtra pelo mesmo valor de uma coluna de baixa cardinalidade.
Pergunte-se se vale a pena indexar todas as linhas, ou apenas as que interessam.

## Dica 2

O PostgreSQL permite criar estruturas que valem apenas para um subconjunto das
linhas, definido por uma condição. Elas ficam menores e mais baratas de manter.

## Dica 3

Uma estrutura com condição só é usada quando o filtro da consulta é compatível
com a condição declarada. Combine essa ideia com a ordenação pedida, lembrando
que a coluna do intervalo de tempo pode ficar depois das igualdades.
