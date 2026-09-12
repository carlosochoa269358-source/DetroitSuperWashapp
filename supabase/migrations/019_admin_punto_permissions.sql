-- 019_admin_punto_permissions.sql
-- Ajusta los permisos de "admin_punto" a lo que realmente necesita el
-- negocio: puede operar, modificar precios/servicios y liquidar
-- trabajadores, pero NO puede registrar gastos ni corregir (anular
-- órdenes/gastos, reversar liquidaciones) — eso queda solo para
-- admin_general.

-- =============================================
-- 1. Gastos: ahora SOLO admin_general (antes admin_general o admin_punto)
-- =============================================
DROP POLICY IF EXISTS "expenses_insert" ON expenses;
DROP POLICY IF EXISTS "expenses_update" ON expenses;

CREATE POLICY "expenses_insert" ON expenses FOR INSERT WITH CHECK (
  company_id = get_user_company_id() AND is_admin_general()
);
CREATE POLICY "expenses_update" ON expenses FOR UPDATE USING (
  company_id = get_user_company_id() AND is_admin_general()
);

-- =============================================
-- 2. Liquidaciones: admin_punto ya puede CREARLAS (liquidar), pero
--    reversarlas (UPDATE) sigue siendo solo admin_general — misma
--    lógica que "cualquiera opera, solo el dueño corrige".
-- =============================================
DROP POLICY IF EXISTS "employee_settlements_insert_ag" ON employee_settlements;

CREATE POLICY "employee_settlements_insert" ON employee_settlements FOR INSERT WITH CHECK (
  company_id = get_user_company_id() AND (is_admin_general() OR is_admin_punto())
);
-- employee_settlements_update_ag (solo admin_general) se queda igual — reversar es corrección.

DROP POLICY IF EXISTS "employee_settlement_items_insert" ON employee_settlement_items;

CREATE POLICY "employee_settlement_items_insert" ON employee_settlement_items FOR INSERT WITH CHECK (
  (is_admin_general() OR is_admin_punto())
  AND settlement_company_id(settlement_id) = get_user_company_id()
);
-- employee_settlement_items_update se queda solo admin_general (no se usa en el flujo actual).
