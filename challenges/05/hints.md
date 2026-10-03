# Challenge 05 — Dicas

## Dica 1

A consulta não filtra por igualdade. O que ela realmente faz é pedir "os
próximos itens antes deste instante", sempre na mesma direção.

## Dica 2

Se a tabela não oferece nenhuma ordem, o banco precisa materializar e ordenar
tudo antes de cortar as primeiras linhas. Uma estrutura ordenada permitiria
parar assim que tivesse as primeiras.

## Dica 3

Quando só existe uma coluna de ordenação principal, uma estrutura sobre essa
coluna (na direção correta) é suficiente para o banco ler apenas o começo da
faixa. Avalie se incluir a coluna de desempate na estrutura ajuda a garantir o
resultado sem ordenação adicional.
