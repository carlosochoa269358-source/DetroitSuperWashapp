-- 004_seed_data.sql

DO $$
DECLARE
  v_company_id uuid;
  v_role_admin_general uuid;
  v_role_admin_punto uuid;
  v_role_operador uuid;
  v_cat_personal uuid;
  v_cat_insumos uuid;
  v_cat_operacion uuid;
  v_cat_marketing uuid;
  v_cat_equipos uuid;
BEGIN
  -- Insert Company
  INSERT INTO companies (name, document, email, phone_1, phone_2, address, city, department, commission_default_pct)
  VALUES (
    'Detroit Súper Wash', '1020456810', 'Detroitsuperwashgirardota@gmail.com', '3127177227', '3235791431',
    'Carrera 16 #7-105, Parqueadero Santa Ana', 'Girardota', 'Antioquia', 40.00
  ) RETURNING id INTO v_company_id;

  -- Insert Roles
  INSERT INTO roles (name, permissions) VALUES ('admin_general', '{"all": true}'::jsonb) RETURNING id INTO v_role_admin_general;
  INSERT INTO roles (name, permissions) VALUES ('admin_punto', '{"operational": true}'::jsonb) RETURNING id INTO v_role_admin_punto;
  INSERT INTO roles (name, permissions) VALUES ('operador', '{"basic": true}'::jsonb) RETURNING id INTO v_role_operador;

  -- Insert Vehicle Types
  INSERT INTO vehicle_types (name) VALUES 
  ('Automóvil'), ('SUV'), ('Camioneta / Pick-up'), ('Moto'), 
  ('Moto alto cilindraje'), ('Van / Microvan'), ('Taxi'), 
  ('Camión / vehículo pesado'), ('Bus / Buseta'), ('Otro');

  -- Insert Service Categories
  INSERT INTO service_categories (company_id, name, color_hex) VALUES
  (v_company_id, 'Lavadas', '#2196F3'),
  (v_company_id, 'Restauradas', '#9C27B0'),
  (v_company_id, 'Motor y Chasis', '#FF9800'),
  (v_company_id, 'Polichado', '#F44336'),
  (v_company_id, 'Detallado Premium', '#F5A623'),
  (v_company_id, 'Limpieza Interior', '#4CAF50');

  -- Insert Expense Categories
  INSERT INTO expense_categories (company_id, name, expense_type) VALUES (v_company_id, 'PERSONAL', 'operational') RETURNING id INTO v_cat_personal;
  INSERT INTO expense_categories (company_id, parent_id, name, expense_type) VALUES 
  (v_company_id, v_cat_personal, 'Nómina base', 'operational'),
  (v_company_id, v_cat_personal, 'Comisiones', 'operational'),
  (v_company_id, v_cat_personal, 'Anticipos', 'operational');

  INSERT INTO expense_categories (company_id, name, expense_type) VALUES (v_company_id, 'INSUMOS DE LAVADO', 'operational') RETURNING id INTO v_cat_insumos;
  INSERT INTO expense_categories (company_id, parent_id, name, expense_type) VALUES 
  (v_company_id, v_cat_insumos, 'Champú/Jabón', 'operational'),
  (v_company_id, v_cat_insumos, 'Ceras y Polichados', 'operational'),
  (v_company_id, v_cat_insumos, 'Desengrasantes', 'operational');

  INSERT INTO expense_categories (company_id, name, expense_type) VALUES (v_company_id, 'OPERACIÓN', 'operational') RETURNING id INTO v_cat_operacion;
  INSERT INTO expense_categories (company_id, parent_id, name, expense_type) VALUES 
  (v_company_id, v_cat_operacion, 'Servicios Públicos', 'operational'),
  (v_company_id, v_cat_operacion, 'Arriendo', 'operational'),
  (v_company_id, v_cat_operacion, 'Mantenimiento', 'operational');

  INSERT INTO expense_categories (company_id, name, expense_type) VALUES (v_company_id, 'MARKETING', 'operational') RETURNING id INTO v_cat_marketing;
  
  INSERT INTO expense_categories (company_id, name, expense_type) VALUES (v_company_id, 'EQUIPOS Y ACTIVOS', 'asset') RETURNING id INTO v_cat_equipos;

END $$;
