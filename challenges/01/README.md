# Challenge 01 — Locating an Event by Request

## Contexto

O time de suporte recebe o identificador de requisição de um evento e precisa
encontrar, em poucos milissegundos, o registro completo daquele evento para
investigar um incidente. Com o crescimento da tabela de telemetria, essa busca
passou a demorar o suficiente para irritar quem atende o chamado.

## Query

```sql
SELECT id, customer_id, event_type, entity_type, entity_id, created_at
FROM events
WHERE request_id = $request_id;
```

O valor de `$request_id` é substituído pelo avaliador por vários identificadores
diferentes. **A query não pode ser alterada.**

## Metas

Você deve atingir, para **cada** valor testado:

- resultado correto (o mesmo que uma varredura sequencial produziria);
- execução abaixo de **30 ms**;
- no máximo **25 buffers compartilhados**;
- o plano não pode conter um `Seq Scan` sobre `events`.

## Regras

- Só é permitido alterar o banco.
- Não altere a query.
- Não altere os dados.
- Não remova constraints.
- Não faça hardcode para valores específicos.
- Índices são permitidos.

## Como investigar

- Use `EXPLAIN (ANALYZE, BUFFERS)` para entender o plano atual.
- Compare o custo estimado com o número de linhas que a consulta realmente
  precisa devolver.
- Leia a documentação do PostgreSQL sobre os diferentes tipos de varredura.

## Executando o avaliador

```bash
make test CHALLENGE=01
```

## Dicas

Veja [`hints.md`](hints.md) se precisar de ajuda progressiva.
