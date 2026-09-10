-- 001_initial_schema.sql
-- Detroit Súper Wash - Esquema Inicial Completo
-- Versión: 1.1 (corregida y completa)

-- Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- SECUENCIA PARA NUMERACIÓN DE ÓRDENES
-- =============================================
-- Nota: se crea una secuencia por año. En 2027 se deberá crear service_order_seq_2027.
CREATE SEQUENCE IF NOT EXISTS service_order_seq_2026 START 1;

-- =============================================
-- 1. COMPANIES
-- =============================================
CREATE TABLE companies (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                  TEXT NOT NULL,
    document              TEXT,                          -- NIT / Cédula
    email                 TEXT,
    phone_1               TEXT,
    phone_2               TEXT,
    address               TEXT,
    city                  TEXT,
    department            TEXT,
    commission_default_pct NUMERIC(5,2) NOT NULL DEFAULT 40.00, -- % comisión global
    is_active             BOOLEAN NOT NULL DEFAULT true,
    settings              JSONB DEFAULT '{}'::jsonb,    -- Configuraciones extensibles
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================
-- 2. ROLES
-- =============================================
CREATE TABLE roles (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name         TEXT NOT NULL UNIQUE, -- admin_general | admin_punto | operador
    display_name TEXT NOT NULL,
    permissions  JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================
-- 3. USERS (vinculado a auth.users de Supabase)
-- =============================================
CREATE TABLE users (
    id         UUID PRIMARY KEY,  -- DEBE coincidir con auth.users.id
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
    role_id    UUID NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    full_name  TEXT NOT NULL,
    email      TEXT,
    phone      TEXT,
    is_active  BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_company_id ON users(company_id);
CREATE INDEX idx_users_role_id ON users(role_id);

-- =============================================
-- 4. EMPLOYEES (lavadores / personal operativo)
-- =============================================
CREATE TABLE employees (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id     UUID NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
    user_id        UUID REFERENCES users(id),           -- Si el empleado también accede a la app
    full_name      TEXT NOT NULL,
    document       TEXT,                                -- Cédula
    phone          TEXT,
    role_label     TEXT,                                -- Cargo descriptivo ej: "Lavador"
    commission_pct NUMERIC(5,2) NOT NULL DEFAULT 40.00, -- % comisión individual
    hire_date      DATE,
    is_active      BOOLEAN NOT NULL DEFAULT true,
    notes          TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_employees_company_id ON employees(company_id);

-- =============================================
-- 5. VEHICLE TYPES (catálogo configurable)
-- =============================================
CREATE TABLE vehicle_types (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),           -- NULL = tipo global, UUID = específico empresa
    name       TEXT NOT NULL,
    icon       TEXT,                                    -- Nombre del icono en Flutter
    sort_order INT NOT NULL DEFAULT 0,
    is_active  BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================
-- 6. CUSTOMERS
-- =============================================
CREATE TABLE customers (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id    UUID NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
    full_name     TEXT NOT NULL,
    phone         TEXT NOT NULL,
    email         TEXT,
    notes         TEXT,
    is_active     BOOLEAN NOT NULL DEFAULT true,
    -- Campos desnormalizados para rendimiento (actualizados por triggers)
    total_spent   NUMERIC(15,2) NOT NULL DEFAULT 0,
    visit_count   INT NOT NULL DEFAULT 0,
    last_visit_at TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_customers_company_phone ON customers(company_id, phone);
CREATE INDEX idx_customers_company_name  ON customers(company_id, full_name);

-- =============================================
-- 7. VEHICLES
-- =============================================
CREATE TABLE vehicles (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
    customer_id     UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    vehicle_type_id UUID REFERENCES vehicle_types(id),
    plate           TEXT NOT NULL,    -- Siempre UPPERCASE, sin espacios (ver trigger)
    brand           TEXT,
    model           TEXT,
    color           TEXT,
    year            INT,
    notes           TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- Placa única por empresa
    CONSTRAINT vehicles_company_plate_unique UNIQUE (company_id, plate)
);

CREATE INDEX idx_vehicles_customer_id ON vehicles(customer_id);
CREATE INDEX idx_vehicles_company_plate ON vehicles(company_id, plate);

-- =============================================
-- 8. SERVICE CATEGORIES
-- =============================================
CREATE TABLE service_categories (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id  UUID NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
    name        TEXT NOT NULL,
    description TEXT,
    color_hex   TEXT,              -- Color para UI ej: '#2196F3'
    sort_order  INT NOT NULL DEFAULT 0,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_service_categories_company ON service_categories(company_id, is_active);

-- =============================================
-- 9. SERVICES
-- =============================================
CREATE TABLE services (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id               UUID NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
    category_id              UUID REFERENCES service_categories(id),
    name                     TEXT NOT NULL,
    description              TEXT,
    base_price               NUMERIC(12,2) NOT NULL,
    estimated_duration_min   INT,                     -- Duración estimada en minutos
    commission_pct           NUMERIC(5,2) NOT NULL DEFAULT 40.00,
    applicable_vehicle_types UUID[],                  -- Array de vehicle_type IDs aplicables
    is_active                BOOLEAN NOT NULL DEFAULT true,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_services_company_category ON services(company_id, category_id, is_active);

-- =============================================
-- 10. SERVICES_VEHICLE_TYPES (Many-to-Many)
-- =============================================
CREATE TABLE services_vehicle_types (
    service_id      UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    vehicle_type_id UUID NOT NULL REFERENCES vehicle_types(id) ON DELETE CASCADE,
    PRIMARY KEY (service_id, vehicle_type_id)
);

-- =============================================
-- 11. CASH REGISTERS (Turnos de caja)
-- =============================================
CREATE TABLE cash_registers (
    id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                UUID NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
    opened_by                 UUID NOT NULL REFERENCES users(id),
    closed_by                 UUID REFERENCES users(id),
    opening_date              DATE NOT NULL,          -- Fecha del turno
    opening_amount            NUMERIC(12,2) NOT NULL DEFAULT 0, -- Efectivo inicial
    opening_denominations     JSONB,                  -- Detalle de billetes/monedas
    closing_amount_expected   NUMERIC(12,2),          -- Calculado al cierre
    closing_amount_counted    NUMERIC(12,2),          -- Contado físicamente
    closing_difference        NUMERIC(12,2),          -- Diferencia
    difference_reason         TEXT,                   -- Obligatorio si diferencia ≠ 0
    status                    TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed')),
    opened_at                 TIMESTAMPTZ NOT NULL DEFAULT now(),
    closed_at                 TIMESTAMPTZ,
    notes                     TEXT,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- Solo puede haber un turno abierto por empresa por día
    CONSTRAINT cash_registers_one_open_per_day UNIQUE (company_id, opening_date, status)
);

COMMENT ON TABLE cash_registers IS 'Turnos de caja. Un solo turno abierto por día por empresa.';

-- =============================================
-- 12. SERVICE ORDERS (Tabla central del sistema)
-- =============================================
CREATE TABLE service_orders (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number     TEXT NOT NULL,         -- DSW-2026-000001 (generado por trigger)
    company_id       UUID NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
    cash_register_id UUID NOT NULL REFERENCES cash_registers(id),
    customer_id      UUID NOT NULL REFERENCES customers(id),
    vehicle_id       UUID NOT NULL REFERENCES vehicles(id),
    service_id       UUID NOT NULL REFERENCES services(id),
    created_by       UUID NOT NULL REFERENCES users(id),
    -- Estado del flujo
    status           TEXT NOT NULL DEFAULT 'new'
                     CHECK (status IN ('new','in_progress','finished','paid','receivable','cancelled')),
    -- Precios (snapshot al momento del registro)
    base_price       NUMERIC(12,2) NOT NULL,
    discount_amount  NUMERIC(12,2) NOT NULL DEFAULT 0,
    discount_reason  TEXT,
    final_price      NUMERIC(12,2) NOT NULL, -- base_price - discount_amount
    -- Comisión (snapshot)
    commission_pct   NUMERIC(5,2) NOT NULL,
    commission_amount NUMERIC(12,2) NOT NULL, -- Calculado sobre final_price
    detroit_amount   NUMERIC(12,2) NOT NULL,  -- final_price - commission_amount
    -- Control de pagos (actualizado por triggers)
    paid_amount      NUMERIC(12,2) NOT NULL DEFAULT 0,
    pending_amount   NUMERIC(12,2) NOT NULL DEFAULT 0,
    -- Timestamps de flujo
    started_at       TIMESTAMPTZ,            -- Cuando inicia el trabajo
    finished_at      TIMESTAMPTZ,            -- Cuando finaliza el trabajo
    paid_at          TIMESTAMPTZ,            -- Cuando se completa el pago
    -- Cancelación (solo Admin General)
    cancelled_at     TIMESTAMPTZ,
    cancel_reason    TEXT,
    cancelled_by     UUID REFERENCES users(id),
    -- Extras
    notes            TEXT,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- Número de orden único por empresa
    CONSTRAINT service_orders_order_number_unique UNIQUE (company_id, order_number)
);

CREATE INDEX idx_so_company_status     ON service_orders(company_id, status);
CREATE INDEX idx_so_company_created    ON service_orders(company_id, created_at DESC);
CREATE INDEX idx_so_customer_id        ON service_orders(customer_id);
CREATE INDEX idx_so_vehicle_id         ON service_orders(vehicle_id);
CREATE INDEX idx_so_cash_register_id   ON service_orders(cash_register_id);
CREATE INDEX idx_so_created_by         ON service_orders(created_by);

COMMENT ON TABLE service_orders IS 'Tabla central. Cada orden es un servicio realizado. Nunca eliminar registros.';
COMMENT ON COLUMN service_orders.base_price IS 'Snapshot del precio al momento del registro. Inalterable.';
COMMENT ON COLUMN service_orders.commission_pct IS 'Snapshot del % de comisión al momento del registro. Inalterable.';

-- =============================================
-- 13. SERVICE ORDER WORKERS
-- (Por ahora 1 lavador por orden, arquitectura soporta N)
-- =============================================
CREATE TABLE service_order_workers (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_order_id UUID NOT NULL REFERENCES service_orders(id) ON DELETE RESTRICT,
    employee_id      UUID NOT NULL REFERENCES employees(id) ON DELETE RESTRICT,
    commission_pct   NUMERIC(5,2) NOT NULL,
    commission_amount NUMERIC(12,2) NOT NULL,  -- Comisión total calculada
    commission_earned NUMERIC(12,2) NOT NULL DEFAULT 0, -- Acumulado liquidable (por abonos CxC)
    is_settled       BOOLEAN NOT NULL DEFAULT false,
    settlement_id    UUID,                     -- FK a employee_settlements (se agrega después)
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_sow_service_order  ON service_order_workers(service_order_id);
CREATE INDEX idx_sow_employee       ON service_order_workers(employee_id);
CREATE INDEX idx_sow_unsettled      ON service_order_workers(employee_id, is_settled) WHERE is_settled = false;

-- =============================================
-- 14. PAYMENTS
-- =============================================
CREATE TABLE payments (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_order_id UUID NOT NULL REFERENCES service_orders(id) ON DELETE RESTRICT,
    cash_register_id UUID NOT NULL REFERENCES cash_registers(id),
    registered_by    UUID NOT NULL REFERENCES users(id),
    amount           NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    payment_method   TEXT NOT NULL
                     CHECK (payment_method IN ('efectivo','transferencia','nequi','daviplata','tarjeta_debito','tarjeta_credito','pse')),
    reference        TEXT,                 -- Número de transferencia/referencia
    notes            TEXT,
    -- Reversión (en lugar de DELETE)
    is_reversed      BOOLEAN NOT NULL DEFAULT false,
    reversed_at      TIMESTAMPTZ,
    reversed_by      UUID REFERENCES users(id),
    reverse_reason   TEXT,
    -- Fecha del pago (puede diferir de created_at si se registra retroactivo)
    paid_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_payments_service_order   ON payments(service_order_id);
CREATE INDEX idx_payments_cash_register   ON payments(cash_register_id);
CREATE INDEX idx_payments_method          ON payments(cash_register_id, payment_method);

COMMENT ON TABLE payments IS 'Pagos de órdenes. Nunca eliminar. Usar is_reversed = true para reversar.';

-- =============================================
-- 15. ACCOUNTS RECEIVABLE (Cuentas por Cobrar)
-- =============================================
CREATE TABLE accounts_receivable (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id       UUID NOT NULL REFERENCES companies(id),
    service_order_id UUID NOT NULL REFERENCES service_orders(id) ON DELETE RESTRICT,
    customer_id      UUID NOT NULL REFERENCES customers(id),
    original_amount  NUMERIC(12,2) NOT NULL,
    paid_amount      NUMERIC(12,2) NOT NULL DEFAULT 0,
    pending_amount   NUMERIC(12,2) NOT NULL,
    status           TEXT NOT NULL DEFAULT 'open'
                     CHECK (status IN ('open','partial','paid')),
    due_date         DATE,
    notes            TEXT,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_ar_company_status ON accounts_receivable(company_id, status);
CREATE INDEX idx_ar_customer_id    ON accounts_receivable(customer_id);
CREATE INDEX idx_ar_service_order  ON accounts_receivable(service_order_id);

-- =============================================
-- 16. ACCOUNTS RECEIVABLE PAYMENTS (Abonos)
-- =============================================
CREATE TABLE accounts_receivable_payments (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    accounts_receivable_id  UUID NOT NULL REFERENCES accounts_receivable(id) ON DELETE RESTRICT,
    cash_register_id        UUID NOT NULL REFERENCES cash_registers(id),
    registered_by           UUID NOT NULL REFERENCES users(id),
    amount                  NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    payment_method          TEXT NOT NULL
                            CHECK (payment_method IN ('efectivo','transferencia','nequi','daviplata','tarjeta_debito','tarjeta_credito','pse')),
    reference               TEXT,
    notes                   TEXT,
    paid_at                 TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_arp_ar_id           ON accounts_receivable_payments(accounts_receivable_id);
CREATE INDEX idx_arp_cash_register   ON accounts_receivable_payments(cash_register_id);

-- =============================================
-- 17. CASH MOVEMENTS (Historial de movimientos de caja)
-- =============================================
CREATE TABLE cash_movements (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id       UUID NOT NULL REFERENCES companies(id),
    cash_register_id UUID NOT NULL REFERENCES cash_registers(id),
    registered_by    UUID NOT NULL REFERENCES users(id),
    type             TEXT NOT NULL CHECK (type IN ('income','expense','adjustment')),
    category         TEXT NOT NULL,  -- pago_servicio | abono_cxc | gasto | apertura | liquidacion
    payment_method   TEXT NOT NULL,
    amount           NUMERIC(12,2) NOT NULL,
    -- Referencias opcionales
    service_order_id UUID REFERENCES service_orders(id),
    expense_id       UUID,           -- FK a expenses (se agrega después)
    ar_payment_id    UUID REFERENCES accounts_receivable_payments(id),
    notes            TEXT,
    movement_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_cash_movements_register ON cash_movements(cash_register_id);
CREATE INDEX idx_cash_movements_type     ON cash_movements(cash_register_id, type, payment_method);

-- =============================================
-- 18. EXPENSE CATEGORIES
-- =============================================
CREATE TABLE expense_categories (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id   UUID NOT NULL REFERENCES companies(id),
    parent_id    UUID REFERENCES expense_categories(id),  -- Para subcategorías
    name         TEXT NOT NULL,
    expense_type TEXT NOT NULL DEFAULT 'operational'
                 CHECK (expense_type IN ('operational','asset')),
    is_active    BOOLEAN NOT NULL DEFAULT true,
    sort_order   INT NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_expense_categories_company    ON expense_categories(company_id, is_active);
CREATE INDEX idx_expense_categories_parent     ON expense_categories(parent_id);

-- =============================================
-- 19. EXPENSES
-- =============================================
CREATE TABLE expenses (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id              UUID NOT NULL REFERENCES companies(id),
    category_id             UUID NOT NULL REFERENCES expense_categories(id),
    cash_register_id        UUID REFERENCES cash_registers(id),
    registered_by           UUID NOT NULL REFERENCES users(id),
    responsible_employee_id UUID REFERENCES employees(id),
    description             TEXT NOT NULL,
    amount                  NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    payment_method          TEXT NOT NULL,
    provider                TEXT,           -- Proveedor (opcional)
    expense_type            TEXT NOT NULL DEFAULT 'operational'
                            CHECK (expense_type IN ('operational','asset')),
    expense_date            DATE NOT NULL,
    notes                   TEXT,
    -- Cancelación (en lugar de DELETE)
    status                  TEXT NOT NULL DEFAULT 'active'
                            CHECK (status IN ('active','cancelled')),
    cancelled_at            TIMESTAMPTZ,
    cancelled_by            UUID REFERENCES users(id),
    cancel_reason           TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_expenses_company_date ON expenses(company_id, expense_date);
CREATE INDEX idx_expenses_category     ON expenses(category_id);

COMMENT ON TABLE expenses IS 'Gastos operativos y compras. Nunca eliminar. Usar status=cancelled.';

-- Agregar FK de cash_movements a expenses (la columna ya existe, solo falta la restricción)
ALTER TABLE cash_movements ADD CONSTRAINT fk_cash_movements_expense FOREIGN KEY (expense_id) REFERENCES expenses(id);

-- =============================================
-- 20. EMPLOYEE SETTLEMENTS (Liquidaciones)
-- =============================================
CREATE TABLE employee_settlements (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id        UUID NOT NULL REFERENCES companies(id),
    employee_id       UUID NOT NULL REFERENCES employees(id),
    cash_register_id  UUID REFERENCES cash_registers(id),  -- Turno en que se liquidó
    settled_by        UUID NOT NULL REFERENCES users(id),
    period_from       DATE NOT NULL,
    period_to         DATE NOT NULL,
    total_sales       NUMERIC(12,2) NOT NULL DEFAULT 0, -- Ventas del período
    commission_pct    NUMERIC(5,2) NOT NULL,
    commission_earned NUMERIC(12,2) NOT NULL DEFAULT 0, -- Comisión total generada
    commission_paid   NUMERIC(12,2) NOT NULL DEFAULT 0, -- Valor efectivamente pagado
    payment_method    TEXT,
    notes             TEXT,
    status            TEXT NOT NULL DEFAULT 'draft'
                      CHECK (status IN ('draft','closed')),
    settled_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_settlements_company_employee ON employee_settlements(company_id, employee_id);
CREATE INDEX idx_settlements_cash_register    ON employee_settlements(cash_register_id);

COMMENT ON TABLE employee_settlements IS 'Liquidaciones cerradas NO pueden modificarse sin autorización del Admin General.';

-- Agregar FK de service_order_workers a settlements
ALTER TABLE service_order_workers ADD CONSTRAINT fk_sow_settlement
    FOREIGN KEY (settlement_id) REFERENCES employee_settlements(id);

-- =============================================
-- 21. EMPLOYEE SETTLEMENT ITEMS
-- =============================================
CREATE TABLE employee_settlement_items (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    settlement_id            UUID NOT NULL REFERENCES employee_settlements(id) ON DELETE RESTRICT,
    service_order_id         UUID NOT NULL REFERENCES service_orders(id),
    service_order_worker_id  UUID NOT NULL REFERENCES service_order_workers(id),
    service_date             DATE NOT NULL,
    commission_amount        NUMERIC(12,2) NOT NULL,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_settlement_items_settlement ON employee_settlement_items(settlement_id);

-- =============================================
-- 22. DAILY CLOSINGS (Cierres de turno)
-- =============================================
CREATE TABLE daily_closings (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id            UUID NOT NULL REFERENCES companies(id),
    cash_register_id      UUID NOT NULL REFERENCES cash_registers(id),
    closed_by             UUID NOT NULL REFERENCES users(id),
    closing_date          DATE NOT NULL,
    -- Ventas del día
    total_sales           NUMERIC(12,2) NOT NULL DEFAULT 0,
    cash_sales            NUMERIC(12,2) NOT NULL DEFAULT 0,
    transfer_sales        NUMERIC(12,2) NOT NULL DEFAULT 0,
    other_sales           NUMERIC(12,2) NOT NULL DEFAULT 0,
    -- CxC
    new_receivables       NUMERIC(12,2) NOT NULL DEFAULT 0,
    receivable_payments   NUMERIC(12,2) NOT NULL DEFAULT 0,
    -- Comisiones y gastos
    total_commissions     NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_expenses        NUMERIC(12,2) NOT NULL DEFAULT 0,
    expense_breakdown     JSONB DEFAULT '{}'::jsonb,  -- Por categoría
    -- Cuadre de caja
    opening_amount        NUMERIC(12,2) NOT NULL DEFAULT 0,
    expected_cash         NUMERIC(12,2) NOT NULL DEFAULT 0,
    counted_cash          NUMERIC(12,2) NOT NULL DEFAULT 0,
    difference            NUMERIC(12,2) NOT NULL DEFAULT 0,
    difference_reason     TEXT,
    -- Estadísticas
    service_count         INT NOT NULL DEFAULT 0,
    new_customers_count   INT NOT NULL DEFAULT 0,
    notes                 TEXT,
    status                TEXT NOT NULL DEFAULT 'draft'
                          CHECK (status IN ('draft','closed')),
    closed_at             TIMESTAMPTZ,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_daily_closings_company_date ON daily_closings(company_id, closing_date);
COMMENT ON TABLE daily_closings IS 'Un cierre por turno. Requiere liquidación de comisiones previa.';

-- =============================================
-- 23. MONTHLY CLOSINGS (Cierres mensuales)
-- =============================================
CREATE TABLE monthly_closings (
    id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                      UUID NOT NULL REFERENCES companies(id),
    closed_by                       UUID NOT NULL REFERENCES users(id),
    year                            INT NOT NULL,
    month                           INT NOT NULL CHECK (month BETWEEN 1 AND 12),
    -- Resumen financiero
    gross_sales                     NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_discounts                 NUMERIC(12,2) NOT NULL DEFAULT 0,
    net_sales                       NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_commissions               NUMERIC(12,2) NOT NULL DEFAULT 0,
    margin_after_commissions        NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_expenses                  NUMERIC(12,2) NOT NULL DEFAULT 0,
    expense_by_category             JSONB DEFAULT '{}'::jsonb,
    operational_result              NUMERIC(12,2) NOT NULL DEFAULT 0,
    -- CxC
    total_receivables_generated     NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_receivables_collected     NUMERIC(12,2) NOT NULL DEFAULT 0,
    pending_receivables             NUMERIC(12,2) NOT NULL DEFAULT 0,
    -- Estadísticas operativas
    service_count                   INT NOT NULL DEFAULT 0,
    new_customers_count             INT NOT NULL DEFAULT 0,
    recurring_customers_count       INT NOT NULL DEFAULT 0,
    vehicles_attended               INT NOT NULL DEFAULT 0,
    top_service_id                  UUID REFERENCES services(id),
    top_vehicle_type_id             UUID REFERENCES vehicle_types(id),
    top_employee_id                 UUID REFERENCES employees(id),
    sales_by_payment_method         JSONB DEFAULT '{}'::jsonb,
    status                          TEXT NOT NULL DEFAULT 'draft'
                                    CHECK (status IN ('draft','closed')),
    closed_at                       TIMESTAMPTZ,
    created_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT monthly_closings_unique_month UNIQUE (company_id, year, month)
);

COMMENT ON TABLE monthly_closings IS 'Solo Admin General puede ver y cerrar cierres mensuales.';

-- =============================================
-- 24. AUDIT LOGS (Solo inserción — NUNCA eliminar)
-- =============================================
CREATE TABLE audit_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id  UUID NOT NULL REFERENCES companies(id),
    user_id     UUID REFERENCES users(id),
    action      TEXT NOT NULL,      -- create | update | cancel | reverse | close | settle
    table_name  TEXT NOT NULL,
    record_id   UUID NOT NULL,
    old_values  JSONB,
    new_values  JSONB,
    reason      TEXT,               -- Obligatorio para cancel/reverse
    ip_address  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_logs_company_table ON audit_logs(company_id, table_name, record_id);
CREATE INDEX idx_audit_logs_user          ON audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_logs_created       ON audit_logs(created_at DESC);

COMMENT ON TABLE audit_logs IS 'SOLO INSERCIÓN. Nunca UPDATE ni DELETE en esta tabla. Integridad innegociable.';

-- =============================================
-- 25. ATTACHMENTS (Fotos y adjuntos)
-- =============================================
CREATE TABLE attachments (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id   UUID NOT NULL REFERENCES companies(id),
    uploaded_by  UUID NOT NULL REFERENCES users(id),
    entity_type  TEXT NOT NULL CHECK (entity_type IN ('service_order','expense','vehicle','settlement')),
    entity_id    UUID NOT NULL,
    file_name    TEXT NOT NULL,
    file_url     TEXT NOT NULL,    -- URL de Supabase Storage
    file_type    TEXT,             -- image/jpeg | image/png | application/pdf
    file_size_bytes INT,
    notes        TEXT,             -- ej: 'Estado de ingreso - rayón lado derecho'
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_attachments_entity ON attachments(entity_type, entity_id);

COMMENT ON COLUMN attachments.notes IS 'Para service_orders: describe el daño documentado. Ej: Estado de ingreso.';

-- =============================================
-- 26. INVENTORY ITEMS (Estructura preparada, sin lógica activa)
-- =============================================
CREATE TABLE inventory_items (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id       UUID NOT NULL REFERENCES companies(id),
    name             TEXT NOT NULL,
    unit             TEXT,          -- unidad | litro | kg | etc
    quantity         NUMERIC(12,3) NOT NULL DEFAULT 0,
    min_quantity     NUMERIC(12,3) NOT NULL DEFAULT 0,
    cost_per_unit    NUMERIC(12,2),
    provider         TEXT,
    is_active        BOOLEAN NOT NULL DEFAULT true,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE inventory_items IS 'Estructura preparada para Fase futura. Sin lógica activa en v1.';
