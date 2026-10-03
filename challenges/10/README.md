# Challenge 10 — The Fulfilment Dashboard

## Contexto

O painel de expedição lista os pedidos em um determinado status, criados a
partir de uma data, do mais recente para o mais antigo, junto com o nome do
cliente. A consulta junta duas tabelas e precisa se manter rápida conforme o
histórico cresce.

## Query

```sql
SELECT o.id, o.status, o.total_cents, o.created_at, c.full_name
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.status = $status
  AND o.created_at >= $since
ORDER BY o.created_at DESC, o.id DESC
LIMIT 100;
```

O avaliador testa várias combinações de status e data. **A query não pode ser
alterada.**

## Metas

Você deve atingir, para **cada** combinação testada:

- resultado correto (o mesmo que uma varredura sequencial produziria);
- execução abaixo de **50 ms**;
- no máximo **2500 buffers compartilhados**;
- o plano não pode conter um `Seq Scan` sobre `orders`;
- o plano não pode conter um nó `Sort`.

## Regras

- Só é permitido alterar o banco.
- Não altere a query.
- Não altere os dados.
- Não remova constraints.
- Não faça hardcode para valores específicos.
- Índices são permitidos.

## Como investigar

- Identifique qual tabela é o gargalo e qual já tem índice suficiente.
- Use `EXPLAIN (ANALYZE, BUFFERS)` para ver quantas linhas de `orders` são
  processadas antes do `LIMIT` e quantas idas à tabela de clientes são feitas.

## Executando o avaliador

```bash
make test CHALLENGE=10
```

## Dicas

Veja [`hints.md`](hints.md).
