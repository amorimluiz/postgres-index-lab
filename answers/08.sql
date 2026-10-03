-- =============================================================================
-- Challenge 08 - a sua resposta
-- =============================================================================
-- Escreva aqui o SQL que altera o banco (DDL: indices, estatisticas, etc.).
--
-- Aplique:  make apply CHALLENGE=08
-- Avalie:   make test  CHALLENGE=08   (ou: make solve CHALLENGE=08)
--
-- Prefira comandos idempotentes para poder reaplicar sem erro, por exemplo:
--   DROP INDEX IF EXISTS ...;  /  CREATE INDEX IF NOT EXISTS ...
--
-- Nao altere as queries dos desafios, nem os dados, nem remova constraints.
-- =============================================================================

-- Escreva sua resposta abaixo.
DROP INDEX IF EXISTS customers_country_status_created_at_desc_id_desc_idx;
CREATE INDEX customers_country_status_created_at_desc_id_desc ON customers(country, status, created_at DESC, id DESC);