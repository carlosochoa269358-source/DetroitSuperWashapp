-- 003_rls_policies.sql
-- Enable RLS
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicle_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE services_vehicle_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_registers ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_order_workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts_receivable ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts_receivable_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_settlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_settlement_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_closings ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_closings ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;

-- Helper policies

-- companies
CREATE POLICY "companies_select" ON companies FOR SELECT USING (id = get_user_company_id());

-- users
CREATE POLICY "users_select" ON users FOR SELECT USING (company_id = get_user_company_id());
CREATE POLICY "users_update" ON users FOR UPDATE USING (company_id = get_user_company_id() AND is_admin_general());

-- roles
CREATE POLICY "roles_select" ON roles FOR SELECT USING (true);

-- General policies for tables (tenant isolation + admin general access)
DO $$ 
DECLARE 
  t text;
  tables text[] := ARRAY['employees', 'customers', 'vehicles', 'service_categories', 'services', 'cash_registers', 'service_orders', 'payments', 'accounts_receivable', 'accounts_receivable_payments', 'cash_movements', 'expense_categories', 'expenses', 'employee_settlements', 'employee_settlement_items', 'daily_closings', 'monthly_closings', 'attachments', 'inventory_items'];
BEGIN
  FOREACH t IN ARRAY tables
  LOOP
    EXECUTE format('CREATE POLICY "%I_select" ON %I FOR SELECT USING (company_id = get_user_company_id());', t, t);
    EXECUTE format('CREATE POLICY "%I_insert" ON %I FOR INSERT WITH CHECK (company_id = get_user_company_id() AND (is_admin_general() OR is_admin_punto()));', t, t);
    EXECUTE format('CREATE POLICY "%I_update" ON %I FOR UPDATE USING (company_id = get_user_company_id() AND (is_admin_general() OR is_admin_punto()));', t, t);
  END LOOP;
END $$;

-- service_order_workers no tiene company_id propio; su empresa se deriva de
-- service_orders vía la función SECURITY DEFINER service_order_company_id(),
-- NO con un EXISTS directo contra service_orders — eso crea una recursión
-- infinita entre las políticas de ambas tablas en cuanto se consultan juntas
-- (ej. traer una orden con su trabajador embebido).
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

-- Exceptions for monthly_closings and employee_settlements (Admin General Only for mutation)
DROP POLICY IF EXISTS "monthly_closings_insert" ON monthly_closings;
DROP POLICY IF EXISTS "monthly_closings_update" ON monthly_closings;
DROP POLICY IF EXISTS "employee_settlements_insert" ON employee_settlements;
DROP POLICY IF EXISTS "employee_settlements_update" ON employee_settlements;

CREATE POLICY "monthly_closings_insert_ag" ON monthly_closings FOR INSERT WITH CHECK (company_id = get_user_company_id() AND is_admin_general());
CREATE POLICY "monthly_closings_update_ag" ON monthly_closings FOR UPDATE USING (company_id = get_user_company_id() AND is_admin_general());

CREATE POLICY "employee_settlements_insert_ag" ON employee_settlements FOR INSERT WITH CHECK (company_id = get_user_company_id() AND is_admin_general());
CREATE POLICY "employee_settlements_update_ag" ON employee_settlements FOR UPDATE USING (company_id = get_user_company_id() AND is_admin_general());

-- Admin Punto cannot select monthly_closings
DROP POLICY IF EXISTS "monthly_closings_select" ON monthly_closings;
CREATE POLICY "monthly_closings_select_ag" ON monthly_closings FOR SELECT USING (company_id = get_user_company_id() AND is_admin_general());

-- Operator policies on service_orders
-- Un operador solo puede actualizar órdenes donde está asignado como trabajador
-- (employees.user_id enlaza el empleado con su cuenta de auth, cuando aplica).
CREATE POLICY "service_orders_operator_update" ON service_orders FOR UPDATE USING (
  company_id = get_user_company_id()
  AND get_user_role() = 'operador'
  AND id IN (
    SELECT service_order_id
    FROM service_order_workers sow
    JOIN employees e ON sow.employee_id = e.id
    WHERE e.user_id = auth.uid()
  )
);

-- audit_logs
CREATE POLICY "audit_logs_select" ON audit_logs FOR SELECT USING (company_id = get_user_company_id() AND is_admin_general());
CREATE POLICY "audit_logs_insert" ON audit_logs FOR INSERT WITH CHECK (company_id = get_user_company_id() AND auth.role() = 'authenticated');
-- No UPDATE or DELETE policies for audit_logs
