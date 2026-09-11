-- 016_fix_one_open_turno_per_day.sql
-- El constraint original UNIQUE(company_id, opening_date, status) para
-- garantizar "un solo turno abierto por día" sin querer también limitaba a
-- UN SOLO TURNO CERRADO por día — al cerrar un segundo turno del mismo día
-- chocaba con el primero ya cerrado (duplicate key value violates unique
-- constraint "cash_registers_one_open_per_day").
--
-- La regla real solo debe aplicar a status='open': se reemplaza por un
-- índice único parcial que solo mira las filas abiertas.

ALTER TABLE cash_registers DROP CONSTRAINT IF EXISTS cash_registers_one_open_per_day;

CREATE UNIQUE INDEX cash_registers_one_open_per_day
  ON cash_registers (company_id, opening_date)
  WHERE status = 'open';
