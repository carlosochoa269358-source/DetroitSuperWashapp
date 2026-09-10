-- 009_drop_duplicate_recursive_policies.sql
-- Postgres combina TODAS las políticas de una tabla con OR. La migración 008
-- dejó políticas limpias (con funciones SECURITY DEFINER) en
-- service_order_workers, accounts_receivable_payments y
-- employee_settlement_items, pero en la base de datos real había además
-- políticas duplicadas con otros nombres (sow_*, ar_payments_*, esi_*) que
-- consultan la tabla padre directamente con EXISTS — exactamente el patrón
-- que causa la recursión infinita. Como ambas conviven, el problema seguía.
--
-- Estas duplicadas no vienen de ninguna migración de este proyecto, así que
-- se eliminan explícitamente por nombre. Las políticas "_operador" (que sí
-- son útiles y no causan recursión) se conservan.

DROP POLICY IF EXISTS "sow_insert" ON service_order_workers;
DROP POLICY IF EXISTS "sow_select_staff" ON service_order_workers;
DROP POLICY IF EXISTS "sow_update" ON service_order_workers;

DROP POLICY IF EXISTS "ar_payments_insert" ON accounts_receivable_payments;
DROP POLICY IF EXISTS "ar_payments_select" ON accounts_receivable_payments;

DROP POLICY IF EXISTS "esi_insert" ON employee_settlement_items;
DROP POLICY IF EXISTS "esi_select" ON employee_settlement_items;
