# Challenge 08 — Segmenting Customers by Country and Status

## Contexto

O time de marketing monta campanhas para um recorte de clientes: todos de um
país, com um status de conta, cadastrados a partir de uma data. A lista é
ordenada do cadastro mais recente para o mais antigo e limitada aos primeiros
resultados para exportação.

## Query

```sql
SELECT id, full_name, country, plan, created_at
FROM customers
WHERE country = $country
  AND status = $status
  AND created_at >= $since
ORDER BY created_at DESC, id DESC
LIMIT 100;
```

O avaliador testa várias combinações de país, status e data. **A query não pode
ser alterada.**

## Metas

Você deve atingir, para **cada** combinação testada:

- resultado correto (o mesmo que uma varredura sequencial produziria);
- execução abaixo de **25 ms**;
- no máximo **400 buffers compartilhados**;
- o plano não pode conter um `Seq Scan` sobre `customers`;
- o plano não pode conter um nó `Sort`.

## Regras

- Só é permitido alterar o banco.
- Não altere a query.
- Não altere os dados.
- Não remova constraints.
- Não faça hardcode para valores específicos.
- Índices são permitidos.

## Como investigar

- Meça a seletividade de cada coluna do filtro isoladamente.
- Use `EXPLAIN (ANALYZE, BUFFERS)` e veja em que ponto da consulta as linhas são
  descartadas.

## Executando o avaliador

```bash
make test CHALLENGE=08
```

## Dicas

Veja [`hints.md`](hints.md).
