-- 023_cleanup_test_turnos.sql
-- Limpieza de turnos de prueba antes de operar en serio.
--
-- Alcance solicitado por el dueño:
--   - Borrar TODOS los turnos con fecha <= 2026-09-14, EXCEPTO el turno
--     734f2 (14-09-2026), que se conserva.
--   - Borrar además el turno 5e5f1 (aparece fechado 2026-09-11, ya incluido
--     en el rango de arriba de todos modos).
--
-- Este script corre en el SQL Editor de Supabase (como postgres/service
-- role), NO como usuario autenticado de la app, así que las políticas RLS
-- de la app no aplican aquí — es un borrado administrativo directo.

-- =====================================================================
-- PASO 1 — SOLO VERIFICACIÓN. Corre esto primero y confirma que la lista
-- de turnos es exactamente la que quieres borrar antes de seguir.
-- =====================================================================
SELECT
  id,
  substring(id::text, 1, 5) AS codigo,
  opening_date,
  status,
  opened_at
FROM cash_registers
WHERE (opening_date <= '2026-09-14' AND substring(id::text, 1, 5) <> '734f2')
   OR substring(id::text, 1, 5) = '5e5f1'
ORDER BY opening_date, opened_at;

-- =====================================================================
-- PASO 2 — SOLO VERIFICACIÓN. Detecta un caso raro: una orden que se
-- ABRIÓ en un turno que se conserva pero se PAGÓ (fiado) dentro de uno de
-- los turnos que se van a borrar (o viceversa). Si esto devuelve filas,
-- avísame antes de continuar — el borrado de abajo asume que no hay
-- ninguna, y si las hay tocaría ajustar el script.
-- =====================================================================
SELECT so.id, so.order_number, so.status,
       cr1.opening_date AS turno_apertura, substring(cr1.id::text,1,5) AS codigo_apertura,
       cr2.opening_date AS turno_pago,     substring(cr2.id::text,1,5) AS codigo_pago
FROM service_orders so
JOIN cash_registers cr1 ON cr1.id = so.cash_register_id
LEFT JOIN cash_registers cr2 ON cr2.id = so.paid_cash_register_id
WHERE so.paid_cash_register_id IS NOT NULL
  AND so.paid_cash_register_id <> so.cash_register_id
  AND (
    (cr1.id IN (
      SELECT id FROM cash_registers
      WHERE (opening_date <= '2026-09-14' AND substring(id::text,1,5) <> '734f2')
         OR substring(id::text,1,5) = '5e5f1'
    ))
    <>
    (cr2.id IN (
      SELECT id FROM cash_registers
      WHERE (opening_date <= '2026-09-14' AND substring(id::text,1,5) <> '734f2')
         OR substring(id::text,1,5) = '5e5f1'
    ))
  );

-- =====================================================================
-- PASO 3 — BORRADO REAL. Solo correr después de revisar los dos SELECT
-- de arriba y confirmar que todo se ve bien. Todo en una transacción: si
-- algo falla a mitad de camino, no queda nada a medias.
-- =====================================================================
BEGIN;

CREATE TEMP TABLE _turnos_a_borrar AS
SELECT id FROM cash_registers
WHERE (opening_date <= '2026-09-14' AND substring(id::text, 1, 5) <> '734f2')
   OR substring(id::text, 1, 5) = '5e5f1';

CREATE TEMP TABLE _ordenes_a_borrar AS
SELECT id FROM service_orders WHERE cash_register_id IN (SELECT id FROM _turnos_a_borrar);

CREATE TEMP TABLE _settlements_a_borrar AS
SELECT id FROM employee_settlements WHERE cash_register_id IN (SELECT id FROM _turnos_a_borrar);

CREATE TEMP TABLE _ar_a_borrar AS
SELECT id FROM accounts_receivable WHERE service_order_id IN (SELECT id FROM _ordenes_a_borrar);

-- Orden de borrado: hijos antes que padres (respeta las llaves foráneas).
DELETE FROM employee_settlement_items
WHERE settlement_id IN (SELECT id FROM _settlements_a_borrar)
   OR service_order_id IN (SELECT id FROM _ordenes_a_borrar);

DELETE FROM cash_movements
WHERE cash_register_id IN (SELECT id FROM _turnos_a_borrar)
   OR service_order_id IN (SELECT id FROM _ordenes_a_borrar);

DELETE FROM service_order_workers
WHERE service_order_id IN (SELECT id FROM _ordenes_a_borrar);

DELETE FROM accounts_receivable_payments
WHERE cash_register_id IN (SELECT id FROM _turnos_a_borrar)
   OR accounts_receivable_id IN (SELECT id FROM _ar_a_borrar);

DELETE FROM accounts_receivable
WHERE id IN (SELECT id FROM _ar_a_borrar);

DELETE FROM payments
WHERE cash_register_id IN (SELECT id FROM _turnos_a_borrar)
   OR service_order_id IN (SELECT id FROM _ordenes_a_borrar);

DELETE FROM employee_settlements
WHERE id IN (SELECT id FROM _settlements_a_borrar);

DELETE FROM expenses
WHERE cash_register_id IN (SELECT id FROM _turnos_a_borrar);

DELETE FROM daily_closings
WHERE cash_register_id IN (SELECT id FROM _turnos_a_borrar);

-- service_order_items tiene un trigger que bloquea cambios a las líneas de
-- una orden que ya no está "new" (aquí estamos borrando líneas de órdenes
-- ya pagadas) — se desactiva solo para este borrado administrativo y se
-- reactiva enseguida, dentro de la misma transacción.
ALTER TABLE service_order_items DISABLE TRIGGER trg_prevent_items_edit_after_new;
ALTER TABLE service_order_items DISABLE TRIGGER trg_recompute_service_order_totals;

DELETE FROM service_order_items
WHERE service_order_id IN (SELECT id FROM _ordenes_a_borrar);

ALTER TABLE service_order_items ENABLE TRIGGER trg_prevent_items_edit_after_new;
ALTER TABLE service_order_items ENABLE TRIGGER trg_recompute_service_order_totals;

DELETE FROM attachments
WHERE entity_type = 'service_order' AND entity_id IN (SELECT id FROM _ordenes_a_borrar);

DELETE FROM service_orders
WHERE id IN (SELECT id FROM _ordenes_a_borrar);

DELETE FROM cash_registers
WHERE id IN (SELECT id FROM _turnos_a_borrar);

-- Recalcula total_spent/visit_count de clientes: el trigger que los
-- mantiene solo SUMA en cada pago nuevo, nunca resta cuando se borra un
-- pago, así que sin esto los clientes de prueba quedarían con visitas y
-- gasto "fantasma" de las órdenes que se acaban de borrar.
UPDATE customers c
SET total_spent = COALESCE(sub.total, 0),
    visit_count  = COALESCE(sub.cnt, 0)
FROM (
  SELECT so.customer_id, SUM(p.amount) AS total, COUNT(*) AS cnt
  FROM payments p
  JOIN service_orders so ON so.id = p.service_order_id
  WHERE p.is_reversed = false
  GROUP BY so.customer_id
) sub
WHERE c.id = sub.customer_id;

UPDATE customers
SET total_spent = 0, visit_count = 0
WHERE id NOT IN (
  SELECT DISTINCT so.customer_id FROM payments p
  JOIN service_orders so ON so.id = p.service_order_id
  WHERE p.is_reversed = false
);

COMMIT;
