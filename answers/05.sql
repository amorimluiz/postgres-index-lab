-- =============================================================================
-- Challenge 05 - a sua resposta
-- =============================================================================
-- Escreva aqui o SQL que altera o banco (DDL: indices, estatisticas, etc.).
--
-- Aplique:  make apply CHALLENGE=05
-- Avalie:   make test  CHALLENGE=05   (ou: make solve CHALLENGE=05)
--
-- Prefira comandos idempotentes para poder reaplicar sem erro, por exemplo:
--   DROP INDEX IF EXISTS ...;  /  CREATE INDEX IF NOT EXISTS ...
--
-- Nao altere as queries dos desafios, nem os dados, nem remova constraints.
-- =============================================================================

-- Escreva sua resposta abaixo.
DROP INDEX IF EXISTS events_id_desc_created_at_desc;
CREATE INDEX events_id_desc_created_at_desc ON events (created_at DESC, id DESC) INCLUDE (customer_id, event_type);