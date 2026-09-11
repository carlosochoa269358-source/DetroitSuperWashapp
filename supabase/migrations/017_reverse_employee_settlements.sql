-- 017_reverse_employee_settlements.sql
-- Permite reversar una liquidación de trabajador (nunca se borra, se marca
-- reversada con motivo — mismo patrón que payments.is_reversed). Al
-- reversar, las órdenes que estaban liquidadas vuelven a quedar pendientes
-- (is_settled = false) para poder corregir el monto o el método y volver a
-- liquidar.

ALTER TABLE employee_settlements
  ADD COLUMN is_reversed BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN reversed_at TIMESTAMPTZ,
  ADD COLUMN reversed_by UUID REFERENCES users(id),
  ADD COLUMN reverse_reason TEXT;

COMMENT ON COLUMN employee_settlements.is_reversed IS
  'Si es true, esta liquidación fue reversada: las órdenes que cubría volvieron a quedar pendientes por liquidar.';
