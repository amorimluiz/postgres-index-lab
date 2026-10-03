# Challenge 10 — Dicas

## Dica 1

Só uma das duas tabelas da junção parece carecer de estrutura adequada. Descubra
qual delas está sendo lida por varredura completa.

## Dica 2

O problema é o mesmo dos desafios anteriores: filtro de igualdade, intervalo de
tempo e ordenação. A presença da junção não muda essa parte.

## Dica 3

Resolva a parte da tabela maior como um Top-N filtrado; a junção com a tabela
menor provavelmente já usa a chave primária. Confirme no `EXPLAIN` que o número
de acessos à tabela de clientes é proporcional ao `LIMIT`, e não ao total filtrado.
