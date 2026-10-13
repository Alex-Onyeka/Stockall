-- Backfill items on receipts, invoices and purchases from the existing
-- item tables. Run by hand after
-- migrations/20261010120000_add_items_to_receipts_invoices_purchases.sql.
-- Kept outside migrations/ so `supabase db push` never runs it.
--
-- Only touches rows whose items are still empty, so it is safe to run
-- more than once, and to re-run while older app versions still create
-- rows without items.
--
-- Each item is the full item-table row (to_jsonb), which is the shape
-- TempProductSaleRecord.fromJson / TempItemPurchaseRecord.fromJson read.
-- If the SQL editor times out on a large project, run one update at a
-- time.

begin;

-- Receipts: lines linked by receipt_uuid. Includes the prorated lines
-- of invoice part-payment receipts, as the app writes them.
update public.receipts r
set items = agg.items
from (
  select ps.receipt_uuid::text as parent_uuid,
         jsonb_agg(to_jsonb(ps) order by ps.created_at, ps.uuid) as items
  from public.product_sales ps
  where ps.receipt_uuid is not null
  group by ps.receipt_uuid
) agg
where r.uuid::text = agg.parent_uuid
  and r.items = '[]'::jsonb;

-- Invoices: lines linked by invoice_uuid. Rows with a receipt_uuid are
-- part-payment receipt lines and belong to that receipt, not here.
update public.invoices i
set items = agg.items
from (
  select ps.invoice_uuid::text as parent_uuid,
         jsonb_agg(to_jsonb(ps) order by ps.created_at, ps.uuid) as items
  from public.product_sales ps
  where ps.invoice_uuid is not null
    and ps.receipt_uuid is null
  group by ps.invoice_uuid
) agg
where i.invoice_uuid::text = agg.parent_uuid
  and i.items = '[]'::jsonb;

-- Purchases: lines linked by purchase_id.
update public.purchases p
set items = agg.items
from (
  select ipr.purchase_id::text as parent_uuid,
         jsonb_agg(to_jsonb(ipr) order by ipr.created_at, ipr.uuid) as items
  from public.item_purchase_records ipr
  where ipr.purchase_id is not null
  group by ipr.purchase_id
) agg
where p.uuid::text = agg.parent_uuid
  and p.items = '[]'::jsonb;

commit;
