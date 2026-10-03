-- =============================================================================
-- Challenge 02 - a sua resposta
-- =============================================================================
-- Escreva aqui o SQL que altera o banco (DDL: indices, estatisticas, etc.).
--
-- Aplique:  make apply CHALLENGE=02
-- Avalie:   make test  CHALLENGE=02   (ou: make solve CHALLENGE=02)
--
-- Prefira comandos idempotentes para poder reaplicar sem erro, por exemplo:
--   DROP INDEX IF EXISTS ...;  /  CREATE INDEX IF NOT EXISTS ...
--
-- Nao altere as queries dos desafios, nem os dados, nem remova constraints.
-- =============================================================================

-- Escreva sua resposta abaixo.
CREATE INDEX IF NOT EXISTS orders_customer_id_status_idx ON orders(customer_id, status)

