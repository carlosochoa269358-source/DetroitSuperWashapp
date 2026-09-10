-- 008_fix_all_rls_recursion.sql
-- Corrección integral de RLS. Reemplaza y amplía a 007.
--
-- payments, accounts_receivable_payments y employee_settlement_items NO
-- tienen columna company_id propia (se relacionan indirectamente a través
-- de service_orders / accounts_receivable / employee_settlements). Igual
-- que pasaba con service_order_workers, cualquier política que intente
-- comparar "company_id = get_user_company_id()" directamente en esas tres
-- tablas falla ("column company_id does not exist"), y cualquier política
-- que las consulte con un EXISTS/subquery directo contra su tabla padre
-- puede crear recursión infinita si esa tabla padre también las referencia.
--
-- Este script es seguro de correr aunque ya hayas corrido 007 antes
-- (usa DROP POLICY IF EXISTS y CREATE OR REPLACE FUNCTION en todo).

-- =============================================
-- 1. service_orders <-> service_order_workers (por si 007 no se corrió)
-- =============================================
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

-- =============================================
-- 2. PAYMENTS (se relaciona a través de service_orders)
-- =============================================
DROP POLICY IF EXISTS "payments_select" ON payments;
DROP POLICY IF EXISTS "payments_insert" ON payments;
DROP POLICY IF EXISTS "payments_update" ON payments;

CREATE POLICY "payments_select" ON payments FOR SELECT USING (
  service_order_company_id(service_order_id) = get_user_company_id()
);
CREATE POLICY "payments_insert" ON payments FOR INSERT WITH CHECK (
  (is_admin_general() OR is_admin_punto())
  AND service_order_company_id(service_order_id) = get_user_company_id()
);
CREATE POLICY "payments_update" ON payments FOR UPDATE USING (
  (is_admin_general() OR is_admin_punto())
  AND service_order_company_id(service_order_id) = get_user_company_id()
);

-- =============================================
-- 3. ACCOUNTS_RECEIVABLE_PAYMENTS (se relaciona a través de accounts_receivable)
-- =============================================
CREATE OR REPLACE FUNCTION accounts_receivable_company_id(p_ar_id uuid)
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT company_id FROM accounts_receivable WHERE id = p_ar_id;
$$;

DROP POLICY IF EXISTS "accounts_receivable_payments_select" ON accounts_receivable_payments;
DROP POLICY IF EXISTS "accounts_receivable_payments_insert" ON accounts_receivable_payments;
DROP POLICY IF EXISTS "accounts_receivable_payments_update" ON accounts_receivable_payments;

CREATE POLICY "accounts_receivable_payments_select" ON accounts_receivable_payments FOR SELECT USING (
  accounts_receivable_company_id(accounts_receivable_id) = get_user_company_id()
);
CREATE POLICY "accounts_receivable_payments_insert" ON accounts_receivable_payments FOR INSERT WITH CHECK (
  (is_admin_general() OR is_admin_punto())
  AND accounts_receivable_company_id(accounts_receivable_id) = get_user_company_id()
);
CREATE POLICY "accounts_receivable_payments_update" ON accounts_receivable_payments FOR UPDATE USING (
  (is_admin_general() OR is_admin_punto())
  AND accounts_receivable_company_id(accounts_receivable_id) = get_user_company_id()
);

-- =============================================
-- 4. EMPLOYEE_SETTLEMENT_ITEMS (se relaciona a través de employee_settlements)
-- =============================================
CREATE OR REPLACE FUNCTION settlement_company_id(p_settlement_id uuid)
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT company_id FROM employee_settlements WHERE id = p_settlement_id;
$$;

DROP POLICY IF EXISTS "employee_settlement_items_select" ON employee_settlement_items;
DROP POLICY IF EXISTS "employee_settlement_items_insert" ON employee_settlement_items;
DROP POLICY IF EXISTS "employee_settlement_items_update" ON employee_settlement_items;

CREATE POLICY "employee_settlement_items_select" ON employee_settlement_items FOR SELECT USING (
  settlement_company_id(settlement_id) = get_user_company_id()
);
CREATE POLICY "employee_settlement_items_insert" ON employee_settlement_items FOR INSERT WITH CHECK (
  is_admin_general()
  AND settlement_company_id(settlement_id) = get_user_company_id()
);
CREATE POLICY "employee_settlement_items_update" ON employee_settlement_items FOR UPDATE USING (
  is_admin_general()
  AND settlement_company_id(settlement_id) = get_user_company_id()
);
