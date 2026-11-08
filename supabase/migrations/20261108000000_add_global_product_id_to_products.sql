-- Migration: Multi-Branch & Multi-Department Product Cluster Linking
-- Adds global_product_id to products table and indexes it for O(1) counterpart resolution.

begin;

-- 1. Add global_product_id column
alter table public.products
add column if not exists global_product_id text;

-- 2. Create index on global_product_id for fast cluster lookups across branches and departments
create index if not exists idx_products_global_product_id
on public.products (global_product_id);

-- 3. Backfill existing products so every product belongs to its own family by default
update public.products
set global_product_id = coalesce(uuid, gen_random_uuid()::text)
where global_product_id is null or trim(global_product_id) = '';

-- 4. Clean up deprecated single-pointer columns if they exist
alter table public.products
drop column if exists transfered_product_id;

alter table public.products
drop column if exists transfered_product_id_department;

commit;
