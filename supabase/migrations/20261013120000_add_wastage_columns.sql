-- 2D sales wastage: the per-product toggle and, on sold lines,
-- the wastage entered at sale. The app already reads and writes
-- these columns.
-- Idempotent: safe if the columns were added by hand.

alter table public.products
  add column if not exists manage_sales_wastage boolean default false;

alter table public.product_sales
  add column if not exists manage_sales_wastage boolean,
  add column if not exists is_percentage_wastage boolean,
  add column if not exists wastage_amount double precision;
