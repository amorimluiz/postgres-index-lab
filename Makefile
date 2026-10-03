# =============================================================================
# PostgreSQL Index Lab
# =============================================================================
# Everything runs through Docker Compose. You never need psql installed locally.
#
#   make up                 start PostgreSQL (seeds on first boot)
#   make wait               block until the database is healthy
#   make psql               open an interactive SQL session as postgres
#   make student            open an interactive SQL session as student
#   make test               run every challenge evaluator
#   make test CHALLENGE=04  run one challenge evaluator
#   make apply CHALLENGE=04 apply answers/04.sql to the database
#   make solve CHALLENGE=04 apply the answer, then run the evaluator
#   make replay             apply every answers/NN.sql in order (reverse reset)
#   make rebuild            reset the volume, wait, then replay all answers
#   make bench              run the read-vs-write benchmark
#   make reset              destroy the volume and recreate the original database
# =============================================================================

COMPOSE   ?= docker compose
SERVICE   ?= db
SCHEMA_DB ?= indexlab

PSQL_POSTGRES := $(COMPOSE) exec -T $(SERVICE) psql -U postgres -d $(SCHEMA_DB)
PSQL_STUDENT  := $(COMPOSE) exec -T $(SERVICE) psql -v ON_ERROR_STOP=1 -U student -d $(SCHEMA_DB)

.PHONY: help up wait down reset psql student test apply solve replay rebuild bench list

help:
	@echo "Targets: up wait down reset psql student test apply solve replay rebuild bench list"

up:
	$(COMPOSE) up -d
	@echo "PostgreSQL starting. On the first boot the seed runs; give it a couple of minutes."

# Blocks until the server is up AND the initial seed has finished. The seed
# marker `lab.ready` is created by the last init script.
wait:
	@printf "Waiting for PostgreSQL and the initial seed"
	@until $(COMPOSE) exec -T $(SERVICE) psql -U postgres -d $(SCHEMA_DB) -tAc \
		"SELECT to_regclass('lab.ready') IS NOT NULL" 2>/dev/null | grep -q '^t$$'; do \
		printf "."; sleep 3; \
	done; echo " ready."

down:
	$(COMPOSE) down

# Destroy the volume, recreate and reseed from scratch.
reset:
	$(COMPOSE) down -v
	$(COMPOSE) up -d
	@echo "Volume removed and database recreated. The seed is running."

psql:
	$(COMPOSE) exec $(SERVICE) psql -U postgres -d $(SCHEMA_DB)

student:
	$(COMPOSE) exec $(SERVICE) psql -U student -d $(SCHEMA_DB)

test:
	@./scripts/run-tests.sh $(CHALLENGE)

# Apply the SQL you wrote for a challenge. Use it like: make apply CHALLENGE=01
apply:
	@test -n "$(CHALLENGE)" || (echo "Usage: make apply CHALLENGE=01" >&2; exit 2)
	@test -f answers/$(CHALLENGE).sql || (echo "answers/$(CHALLENGE).sql not found" >&2; exit 2)
	$(PSQL_STUDENT) < answers/$(CHALLENGE).sql
	@echo "Applied answers/$(CHALLENGE).sql"

# Apply the answer and immediately evaluate the challenge.
solve: apply
	@./scripts/run-tests.sh $(CHALLENGE)

# Reverse reset: replay every answer file, in order, leaving the database built
# up with all the solutions you have written so far. Empty templates are no-ops.
replay:
	@for f in $$(ls -1 answers/[0-9][0-9].sql 2>/dev/null | sort); do \
		echo "--> applying $$f"; \
		$(COMPOSE) exec -T $(SERVICE) psql -v ON_ERROR_STOP=1 -U student -d $(SCHEMA_DB) < "$$f" || exit 1; \
	done
	@echo "Replayed all answer files."

# Reset to the original database, then replay every answer. Leaves the lab in a
# reproducible state built entirely from versioned SQL.
rebuild: reset
	@$(MAKE) wait
	@$(MAKE) replay

bench:
	$(PSQL_POSTGRES) < benchmarks/write_tradeoff.sql

list:
	@ls -1 tests/challenge-*.sql | sed 's#.*/challenge-##; s#\.sql##' | sed 's/^/Challenge /'
