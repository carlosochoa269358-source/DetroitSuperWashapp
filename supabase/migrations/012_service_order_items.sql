-- 012_service_order_items.sql
-- Una orden ahora puede tener varios servicios (líneas), no solo uno.
-- Un solo trabajador por orden (la comisión se paga sobre el total de
-- todas las líneas). Las líneas solo se pueden crear/editar/borrar
-- mientras la orden está en 'new'.

-- =============================================
-- 1. SERVICE_ORDER_ITEMS
-- =============================================
CREATE TABLE service_order_items (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_order_id UUID NOT NULL REFERENCES service_orders(id) ON DELETE RESTRICT,
    service_id       UUID NOT NULL REFERENCES services(id),
    base_price       NUMERIC(12,2) NOT NULL,
    discount_amount  NUMERIC(12,2) NOT NULL DEFAULT 0,
    final_price      NUMERIC(12,2) NOT NULL,
    commission_pct   NUMERIC(5,2) NOT NULL,
    commission_amount NUMERIC(12,2) NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_service_order_items_order ON service_order_items(service_order_id);

CREATE TRIGGER trg_service_order_items_updated_at BEFORE UPDATE ON service_order_items
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE service_order_items IS 'Servicios (líneas) dentro de una orden. Una orden puede tener varios (ej. lavada + polichada). Solo editables mientras la orden está en status=new.';

-- =============================================
-- 2. service_orders pierde las columnas de "un solo servicio"
-- =============================================
ALTER TABLE service_orders DROP COLUMN IF EXISTS service_id;
ALTER TABLE service_orders DROP COLUMN IF EXISTS base_price;
ALTER TABLE service_orders DROP COLUMN IF EXISTS commission_pct;
ALTER TABLE service_orders DROP COLUMN IF EXISTS discount_reason;

-- discount_amount / final_price / commission_amount / detroit_amount se
-- quedan, pero ahora son sumas mantenidas por trigger (abajo), no valores
-- fijados al crear la orden.

-- =============================================
-- 3. Recalcula los totales del encabezado cuando cambian las líneas
-- =============================================
CREATE OR REPLACE FUNCTION recompute_service_order_totals()
RETURNS TRIGGER AS $$
DECLARE
  v_order_id uuid;
  v_final_price numeric(12,2);
  v_discount numeric(12,2);
  v_commission numeric(12,2);
  v_paid numeric(12,2);
BEGIN
  v_order_id := COALESCE(NEW.service_order_id, OLD.service_order_id);

  SELECT COALESCE(SUM(final_price), 0), COALESCE(SUM(discount_amount), 0), COALESCE(SUM(commission_amount), 0)
  INTO v_final_price, v_discount, v_commission
  FROM service_order_items
  WHERE service_order_id = v_order_id;

  SELECT paid_amount INTO v_paid FROM service_orders WHERE id = v_order_id;

  UPDATE service_orders
  SET final_price = v_final_price,
      discount_amount = v_discount,
      commission_amount = v_commission,
      detroit_amount = v_final_price - v_commission,
      pending_amount = v_final_price - v_paid
  WHERE id = v_order_id;

  UPDATE service_order_workers
  SET commission_amount = v_commission
  WHERE service_order_id = v_order_id;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recompute_service_order_totals
AFTER INSERT OR UPDATE OR DELETE ON service_order_items
FOR EACH ROW EXECUTE FUNCTION recompute_service_order_totals();

-- =============================================
-- 4. Bloquea cambios en las líneas si la orden ya no está en 'new'
-- =============================================
CREATE OR REPLACE FUNCTION prevent_items_edit_after_new()
RETURNS TRIGGER AS $$
DECLARE
  v_status text;
BEGIN
  SELECT status INTO v_status FROM service_orders WHERE id = COALESCE(NEW.service_order_id, OLD.service_order_id);
  IF v_status IS DISTINCT FROM 'new' THEN
    RAISE EXCEPTION 'No se pueden modificar los servicios de una orden que ya no está en estado "new" (actual: %)', v_status;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_items_edit_after_new
BEFORE INSERT OR UPDATE OR DELETE ON service_order_items
FOR EACH ROW EXECUTE FUNCTION prevent_items_edit_after_new();

-- =============================================
-- 5. RLS (mismo patrón SECURITY DEFINER que service_order_workers/payments)
-- =============================================
ALTER TABLE service_order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_order_items_select" ON service_order_items FOR SELECT USING (
  service_order_company_id(service_order_id) = get_user_company_id()
);
CREATE POLICY "service_order_items_insert" ON service_order_items FOR INSERT WITH CHECK (
  (is_admin_general() OR is_admin_punto())
  AND service_order_company_id(service_order_id) = get_user_company_id()
);
CREATE POLICY "service_order_items_update" ON service_order_items FOR UPDATE USING (
  (is_admin_general() OR is_admin_punto())
  AND service_order_company_id(service_order_id) = get_user_company_id()
);
CREATE POLICY "service_order_items_delete" ON service_order_items FOR DELETE USING (
  (is_admin_general() OR is_admin_punto())
  AND service_order_company_id(service_order_id) = get_user_company_id()
);
