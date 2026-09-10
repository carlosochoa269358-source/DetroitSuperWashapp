-- 007_fix_rls_recursion.sql
-- Corrige "infinite recursion detected in policy for relation service_orders" (42P17).
--
-- Causa: las políticas de service_order_workers consultaban service_orders
-- directamente (EXISTS ... FROM service_orders), y service_orders tiene una
-- política que a su vez consulta service_order_workers. Cuando se consultan
-- ambas tablas juntas (ej. traer una orden con su trabajador embebido),
-- Postgres detecta el ciclo entre las dos políticas y aborta la consulta.
--
-- Solución: mover la comparación de company_id a una función SECURITY DEFINER,
-- que evalúa el dato sin volver a pasar por las políticas de service_orders
-- (igual que ya se hace en get_user_company_id()), rompiendo el ciclo.

CREATE OR REPLACE FUNCTION service_order_company_id(p_service_order_id uuid)
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT company_id FROM service_orders WHERE id = p_service_order_id;
$$;

DROP POLICY IF EXISTS "service_order_workers_select" ON service_order_workers;
DROP POLICY IF EXISTS "service_order_workers_insert" ON service_order_workers;
DROP POLICY IF EXISTS "service_order_workers_update" ON service_order_workers;

CREATE POLICY "service_order_workers_select" ON service_order_workers FOR SELECT USING (
  service_order_company_id(service_order_id) = get_user_company_id()
);
CREATE POLICY "service_order_workers_insert" ON service_order_workers FOR INSERT WITH CHECK (
  (is_admin_general() OR is_admin_punto())
  AND service_order_company_id(service_order_id) = get_user_company_id()
);
CREATE POLICY "service_order_workers_update" ON service_order_workers FOR UPDATE USING (
  (is_admin_general() OR is_admin_punto())
  AND service_order_company_id(service_order_id) = get_user_company_id()
);
