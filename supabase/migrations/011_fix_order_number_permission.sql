-- 011_fix_order_number_permission.sql
-- Corrige "permission denied for schema public" al crear un servicio.
--
-- generate_order_number() crea dinámicamente una secuencia por año
-- (CREATE SEQUENCE service_order_seq_2027, etc.) para que la numeración no
-- se rompa en el cambio de año. Crear una secuencia requiere permiso CREATE
-- sobre el esquema, que el rol autenticado normal de la app NO tiene (solo
-- el dueño de la base de datos). Al no ser SECURITY DEFINER, la función
-- corría con los permisos de quien la llama (el usuario logueado) y fallaba.

CREATE OR REPLACE FUNCTION generate_order_number(p_company_id uuid)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_seq int;
  v_year text;
  v_seq_name text;
  v_num text;
BEGIN
  v_year := to_char(now(), 'YYYY');
  v_seq_name := 'service_order_seq_' || v_year;

  EXECUTE format('CREATE SEQUENCE IF NOT EXISTS %I START 1', v_seq_name);
  EXECUTE format('SELECT nextval(%L)', v_seq_name) INTO v_seq;

  v_num := lpad(v_seq::text, 6, '0');
  RETURN 'DSW-' || v_year || '-' || v_num;
END;
$$;
