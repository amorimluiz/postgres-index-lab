-- =============================================================================
-- Challenge 07 - a sua resposta
-- =============================================================================
-- Escreva aqui o SQL que altera o banco (DDL: indices, estatisticas, etc.).
--
-- Aplique:  make apply CHALLENGE=07
-- Avalie:   make test  CHALLENGE=07   (ou: make solve CHALLENGE=07)
--
-- Prefira comandos idempotentes para poder reaplicar sem erro, por exemplo:
--   DROP INDEX IF EXISTS ...;  /  CREATE INDEX IF NOT EXISTS ...
--
-- Nao altere as queries dos desafios, nem os dados, nem remova constraints.
-- =============================================================================

-- Escreva sua resposta abaixo.
DROP INDEX IF EXISTS orders_status_pending_created_at_desc_id_desc_idx;
CREATE INDEX orders_status_pending_created_at_desc_id_desc_idx ON orders(status, created_at DESC, id DESC) WHERE status = 'pending';