# Challenge 03 — Browsing a Product Category

## Contexto

A vitrine virtual lista os produtos ativos de uma categoria, ordenados do mais
novo para o mais antigo, paginando 20 por vez. É a consulta mais executada do
site e precisa responder instantaneamente mesmo com o catálogo completo.

## Query

```sql
SELECT id, name, price_cents, created_at
FROM products
WHERE category = $category
  AND active = true
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

O avaliador testa várias categorias. **A query não pode ser alterada.**

## Metas

Você deve atingir, para **cada** categoria testada:

- resultado correto (o mesmo que uma varredura sequencial produziria);
- execução abaixo de **15 ms**;
- no máximo **60 buffers compartilhados**;
- o plano não pode conter um `Seq Scan` sobre `products`;
- o plano não pode conter um nó `Sort`.

## Regras

- Só é permitido alterar o banco.
- Não altere a query.
- Não altere os dados.
- Não remova constraints.
- Não faça hardcode para valores específicos.
- Índices são permitidos.

## Como investigar

- Repare que a consulta filtra e, ao mesmo tempo, pede uma ordem específica.
- Use `EXPLAIN (ANALYZE, BUFFERS)` e observe onde o tempo é gasto: na busca ou
  na ordenação dos resultados.

## Executando o avaliador

```bash
make test CHALLENGE=03
```

## Dicas

Veja [`hints.md`](hints.md).
