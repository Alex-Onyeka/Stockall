alter table public.product_sales
add column if not exists order_item_uuid text;
