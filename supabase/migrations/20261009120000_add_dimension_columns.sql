-- 2D (dimensional) items: width/height/quantity type on products and
-- on sold lines. The app already reads and writes these columns.
-- Idempotent: safe if the columns were added by hand.

alter table public.products
  add column if not exists width_dimension double precision,
  add column if not exists height_dimension double precision,
  add column if not exists quantity_type integer default 1;

alter table public.product_sales
  add column if not exists width_dimension double precision,
  add column if not exists height_dimension double precision,
  add column if not exists quantity_type integer;
