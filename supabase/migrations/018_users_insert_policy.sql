-- 018_users_insert_policy.sql
-- Faltaba una política de INSERT en "users" (solo existían select/update).
-- Sin esto, crear un usuario desde la app (no solo desde el SQL Editor)
-- queda bloqueado por RLS aunque quien lo intente sea admin general.

CREATE POLICY "users_insert" ON users FOR INSERT WITH CHECK (
  company_id = get_user_company_id() AND is_admin_general()
);
