# Respostas

Aqui você registra a solução de cada desafio em SQL versionado. O banco em si é
o ambiente de experimentação; este diretório é o registro do que você fez.

## Fluxo

1. Escreva o SQL que altera o banco em `answers/NN.sql`.
2. Aplique no banco:

   ```bash
   make apply CHALLENGE=01
   ```

3. Rode o avaliador:

   ```bash
   make test CHALLENGE=01
   # ou, para aplicar e avaliar de uma vez:
   make solve CHALLENGE=01
   ```

4. Quando passar, faça o commit do seu arquivo.

```bash
git add answers/01.sql
git commit -m "solve(challenge-01): ..."
```

## Por que registrar em arquivo

- `make reset` apaga o volume e recria o banco original; o arquivo permite
  reaplicar sua resposta sem refazer o trabalho.
- O histórico do git guarda sua evolução por desafio.

## Idempotência

Prefira comandos que possam ser reaplicados sem erro, por exemplo:

```sql
DROP INDEX IF EXISTS meu_indice;
CREATE INDEX IF NOT EXISTS meu_indice ON ...;
```

Assim você pode rodar `make apply` várias vezes enquanto itera.

## Restaurar o laboratório e reaplicar

```bash
make reset
make wait
make apply CHALLENGE=01
make apply CHALLENGE=02
# ...
```

As respostas são independentes entre si; aplique apenas as que já resolveu.
