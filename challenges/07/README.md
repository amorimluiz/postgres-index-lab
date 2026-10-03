# Challenge 07 — Pending Orders Awaiting Action

## Contexto

Um painel operacional traz continuamente os pedidos que estão pendentes e foram
criados a partir de uma data, do mais recente para o mais antigo, para a fila de
atendimento. A maior parte dos pedidos já foi processada; os pendentes são uma
fração pequena do total.

## Query

```sql
SELECT id, customer_id, total_cents, created_at
FROM orders
WHERE status = 'pending'
  AND created_at >= $since
ORDER BY created_at DESC, id DESC
LIMIT 50;
```

O avaliador testa vários valores de `$since`. **A query não pode ser alterada.**

## Metas

Você deve atingir, para **cada** data testada:

- resultado correto (o mesmo que uma varredura sequencial produziria);
- execução abaixo de **30 ms**;
- no máximo **200 buffers compartilhados**;
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

- Descubra a distribuição dos valores de `status` na tabela.
- Use `EXPLAIN (ANALYZE, BUFFERS)`. Pergunte-se se faz sentido manter
  informação para linhas que a consulta nunca vai devolver.

## Executando o avaliador

```bash
make test CHALLENGE=07
```

## Dicas

Veja [`hints.md`](hints.md).
