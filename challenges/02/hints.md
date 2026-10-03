# Challenge 02 — Dicas

## Dica 1

Há duas colunas no filtro. Uma estrutura que acelere apenas uma delas ainda
pode deixar trabalho demais para o banco.

## Dica 2

Considere uma estrutura que trate as duas colunas do filtro em conjunto, e não
duas estruturas separadas.

## Dica 3

Quando mais de uma coluna participa do mesmo filtro de igualdade, a ordem em
que elas aparecem na estrutura influencia quais consultas conseguem usá-la por
completo. Compare o plano obtido com um filtro que use apenas a primeira coluna
da estrutura.
