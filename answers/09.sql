-- =============================================================================
-- Challenge 09 - a sua resposta
-- =============================================================================
-- Escreva aqui o SQL que altera o banco (DDL: indices, estatisticas, etc.).
--
-- Aplique:  make apply CHALLENGE=09
-- Avalie:   make test  CHALLENGE=09   (ou: make solve CHALLENGE=09)
--
-- Prefira comandos idempotentes para poder reaplicar sem erro, por exemplo:
--   DROP INDEX IF EXISTS ...;  /  CREATE INDEX IF NOT EXISTS ...
--
-- Nao altere as queries dos desafios, nem os dados, nem remova constraints.
-- =============================================================================

-- Escreva sua resposta abaixo.
DROP INDEX IF EXISTS sessions_customer_id_idx,
  sessions_customer_created_idx,
  sessions_status_idx,
  sessions_created_at_idx,
  sessions_customer_status_idx,
  sessions_customer_id_created_at_desc_id_desc_idx,
  sessions_active_created_at_desc_idx;

CREATE INDEX sessions_customer_id_created_at_desc_id_desc_idx ON sessions(customer_id, created_at DESC, id DESC);

CREATE INDEX sessions_active_created_at_desc_idx ON sessions(created_at DESC) WHERE status = 'active';