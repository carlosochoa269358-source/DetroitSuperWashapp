-- 022_customers_delete_and_vehicle_transfer.sql

-- Igual que vehicles (021), "customers" tampoco tenía política de DELETE.
-- A diferencia de las placas, eliminar un cliente completo se restringe a
-- admin_general (decisión explícita del dueño: es más delicado que corregir
-- una placa, igual que anular órdenes/gastos o reversar liquidaciones).
CREATE POLICY "customers_delete" ON customers FOR DELETE USING (
  company_id = get_user_company_id() AND is_admin_general()
);

-- Transferir una placa a otro cliente (cuando el carro cambia de dueño) es
-- un UPDATE normal de vehicles.customer_id — ya cubierto por la política
-- "vehicles_update" existente (admin_general OR admin_punto), así que no
-- hace falta una política nueva para eso.
