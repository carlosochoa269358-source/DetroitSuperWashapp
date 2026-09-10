-- 002_helper_functions.sql

-- 1. get_user_company_id()
CREATE OR REPLACE FUNCTION get_user_company_id()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT company_id FROM users WHERE id = auth.uid();
$$;

-- 2. get_user_role()
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT r.name 
  FROM users u
  JOIN roles r ON u.role_id = r.id
  WHERE u.id = auth.uid();
$$;

-- 3. is_admin_general()
CREATE OR REPLACE FUNCTION is_admin_general()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT get_user_role() = 'admin_general';
$$;

-- 4b. service_order_company_id()
-- SECURITY DEFINER para que las políticas de service_order_workers puedan
-- comparar contra la empresa de la orden sin volver a pasar por las
-- políticas de service_orders (evita recursión infinita entre ambas tablas).
CREATE OR REPLACE FUNCTION service_order_company_id(p_service_order_id uuid)
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT company_id FROM service_orders WHERE id = p_service_order_id;
$$;

-- 4c. accounts_receivable_company_id() y settlement_company_id()
-- Mismo patrón que service_order_company_id(): SECURITY DEFINER para que
-- las tablas hijas sin company_id propio (accounts_receivable_payments,
-- employee_settlement_items) puedan filtrar por empresa sin re-entrar a
-- las políticas de su tabla padre.
CREATE OR REPLACE FUNCTION accounts_receivable_company_id(p_ar_id uuid)
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT company_id FROM accounts_receivable WHERE id = p_ar_id;
$$;

CREATE OR REPLACE FUNCTION settlement_company_id(p_settlement_id uuid)
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT company_id FROM employee_settlements WHERE id = p_settlement_id;
$$;

-- 4. is_admin_punto()
CREATE OR REPLACE FUNCTION is_admin_punto()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT get_user_role() = 'admin_punto';
$$;

-- 5. update_customer_stats()
CREATE OR REPLACE FUNCTION update_customer_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_reversed = false THEN
    UPDATE customers
    SET total_spent = total_spent + NEW.amount,
        visit_count = visit_count + 1,
        last_visit_at = now()
    WHERE id = (SELECT customer_id FROM service_orders WHERE id = NEW.service_order_id);
  ELSIF NEW.is_reversed = true THEN
    -- logic to reverse if needed, keeping simple for now
    UPDATE customers
    SET total_spent = total_spent - NEW.amount,
        visit_count = visit_count - 1
    WHERE id = (SELECT customer_id FROM service_orders WHERE id = NEW.service_order_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_customer_stats
AFTER INSERT OR UPDATE OF is_reversed ON payments
FOR EACH ROW EXECUTE FUNCTION update_customer_stats();

-- 6. update_service_order_paid_amount()
CREATE OR REPLACE FUNCTION update_service_order_paid_amount()
RETURNS TRIGGER AS $$
DECLARE
  v_total_paid numeric(12,2);
  v_total_amount numeric(12,2);
BEGIN
  -- Sum all non-reversed payments for the order
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
      paid_at = CASE WHEN v_total_amount - v_total_paid <= 0 THEN now() ELSE paid_at END
  WHERE id = NEW.service_order_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_so_paid_amount
AFTER INSERT OR UPDATE OF is_reversed ON payments
FOR EACH ROW EXECUTE FUNCTION update_service_order_paid_amount();

-- 7. update_ar_paid_amount()
CREATE OR REPLACE FUNCTION update_ar_paid_amount()
RETURNS TRIGGER AS $$
DECLARE
  v_total_paid numeric(12,2);
  v_total_amount numeric(12,2);
BEGIN
  SELECT COALESCE(SUM(amount), 0) INTO v_total_paid
  FROM accounts_receivable_payments
  WHERE accounts_receivable_id = NEW.accounts_receivable_id;

  SELECT original_amount INTO v_total_amount
  FROM accounts_receivable
  WHERE id = NEW.accounts_receivable_id;

  UPDATE accounts_receivable
  SET paid_amount = v_total_paid,
      pending_amount = v_total_amount - v_total_paid,
      status = CASE 
                 WHEN v_total_amount - v_total_paid <= 0 THEN 'paid' 
                 WHEN v_total_paid > 0 THEN 'partial'
                 ELSE 'open' 
               END
  WHERE id = NEW.accounts_receivable_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_ar_paid_amount
AFTER INSERT ON accounts_receivable_payments
FOR EACH ROW EXECUTE FUNCTION update_ar_paid_amount();

-- 8. set_updated_at()
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply set_updated_at to a few tables as example (apply to all in practice)
CREATE TRIGGER trg_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_service_orders_updated_at BEFORE UPDATE ON service_orders FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_vehicles_updated_at BEFORE UPDATE ON vehicles FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 9. uppercase_plate()
CREATE OR REPLACE FUNCTION uppercase_plate()
RETURNS TRIGGER AS $$
BEGIN
  NEW.plate = UPPER(REPLACE(NEW.plate, ' ', ''));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_uppercase_plate
BEFORE INSERT OR UPDATE OF plate ON vehicles
FOR EACH ROW EXECUTE FUNCTION uppercase_plate();

-- Generate Order Number Function
CREATE OR REPLACE FUNCTION generate_order_number(p_company_id uuid)
RETURNS text AS $$
DECLARE
  v_seq int;
  v_year text;
  v_seq_name text;
  v_num text;
BEGIN
  v_year := to_char(now(), 'YYYY');
  v_seq_name := 'service_order_seq_' || v_year;

  -- Crea la secuencia del año actual si todavía no existe (reinicio anual)
  EXECUTE format('CREATE SEQUENCE IF NOT EXISTS %I START 1', v_seq_name);
  EXECUTE format('SELECT nextval(%L)', v_seq_name) INTO v_seq;

  v_num := lpad(v_seq::text, 6, '0');
  RETURN 'DSW-' || v_year || '-' || v_num;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_set_order_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
    NEW.order_number := generate_order_number(NEW.company_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_service_order_number
BEFORE INSERT ON service_orders
FOR EACH ROW EXECUTE FUNCTION trg_set_order_number();

-- 10. set_initial_pending_amount()
-- Al crear una orden nada se ha pagado todavía: pending_amount debe iniciar en final_price.
CREATE OR REPLACE FUNCTION set_initial_pending_amount()
RETURNS TRIGGER AS $$
BEGIN
  NEW.pending_amount := NEW.final_price - NEW.paid_amount;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_service_orders_initial_pending
BEFORE INSERT ON service_orders
FOR EACH ROW EXECUTE FUNCTION set_initial_pending_amount();

-- updated_at triggers faltantes (tablas con columna updated_at que no la tenían aplicada)
CREATE TRIGGER trg_employees_updated_at BEFORE UPDATE ON employees FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_service_categories_updated_at BEFORE UPDATE ON service_categories FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_services_updated_at BEFORE UPDATE ON services FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_cash_registers_updated_at BEFORE UPDATE ON cash_registers FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_accounts_receivable_updated_at BEFORE UPDATE ON accounts_receivable FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_expenses_updated_at BEFORE UPDATE ON expenses FOR EACH ROW EXECUTE FUNCTION set_updated_at();
