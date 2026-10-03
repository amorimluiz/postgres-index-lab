# Challenge 04 — A Customer's Activity Timeline

## Contexto

O painel de um cliente exibe as atividades mais recentes de um tipo específico
dentro de uma janela de tempo. A consulta alimenta um gráfico de uso e roda a
cada alguns segundos para muitos clientes simultâneos.

## Query

```sql
SELECT id, event_type, entity_type, entity_id, created_at
FROM events
WHERE customer_id = $customer_id
  AND event_type = $event_type
  AND created_at >= $since
ORDER BY created_at DESC, id DESC
LIMIT 50;
```

O avaliador testa várias combinações de cliente, tipo e data. **A query não pode
ser alterada.**

## Metas

Você deve atingir, para **cada** combinação testada:

- resultado correto (o mesmo que uma varredura sequencial produziria);
- execução abaixo de **30 ms**;
- no máximo **40 buffers compartilhados**;
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

- Separe mentalmente o filtro em partes: quais colunas usam igualdade e qual usa
  comparação de intervalo.
- Use `EXPLAIN (ANALYZE, BUFFERS)` para ver quantas linhas entram em cada etapa
  antes do `LIMIT`.

## Executando o avaliador

```bash
make test CHALLENGE=04
```

## Dicas

Veja [`hints.md`](hints.md).
