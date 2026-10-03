-- =============================================================================
-- Challenge 03 - a sua resposta
-- =============================================================================
-- Escreva aqui o SQL que altera o banco (DDL: indices, estatisticas, etc.).
--
-- Aplique:  make apply CHALLENGE=03
-- Avalie:   make test  CHALLENGE=03   (ou: make solve CHALLENGE=03)
--
-- Prefira comandos idempotentes para poder reaplicar sem erro, por exemplo:
--   DROP INDEX IF EXISTS ...;  /  CREATE INDEX IF NOT EXISTS ...
--
-- Nao altere as queries dos desafios, nem os dados, nem remova constraints.
-- =============================================================================

-- Escreva sua resposta abaixo.
CREATE INDEX IF NOT EXISTS products_created_at_category_active ON products(created_at, category) WHERE active = TRUE