-- Derive quantity from price: the per-product toggle that lets
-- the sale dialog take a price and work out the quantity.
-- The app already reads and writes this column.
-- Idempotent: safe if the column was added by hand.

alter table public.products
  add column if not exists derive_quantity_from_price boolean default false;
