-- 013_turno_scoping_and_history.sql
-- Escopa las pestañas Nuevas/Finalizadas/Pagadas al turno abierto actual,
-- bloquea el cierre de turno mientras queden órdenes sin resolver, y deja
-- registrado en qué turno se terminó de pagar cada orden (puede ser
-- distinto al turno en que se creó, ej. un fiado pagado días después) para
-- poder archivar "Pagadas" bajo el turno correcto al cerrarlo.
-- "Por Cobrar" (fiados) NUNCA se escopa por turno ni bloquea el cierre.

-- =============================================
-- 1. Turno en el que una orden terminó de pagarse
-- =============================================
ALTER TABLE service_orders ADD COLUMN paid_cash_register_id UUID REFERENCES cash_registers(id);

COMMENT ON COLUMN service_orders.paid_cash_register_id IS
  'Turno en el que la orden quedó completamente pagada (puede ser distinto a cash_register_id si fue fiada y se pagó después). Se usa para archivar "Pagadas" bajo el turno correcto al cerrarlo.';

-- =============================================
-- 2. Pago directo completo (tabla payments) también registra el turno del pago
-- =============================================
CREATE OR REPLACE FUNCTION update_service_order_paid_amount()
RETURNS TRIGGER AS $$
DECLARE
  v_total_paid numeric(12,2);
  v_total_amount numeric(12,2);
BEGIN
  SELECT COALESCE(SUM(amount), 0) INTO v_total_paid
  FROM payments
  WHERE service_order_id = NEW.service_order_id AND is_reversed = false;

  SELECT final_price INTO v_total_amount
  FROM service_orders
  WHERE id = NEW.service_order_id;

  UPDATE service_orders
  SET paid_amount = v_total_paid,
      pending_amount = v_total_amount - v_total_paid,
      status = CASE WHEN v_total_amount - v_total_paid <= 0 THEN 'paid' ELSE status END,
      paid_at = CASE WHEN v_total_amount - v_total_paid <= 0 THEN now() ELSE paid_at END,
      paid_cash_register_id = CASE
        WHEN v_total_amount - v_total_paid <= 0 THEN NEW.cash_register_id
        ELSE paid_cash_register_id
      END
  WHERE id = NEW.service_order_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- 3. Abono que termina de saldar un fiado también registra el turno del abono
-- =============================================
CREATE OR REPLACE FUNCTION update_ar_paid_amount()
RETURNS TRIGGER AS $$
DECLARE
  v_total_paid numeric(12,2);
  v_total_amount numeric(12,2);
  v_service_order_id uuid;
  v_new_status text;
BEGIN
  SELECT COALESCE(SUM(amount), 0) INTO v_total_paid
  FROM accounts_receivable_payments
  WHERE accounts_receivable_id = NEW.accounts_receivable_id;

  SELECT original_amount, service_order_id INTO v_total_amount, v_service_order_id
  FROM accounts_receivable
  WHERE id = NEW.accounts_receivable_id;

  v_new_status := CASE
                     WHEN v_total_amount - v_total_paid <= 0 THEN 'paid'
                     WHEN v_total_paid > 0 THEN 'partial'
                     ELSE 'open'
                   END;

  UPDATE accounts_receivable
  SET paid_amount = v_total_paid,
      pending_amount = v_total_amount - v_total_paid,
      status = v_new_status
  WHERE id = NEW.accounts_receivable_id;

  IF v_new_status = 'paid' THEN
    UPDATE service_orders
    SET status = 'paid', paid_at = now(), paid_amount = final_price, pending_amount = 0,
        paid_cash_register_id = NEW.cash_register_id
    WHERE id = v_service_order_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- 4. No se puede cerrar un turno con órdenes sin resolver: 'new' (todavía en
--    lavado) o 'finished' (terminada pero sin cobrar ni pasar a fiado).
--    Los fiados ('receivable') nunca bloquean el cierre, sin importar cuánto
--    tiempo lleven pendientes.
-- =============================================
CREATE OR REPLACE FUNCTION prevent_close_with_unresolved_orders()
RETURNS TRIGGER AS $$
DECLARE
  v_pending_count integer;
BEGIN
  IF NEW.status = 'closed' AND OLD.status = 'open' THEN
    SELECT COUNT(*) INTO v_pending_count
    FROM service_orders
    WHERE cash_register_id = NEW.id AND status IN ('new', 'finished');

    IF v_pending_count > 0 THEN
      RAISE EXCEPTION 'No se puede cerrar el turno: hay % orden(es) sin terminar o sin cobrar todavía.', v_pending_count;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_close_with_unresolved_orders ON cash_registers;
CREATE TRIGGER trg_prevent_close_with_unresolved_orders
BEFORE UPDATE ON cash_registers
FOR EACH ROW EXECUTE FUNCTION prevent_close_with_unresolved_orders();
