-- 2D storage items: quantity type and sheet size, mirroring
-- products. The app already reads and writes these columns.
-- Idempotent: safe if the columns were added by hand.

alter table public.storage_products
  add column if not exists quantity_type integer default 1,
  add column if not exists width_dimension double precision,
  add column if not exists height_dimension double precision;
