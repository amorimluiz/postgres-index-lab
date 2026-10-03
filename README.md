# PostgreSQL Index Lab

Um laboratório prático para aprender a **projetar índices e otimizar queries no
PostgreSQL através de investigação**, e não de memorização.

O repositório entrega um banco de dados propositalmente mal indexado, uma
sequência de desafios com metas mensuráveis e um avaliador automático. Você
resolve cada desafio alterando apenas o banco (índices, estatísticas, schema
físico) e roda o avaliador para saber se atingiu as metas.

## Como funciona

```text
Você recebe um problema + uma query + metas
        ↓
Investiga o banco com EXPLAIN / EXPLAIN (ANALYZE, BUFFERS)
        ↓
Altera o banco (cria/remove índices, etc.)
        ↓
Roda o avaliador
        ↓
PASS / FAIL
        ↓
Próximo desafio
```

O avaliador mede **comportamento**, não nomes de índices. Uma mesma meta pode
ser atingida por caminhos diferentes.

## Pré-requisitos

- Docker
- Docker Compose (v2)
- `make` (opcional, mas recomendado)

Não é necessário ter o PostgreSQL nem o `psql` instalados na máquina.

## Subindo o ambiente

```bash
docker compose up -d
```

Na primeira execução o banco é criado e populado automaticamente (cerca de
**11 milhões de linhas**). Isso leva alguns minutos. Para acompanhar:

```bash
docker compose logs -f db
```

Aguarde as mensagens de `VACUUM`/`ANALYZE`. Quando o log parar, o banco está
pronto. Você também pode usar:

```bash
make up
make wait
```

## Conectando ao banco

Existem dois papéis:

- `student` — é com ele que você trabalha. Não é superusuário.
- `postgres` — usado apenas pelo avaliador.

```bash
# via make
make student

# ou diretamente
docker compose exec db psql -U student -d indexlab
```

O banco se chama `indexlab` e o PostgreSQL fica exposto na porta **55432** da
máquina host.

## Rodando os desafios

Cada desafio tem uma página própria em `challenges/NN/README.md`, com contexto,
query, metas e regras. Os desafios ficam progressivamente mais difíceis.

Comece pelo [`challenges/01/README.md`](challenges/01/README.md).

## Registrando sua resposta

Sua solução é um arquivo SQL versionado: `answers/NN.sql` (um por desafio).
Você experimenta no banco à vontade e registra ali o SQL que resolve o desafio
(índices, estatísticas, schema físico — o que for). Nada de solução em markdown.

```bash
# escreva answers/01.sql e aplique no banco
make apply CHALLENGE=01

# aplique e já avalie
make solve CHALLENGE=01
```

### Reset reverso

Para reconstruir o banco original e reaplicar, em ordem, todas as respostas que
você já escreveu:

```bash
make rebuild      # reset do volume + espera o seed + replay de answers/*.sql
```

Se preferir apenas reaplicar as respostas sobre o banco atual (sem resetar):

```bash
make replay
```

Arquivos de resposta ainda vazios (só comentários) são ignorados sem erro, então
você pode rodar `make replay` a qualquer momento, mesmo tendo resolvido apenas
os primeiros desafios. Com isso, o estado do banco é sempre reproduzível a
partir do SQL versionado.

## Executando o avaliador

```bash
make test                # todos os desafios
make test CHALLENGE=04   # apenas o desafio 04
```

Exemplo de saída:

```text
Challenge 04

✓ Data integrity
✓ Correctness customer=42 page_view from 2023-01-01
✓ customer=42 page_view from 2023-01-01 plan
✓ customer=42 page_view from 2023-01-01 sort
✓ customer=42 page_view from 2023-01-01 buffers
✓ customer=42 page_view from 2023-01-01 time
...
Status: PASSED
```

Em caso de falha, o avaliador mostra o esperado e o obtido, mas **não revela a
solução**.

## Dicas

Cada desafio possui um `hints.md` com três níveis de dica. Use uma de cada vez.

## Resetando o laboratório

Para descartar todas as suas alterações e recriar o banco original:

```bash
make reset
# equivalente a
docker compose down -v
docker compose up -d
```

O volume é removido e o banco é recriado e repovoado do zero. Seus arquivos em
`answers/` **não** são afetados; use `make rebuild` para voltar a montar o banco
com todas as suas respostas aplicadas.

## Regras do laboratório

- Só é permitido alterar o banco.
- Não altere as queries dos desafios.
- Não altere os dados.
- Não remova constraints.
- Não faça hardcode para valores específicos.
- Índices e outras estruturas de banco são permitidos (salvo indicação em
  contrário no desafio).
- O avaliador roda como `postgres`, então configurações de sessão/papel feitas
  por `student` não influenciam a medição.

## Conceitos estudados

Ao longo dos desafios você vai praticar:

- B-Tree indexes e quando o planejador os usa;
- Sequential Scan vs Index Scan vs Bitmap Scan vs Index Only Scan;
- filtros de igualdade e de intervalo;
- índices compostos e a ordem das colunas;
- `ORDER BY` atendido por índice e Top-N (`ORDER BY ... LIMIT`);
- índices de cobertura e `INCLUDE`;
- Index Only Scan;
- índices parciais;
- seletividade;
- leitura de `EXPLAIN` e `EXPLAIN (ANALYZE, BUFFERS)`;
- tamanho e custo de manutenção dos índices;
- trade-off entre performance de leitura e custo de escrita.

## Estrutura do repositório

```text
.
├── docker-compose.yml
├── Makefile
├── README.md
├── db/
│   ├── schema/        # schema inicial, propositalmente pobre em índices
│   ├── seed/          # geração determinística dos dados
│   ├── functions/     # harness de avaliação (schema `lab`)
│   └── grants/        # papel `student`
├── challenges/        # enunciados e dicas (01..10)
├── tests/             # avaliadores de cada desafio
├── benchmarks/        # benchmark de leitura vs escrita
└── scripts/           # runner dos testes
```

## Sobre thresholds de tempo

As metas de tempo são generosas e podem variar conforme o hardware. Quando um
desafio exige uma meta de plano ou de buffers, essas métricas são as fontes
principais de verdade, pois não dependem da máquina. As metas absolutas de tempo
servem como um teto de segurança.

## Reprodutibilidade

O dataset é gerado inteiramente dentro do PostgreSQL, de forma determinística.
Não há download de dados, APIs externas nem dependências além do Docker.

## Limpeza

```bash
docker compose down -v   # remove o container e o volume de dados
```
