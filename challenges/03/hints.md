# Challenge 03 — Dicas

## Dica 1

A consulta faz duas coisas: seleciona um subconjunto de linhas e devolve essas
linhas em uma ordem específica. O `EXPLAIN` mostra qual etapa está custando.

## Dica 2

Se os dados já estivessem armazenados na ordem pedida pelo `ORDER BY`, dentro de
cada combinação de filtro, a etapa de ordenação poderia desaparecer.

## Dica 3

É possível declarar a direção de ordenação ao descrever as colunas de uma
estrutura de índices. Quando o filtro tem mais de uma coluna, pense na posição
relativa entre as colunas de igualdade e a coluna usada na ordenação.
