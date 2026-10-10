-- Line items stored on the parent document. The app still writes
-- product_sales and item_purchase_records as well (dual-write).
-- Older app versions don't send items, so their rows get '[]'.
-- Idempotent: safe if the columns were added by hand.

alter table public.receipts
  add column if not exists items jsonb not null default '[]'::jsonb;

alter table public.invoices
  add column if not exists items jsonb not null default '[]'::jsonb;

alter table public.purchases
  add column if not exists items jsonb not null default '[]'::jsonb;
