# Challenge 06 — Dicas

## Dica 1

O filtro usa uma coluna, mas o `SELECT` devolve outras duas além dela. Um índice
sobre o filtro leva o banco até as linhas, mas ainda exige ler a tabela para
buscar as colunas restantes.

## Dica 2

Se o índice já carregasse todas as colunas que a consulta lê, o banco poderia
responder sem tocar nas páginas da tabela.

## Dica 3

O PostgreSQL permite que uma definição de índice carregue colunas extras que não
participam da busca, apenas para estarem disponíveis na leitura. Verifique em
`EXPLAIN` qual nó aparece quando o índice cobre todas as colunas pedidas e
garanta que as estatísticas/visibilidade estejam em dia.
