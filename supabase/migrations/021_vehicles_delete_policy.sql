-- 021_vehicles_delete_policy.sql
-- Faltaba la política de DELETE en "vehicles" (solo existían select/insert/
-- update desde 003_rls_policies.sql). Sin ella, Postgres descarta el borrado
-- silenciosamente (0 filas afectadas, sin lanzar error), así que la función
-- de "eliminar placa" agregada en la app no borraba nada aunque mostraba
-- éxito.
CREATE POLICY "vehicles_delete" ON vehicles FOR DELETE USING (
  company_id = get_user_company_id() AND (is_admin_general() OR is_admin_punto())
);
