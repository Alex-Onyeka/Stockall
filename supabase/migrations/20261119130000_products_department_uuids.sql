-- ============================================================================
-- Stockall: products.department_uuids (multi-department products)
-- ============================================================================
-- The app now sends `department_uuids` on every product insert/update
-- (TempProductClass.toJson). Without this column those syncs fail.
-- Additive and safe to re-run: existing rows get an empty list, and the
-- single `department_uuid` column is left as it is.
-- ============================================================================

ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS department_uuids text[] NOT NULL DEFAULT '{}';
