# Challenge 09 — Session Ingest vs. Session Lookups

## Contexto

A tabela `sessions` acumulou estruturas ao longo do tempo, adicionadas por
diferentes otimizações pontuais. Ao mesmo tempo, o sistema precisa continuar
atendendo duas leituras importantes e absorver um volume alto de escrita
(inserção, atualização e remoção de sessões). Hoje, a escrita virou o gargalo.

Diferente dos desafios anteriores, aqui o objetivo **não** é apenas deixar uma
consulta mais rápida: é equilibrar leitura e escrita. Toda estrutura extra tem
um custo.

## Leituras que precisam continuar rápidas

### R1 — Sessões recentes de um cliente

```sql
SELECT id, status, device, created_at
FROM sessions
WHERE customer_id = $customer_id
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

Metas, para cada cliente testado:

- resultado correto;
- o plano não pode conter um `Seq Scan` sobre `sessions`;
- o plano não pode conter um nó `Sort`;
- no máximo **60 buffers compartilhados**;
- execução abaixo de **30 ms**.

### R2 — Contagem de sessões ativas recentes

```sql
SELECT count(*)
FROM sessions
WHERE status = 'active'
  AND created_at >= $since;
```

Metas:

- resultado correto;
- o plano não pode conter um `Seq Scan` sobre `sessions`;
- no máximo **200 buffers compartilhados**;
- execução abaixo de **30 ms**.

## Escrita que precisa melhorar

O avaliador executa um lote fixo de `INSERT`, `UPDATE` e `DELETE` sobre
`sessions`, sempre dentro de uma transação revertida (os dados não mudam). A
métrica usada é a quantidade de WAL gerada pelo lote, que é independente do
hardware.

Metas:

- WAL gerada no lote **abaixo de 130 MB**;
- tamanho total somado de todos os índices de `sessions` **abaixo de 170 MB**.

## Regras

- Só é permitido alterar o banco.
- Não altere as queries.
- Não altere os dados.
- Não remova constraints.
- Não faça hardcode para valores específicos.
- Índices podem ser criados e removidos.

## Como investigar

- Liste todas as estruturas existentes na tabela e o tamanho de cada uma.
- Use `EXPLAIN (ANALYZE, BUFFERS)` nas duas leituras.
- Observe quais estruturas são atualizadas em cada `INSERT`/`UPDATE`/`DELETE`.
- Pergunte-se quais estruturas são redundantes entre si para as leituras exigidas.

## Executando o avaliador

```bash
make test CHALLENGE=09
```

O benchmark avulso pode ser rodado com:

```bash
make bench
```

## Dicas

Veja [`hints.md`](hints.md).
