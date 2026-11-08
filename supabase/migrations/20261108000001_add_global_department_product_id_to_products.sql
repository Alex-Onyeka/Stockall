-- Migration: Multi-Department Product Cluster Linking
-- Adds global_department_product_id to products table and indexes it for fast counterpart resolution within a shop.

begin;

-- 1. Add global_department_product_id column
alter table public.products
add column if not exists global_department_product_id text;

-- 2. Create index on global_department_product_id for fast cluster lookups across departments
create index if not exists idx_products_global_department_product_id
on public.products (global_department_product_id);

-- 3. Backfill existing products so every department product belongs to its own family by default
update public.products
set global_department_product_id = coalesce(uuid, gen_random_uuid()::text)
where global_department_product_id is null or trim(global_department_product_id) = '';

commit;
