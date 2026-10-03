# Challenge 06 — Payment Details for an Order

## Contexto

O serviço de conciliação busca, para um pedido, o valor e a situação dos seus
pagamentos. A consulta é chamada milhares de vezes por minuto durante o
fechamento financeiro e não pode tocar as páginas da tabela mais do que o
estritamente necessário.

## Query

```sql
SELECT order_id, amount_cents, status
FROM payments
WHERE order_id = $order_id;
```

O avaliador testa vários pedidos. **A query não pode ser alterada.**

## Metas

Você deve atingir, para **cada** pedido testado:

- resultado correto (o mesmo que uma varredura sequencial produziria);
- execução abaixo de **20 ms**;
- no máximo **15 buffers compartilhados**;
- o plano não pode conter um `Seq Scan` sobre `payments`;
- o plano deve conter um nó **`Index Only Scan`**.

## Regras

- Só é permitido alterar o banco.
- Não altere a query.
- Não altere os dados.
- Não remova constraints.
- Não faça hardcode para valores específicos.
- Índices são permitidos.

## Como investigar

- Liste exatamente as colunas usadas no filtro e as devolvidas no `SELECT`.
- Use `EXPLAIN (ANALYZE, BUFFERS)` e compare um plano que ainda visita as
  páginas da tabela com um que não precisa visitá-las.
- Só faz sentido pedir um plano `Index Only Scan` quando o índice já contém
  todas as colunas de que a consulta precisa.

## Executando o avaliador

```bash
make test CHALLENGE=06
```

## Dicas

Veja [`hints.md`](hints.md).
