# Challenge 08 — Dicas

## Dica 1

Há duas igualdades e um intervalo, além da ordenação. Vale a pena comparar a
seletividade das duas colunas de igualdade antes de decidir o que vem primeiro.

## Dica 2

Assim como nos desafios anteriores, uma estrutura pode resolver filtro e
ordenação de uma só vez, desde que a ordem das colunas respeite o que a consulta
pede.

## Dica 3

A coluna do intervalo deve ficar depois das colunas de igualdade para que a
estrutura seja aproveitada por igualdade + faixa. Avalie também se a direção da
ordenação pode ser embutida na definição, evitando a etapa de ordenação.
