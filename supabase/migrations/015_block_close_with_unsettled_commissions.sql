-- 015_block_close_with_unsettled_commissions.sql
-- "Si se cierra un turno, se cierra todo": además de bloquear el cierre con
-- órdenes 'new'/'finished' sin resolver, también lo bloquea si quedan
-- comisiones de trabajadores sin liquidar sobre órdenes YA PAGADAS que se
-- crearon en ese turno. Los fiados ('receivable') siguen sin bloquear nada
-- y sin poder liquidarse — esa regla no cambia.

CREATE OR REPLACE FUNCTION prevent_close_with_unresolved_orders()
RETURNS TRIGGER AS $$
DECLARE
  v_pending_orders integer;
  v_pending_commissions integer;
BEGIN
  IF NEW.status = 'closed' AND OLD.status = 'open' THEN
    SELECT COUNT(*) INTO v_pending_orders
    FROM service_orders
    WHERE cash_register_id = NEW.id AND status IN ('new', 'finished');

    IF v_pending_orders > 0 THEN
      RAISE EXCEPTION 'No se puede cerrar el turno: hay % orden(es) sin terminar o sin cobrar todavía.', v_pending_orders;
    END IF;

    SELECT COUNT(*) INTO v_pending_commissions
    FROM service_order_workers sow
    JOIN service_orders so ON so.id = sow.service_order_id
    WHERE so.cash_register_id = NEW.id
      AND so.status = 'paid'
      AND sow.is_settled = false;

    IF v_pending_commissions > 0 THEN
      RAISE EXCEPTION 'No se puede cerrar el turno: hay % comisión(es) de trabajadores sin liquidar todavía.', v_pending_commissions;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
