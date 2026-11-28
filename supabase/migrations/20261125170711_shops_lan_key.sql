-- supabase/migrations/20261125170711_shops_lan_key.sql
-- 1. Check first: shops.shop_id exists, lan_key does not yet.
SELECT column_name, data_type
  FROM information_schema.columns
 WHERE table_schema = 'public' AND table_name = 'shops'
   AND column_name IN ('shop_id', 'lan_key');

-- 2. Secret per shop for the LAN shop tag (64 hex chars, ~244 random bits).
ALTER TABLE public.shops ADD COLUMN IF NOT EXISTS lan_key text;
UPDATE public.shops
   SET lan_key = replace(gen_random_uuid()::text, '-', '')
              || replace(gen_random_uuid()::text, '-', '')
 WHERE lan_key IS NULL;
ALTER TABLE public.shops
  ALTER COLUMN lan_key SET DEFAULT
    replace(gen_random_uuid()::text, '-', '')
    || replace(gen_random_uuid()::text, '-', '');
ALTER TABLE public.shops ALTER COLUMN lan_key SET NOT NULL;
