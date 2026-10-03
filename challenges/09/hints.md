# Challenge 09 — Dicas

## Dica 1

Toda estrutura de índice precisa ser atualizada em cada escrita. Reduzir a
quantidade/sobreposição de estruturas que servem às mesmas leituras reduz o
custo de escrita.

## Dica 2

Procure estruturas cujas colunas iniciais já são cobertas por outra estrutura
maior. Uma leitura de igualdade por prefixo pode ser atendida por uma estrutura
mais completa.

## Dica 3

Você provavelmente precisará adicionar uma estrutura para uma das leituras e
remover várias outras que se tornaram redundantes. Verifique, com `EXPLAIN`, se
cada leitura continua sem `Seq Scan` e sem `Sort` depois das remoções, e compare
o WAL do lote antes e depois.
