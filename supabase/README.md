# Detroit Súper Wash - Supabase Migration Guide

## Applying Migrations
1. Open the Supabase SQL Editor in your project dashboard.
2. Run the files sequentially:
   - `001_initial_schema.sql`
   - `002_helper_functions.sql`
   - `003_rls_policies.sql`
   - `004_seed_data.sql`

## Creating the First Admin
1. Go to Authentication > Users in Supabase.
2. Create a new user with an email and password.
3. Copy the newly created user's `UUID`.
4. Run this query in SQL Editor (replace UUIDs appropriately):
   ```sql
   INSERT INTO public.users (id, company_id, role_id, full_name)
   VALUES (
     'YOUR_AUTH_USER_UUID',
     (SELECT id FROM companies LIMIT 1),
     (SELECT id FROM roles WHERE name = 'admin_general' LIMIT 1),
     'Admin Name'
   );
   ```

## Storage Buckets
Create the following storage buckets in the Supabase Dashboard:
- `service-photos`
- `expense-receipts`
- `vehicle-photos`

Set proper access policies for these buckets based on your requirements.
