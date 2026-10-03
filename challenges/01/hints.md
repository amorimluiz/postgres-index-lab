# Challenge 01 — Dicas

Use uma por vez. Leia a próxima apenas se a anterior não for suficiente.

## Dica 1

Observe quantas linhas da tabela a consulta precisa ler para devolver uma única
linha, e compare com o total de linhas existentes.

## Dica 2

O PostgreSQL precisa de uma estrutura que permita localizar diretamente as
linhas que satisfazem o filtro, sem inspecionar todas as páginas da tabela.

## Dica 3

Considere quais estruturas o PostgreSQL mantém separadas dos dados da tabela e
que podem ser consultadas por um valor de coluna. Verifique em `EXPLAIN` qual
tipo de nó aparece quando o planejador decide usá-las.
