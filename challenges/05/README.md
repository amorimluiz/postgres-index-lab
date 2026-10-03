# Challenge 05 — The Recent Events Feed

## Contexto

Uma tela interna mostra os eventos mais recentes do sistema, em tempo real. Ela
usa paginação por cursor: o cliente envia o instante do último item recebido e o
servidor devolve os itens anteriores a esse instante. Não há filtro por cliente
ou tipo — apenas a ordenação temporal.

## Query

```sql
SELECT id, customer_id, event_type, created_at
FROM events
WHERE created_at < $cursor
ORDER BY created_at DESC, id DESC
LIMIT 100;
```

O avaliador testa vários valores de `$cursor`. **A query não pode ser alterada.**

## Metas

Você deve atingir, para **cada** cursor testado:

- resultado correto (o mesmo que uma varredura sequencial produziria);
- execução abaixo de **60 ms**;
- no máximo **400 buffers compartilhados**;
- o plano não pode conter um `Seq Scan` sobre `events`;
- o plano não pode conter um nó `Sort`.

## Regras

- Só é permitido alterar o banco.
- Não altere a query.
- Não altere os dados.
- Não remova constraints.
- Não faça hardcode para valores específicos.
- Índices são permitidos.

## Como investigar

- Entenda o padrão "Top-N": a consulta quer apenas as primeiras linhas na ordem
  definida.
- Use `EXPLAIN (ANALYZE, BUFFERS)` e observe quantas linhas o banco precisa
  processar antes de poder aplicar o `LIMIT`.

## Executando o avaliador

```bash
make test CHALLENGE=05
```

## Dicas

Veja [`hints.md`](hints.md).
