-- 006_service_prices_and_shift_flow.sql
-- Precio de servicio por tipo de vehículo + corrige propagación de pago
-- completo de cuentas por cobrar hacia la orden de servicio.

-- =============================================
-- 1. SERVICE_PRICES (precio de un servicio según el tipo de vehículo)
-- =============================================
CREATE TABLE service_prices (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id      UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    vehicle_type_id UUID NOT NULL REFERENCES vehicle_types(id) ON DELETE RESTRICT,
    price           NUMERIC(12,2) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT service_prices_unique UNIQUE (service_id, vehicle_type_id)
);

CREATE INDEX idx_service_prices_service ON service_prices(service_id);
CREATE INDEX idx_service_prices_vehicle_type ON service_prices(vehicle_type_id);

CREATE TRIGGER trg_service_prices_updated_at BEFORE UPDATE ON service_prices
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE service_prices IS 'Reemplaza el precio único por servicio: un mismo servicio (ej. Lavada sencilla) puede costar distinto según el tipo de vehículo.';

-- Columnas/tabla redundantes ahora que existe service_prices (sin datos reales todavía)
ALTER TABLE services DROP COLUMN IF EXISTS base_price;
ALTER TABLE services DROP COLUMN IF EXISTS applicable_vehicle_types;
DROP TABLE IF EXISTS services_vehicle_types;

-- =============================================
-- 2. RLS para service_prices (no tiene company_id propio; se deriva de services)
-- =============================================
ALTER TABLE service_prices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_prices_select" ON service_prices FOR SELECT USING (
  EXISTS (SELECT 1 FROM services s WHERE s.id = service_prices.service_id AND s.company_id = get_user_company_id())
);
CREATE POLICY "service_prices_insert" ON service_prices FOR INSERT WITH CHECK (
  (is_admin_general() OR is_admin_punto())
  AND EXISTS (SELECT 1 FROM services s WHERE s.id = service_prices.service_id AND s.company_id = get_user_company_id())
);
CREATE POLICY "service_prices_update" ON service_prices FOR UPDATE USING (
  (is_admin_general() OR is_admin_punto())
  AND EXISTS (SELECT 1 FROM services s WHERE s.id = service_prices.service_id AND s.company_id = get_user_company_id())
);
CREATE POLICY "service_prices_delete" ON service_prices FOR DELETE USING (
  (is_admin_general() OR is_admin_punto())
  AND EXISTS (SELECT 1 FROM services s WHERE s.id = service_prices.service_id AND s.company_id = get_user_company_id())
);

-- =============================================
-- 3. Corrige update_ar_paid_amount(): cuando el saldo de la cuenta por cobrar
--    llega a cero, la orden de servicio debe pasar a 'paid' también (antes
--    solo se actualizaba accounts_receivable y la orden se quedaba varada
--    en 'receivable' para siempre).
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
    SET status = 'paid', paid_at = now(), paid_amount = final_price, pending_amount = 0
    WHERE id = v_service_order_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
