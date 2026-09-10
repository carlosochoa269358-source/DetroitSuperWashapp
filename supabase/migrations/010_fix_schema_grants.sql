-- 010_fix_schema_grants.sql
-- Corrige "permission denied for schema public" (42501).
--
-- Esto no es un problema de RLS (row level security ya sigue mandando sobre
-- qué filas puede ver/tocar cada quien) sino de permisos base a nivel de
-- esquema/tabla/función: los roles anon/authenticated necesitan el permiso
-- general para "intentar" leer/escribir una tabla o ejecutar una función
-- antes de que RLS decida fila por fila. Las tablas y funciones originales
-- (migración 001-005) lo tenían por la configuración inicial del proyecto;
-- las agregadas después (service_prices, las funciones SECURITY DEFINER,
-- etc.) no lo heredaron automáticamente.
--
-- Seguro de correr las veces que sea: solo amplía permisos de acceso,
-- nunca de qué datos exactos se pueden ver (eso lo sigue controlando RLS).

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;

-- Para que las tablas/funciones que se creen en el futuro también queden
-- con permisos automáticamente, sin tener que repetir esto cada vez.
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO anon, authenticated, service_role;
