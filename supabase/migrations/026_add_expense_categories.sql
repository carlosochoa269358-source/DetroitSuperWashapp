-- 026_add_expense_categories.sql
-- No existe pantalla en Configuración para crear categorías de gasto (la
-- pestaña "Categorías" es de servicios), así que se agregan por SQL,
-- siguiendo el mismo árbol de categorías sembrado en 004_seed_data.sql.
--
--   - "Plan celular" como subcategoría de OPERACIÓN (junto a Servicios
--     Públicos, Arriendo, Mantenimiento).
--   - "Ajuste nómina" como subcategoría de PERSONAL (junto a Nómina base,
--     Comisiones, Anticipos).

DO $$
DECLARE
  v_company_id uuid;
  v_cat_personal uuid;
  v_cat_operacion uuid;
BEGIN
  SELECT id INTO v_company_id FROM companies LIMIT 1;
  SELECT id INTO v_cat_personal FROM expense_categories WHERE company_id = v_company_id AND name = 'PERSONAL' AND parent_id IS NULL;
  SELECT id INTO v_cat_operacion FROM expense_categories WHERE company_id = v_company_id AND name = 'OPERACIÓN' AND parent_id IS NULL;

  INSERT INTO expense_categories (company_id, parent_id, name, expense_type)
  VALUES
    (v_company_id, v_cat_operacion, 'Plan celular', 'operational'),
    (v_company_id, v_cat_personal, 'Ajuste nómina', 'operational');
END $$;
