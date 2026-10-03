# Benchmarks

## `write_tradeoff.sql`

Mede o custo de escrita da tabela `sessions`. O lote executa `INSERT`, `UPDATE`
e `DELETE` dentro de uma transação que é sempre revertida, portanto os dados
nunca mudam e o benchmark pode ser repetido quantas vezes você quiser.

```bash
make bench
# ou
docker compose exec -T db psql -U postgres -d indexlab < benchmarks/write_tradeoff.sql
```

A métrica principal é a quantidade de **WAL** gerada pelo lote. WAL é uma boa
métrica porque não depende do hardware: o mesmo conjunto de índices produz
aproximadamente o mesmo volume de WAL em qualquer máquina. O tempo decorrido é
mostrado apenas como referência.

Antes de medir, o benchmark força um `CHECKPOINT` para estabilizar a geração de
WAL entre execuções.

O benchmark é o mesmo usado pelo avaliador do desafio 09. Veja
[`challenges/09/README.md`](../challenges/09/README.md).
