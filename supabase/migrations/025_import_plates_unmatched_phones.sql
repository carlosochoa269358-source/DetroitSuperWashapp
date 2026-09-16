-- 025_import_plates_unmatched_phones.sql
-- Los 3 telefonos que 024 no pudo emparejar no existian como clientes (no
-- estaban en la migracion original de 460 clientes de 020). Como si
-- tenemos su nombre en el Excel, se crean como clientes nuevos y se les
-- agrega su placa de una vez.

DO $$
DECLARE
  v_company_id uuid;
BEGIN
  SELECT id INTO v_company_id FROM companies LIMIT 1;

  INSERT INTO customers (company_id, full_name, phone)
  VALUES
    (v_company_id, 'AICARDO', '3237071936'),
    (v_company_id, 'ANDRES', '3106432996'),
    (v_company_id, 'MONICA', '3122759335')
  ON CONFLICT (company_id, phone) DO NOTHING;
END $$;

INSERT INTO vehicles (company_id, customer_id, vehicle_type_id, plate)
SELECT c.company_id, c.id, vt.id, x.placa
FROM (VALUES
  ('3237071936', 'Camioneta / Pick-up', 'NPU306'),
  ('3106432996', 'Moto', 'OHJ29G'),
  ('3122759335', 'Camioneta / Pick-up', 'QMU701')
) AS x(telefono, tipo_nombre, placa)
JOIN customers c ON c.phone = x.telefono AND c.company_id = (SELECT id FROM companies LIMIT 1)
JOIN vehicle_types vt ON vt.name = x.tipo_nombre
ON CONFLICT (company_id, plate) DO NOTHING;
