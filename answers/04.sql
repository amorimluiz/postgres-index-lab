-- =============================================================================
-- Challenge 04 - a sua resposta
-- =============================================================================
-- Escreva aqui o SQL que altera o banco (DDL: indices, estatisticas, etc.).
--
-- Aplique:  make apply CHALLENGE=04
-- Avalie:   make test  CHALLENGE=04   (ou: make solve CHALLENGE=04)
--
-- Prefira comandos idempotentes para poder reaplicar sem erro, por exemplo:
--   DROP INDEX IF EXISTS ...;  /  CREATE INDEX IF NOT EXISTS ...
--
-- Nao altere as queries dos desafios, nem os dados, nem remova constraints.
-- =============================================================================

-- Escreva sua resposta abaixo.
DROP INDEX IF EXISTS events_activity_idx;
CREATE INDEX events_activity_idx
    ON events (customer_id, event_type, created_at DESC, id DESC);
CREATE INDEX IF NOT EXISTS events_customer_id_event_type_created_at ON events(customer_id, event_type, created_at)