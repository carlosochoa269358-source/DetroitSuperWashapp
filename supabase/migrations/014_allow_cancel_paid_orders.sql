-- 014_allow_cancel_paid_orders.sql
-- Permite anular una orden en cualquier estado (no solo 'new'), para
-- corregir errores de digitación (placa, cliente, método de pago) que ya
-- se pagaron. Al anular: se reversan los pagos directos asociados (nunca
-- se borran, se marca is_reversed) y, si había un fiado abierto/parcial,
-- se marca como cancelado para que deje de aparecer en "Por Cobrar".

-- 'cancelled' como estado válido de una cuenta por cobrar (además de
-- open/partial/paid), para cuando se anula la orden que la originó.
ALTER TABLE accounts_receivable DROP CONSTRAINT IF EXISTS accounts_receivable_status_check;
ALTER TABLE accounts_receivable ADD CONSTRAINT accounts_receivable_status_check
  CHECK (status IN ('open', 'partial', 'paid', 'cancelled'));
