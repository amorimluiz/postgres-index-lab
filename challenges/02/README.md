# Challenge 02 — A Customer's Orders by Status

## Contexto

A tela de conta do cliente mostra os pedidos de um cliente filtrados por
situação (por exemplo, apenas os pagos, apenas os cancelados). A consulta é
disparada a cada carregamento de tela e, com o volume atual de pedidos, já
aparece nos relatórios de latência.

## Query

```sql
SELECT id, status, total_cents, created_at
FROM orders
WHERE customer_id = $customer_id
  AND status = $status;
```

O avaliador testa vários pares `($customer_id, $status)`. **A query não pode ser
alterada.**

## Metas

Você deve atingir, para **cada** combinação testada:

- resultado correto (o mesmo que uma varredura sequencial produziria);
- execução abaixo de **20 ms**;
- no máximo **15 buffers compartilhados**;
- o plano não pode conter um `Seq Scan` sobre `orders`.

## Regras

- Só é permitido alterar o banco.
- Não altere a query.
- Não altere os dados.
- Não remova constraints.
- Não faça hardcode para valores específicos.
- Índices são permitidos.

## Como investigar

- Use `EXPLAIN (ANALYZE, BUFFERS)` para ver como o filtro está sendo resolvido.
- Pense na ordem em que as condições são avaliadas e em quantas linhas cada uma
  elimina.

## Executando o avaliador

```bash
make test CHALLENGE=02
```

## Dicas

Veja [`hints.md`](hints.md).
