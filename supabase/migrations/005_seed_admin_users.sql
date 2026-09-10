-- 005_seed_admin_users.sql
-- Vincula usuarios ya creados en Supabase Auth (Authentication > Users)
-- como Administrador General de Detroit Súper Wash.
--
-- REQUISITO: antes de correr este script, crea en Authentication > Users
-- (Add user, con "Auto Confirm User" activado) las cuentas:
--   - diegoalbeiroo@gmail.com
--   - andres--8a@hotmail.com

DO $$
DECLARE
  v_company_id uuid;
  v_role_admin_general uuid;
BEGIN
  SELECT id INTO v_company_id FROM companies WHERE document = '1020456810';
  SELECT id INTO v_role_admin_general FROM roles WHERE name = 'admin_general';

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'No se encontró la empresa Detroit Súper Wash. Corre primero 004_seed_data.sql';
  END IF;

  IF v_role_admin_general IS NULL THEN
    RAISE EXCEPTION 'No se encontró el rol admin_general. Corre primero 004_seed_data.sql';
  END IF;

  INSERT INTO users (id, company_id, role_id, full_name, email, is_active)
  SELECT au.id, v_company_id, v_role_admin_general, admins.full_name, au.email, true
  FROM auth.users au
  JOIN (
    VALUES
      ('diegoalbeiroo@gmail.com', 'Diego Ochoa'),
      ('andres--8a@hotmail.com', 'Andres Ochoa')
  ) AS admins(email, full_name) ON au.email = admins.email
  ON CONFLICT (id) DO UPDATE
    SET role_id = EXCLUDED.role_id,
        company_id = EXCLUDED.company_id,
        full_name = EXCLUDED.full_name,
        is_active = true;
END $$;
