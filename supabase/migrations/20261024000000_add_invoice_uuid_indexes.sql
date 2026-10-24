-- Speed up invoice deletion and foreign key referential integrity checks so
-- DELETE FROM invoices does not time out (error 57014).
create index if not exists idx_invoices_invoice_uuid on public.invoices (invoice_uuid);
create index if not exists idx_product_sales_invoice_uuid on public.product_sales (invoice_uuid);
create index if not exists idx_receipts_invoice_uuid on public.receipts (invoice_uuid);

