-- 2D sales wastage: the unit a fixed wastage amount was entered
-- in. Null on lines sold before wastage units existed; their fixed
-- amount is in area units. The app already sends this field.
-- Receipt, invoice and draft items are jsonb and need no column.
-- Idempotent: safe if the column was added by hand.

alter table public.product_sales
  add column if not exists wastage_unit_uuid text;
