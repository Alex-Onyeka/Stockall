-- Migration: Add custom payment methods, payment entries, and selected bank
-- Enables shops to configure multiple bank accounts and custom payment channels,
-- and stores granular payment breakdowns and selected custom bank details on receipts and invoices.

begin;

-- 1. Add custom_payment_methods column to shops
alter table public.shops
add column if not exists custom_payment_methods jsonb default '[]'::jsonb;

-- 2. Add payment_entries and selected_bank columns to receipts
alter table public.receipts
add column if not exists payment_entries jsonb,
add column if not exists selected_bank jsonb;

-- 3. Add payment_entries and selected_bank columns to invoices
alter table public.invoices
add column if not exists payment_entries jsonb,
add column if not exists selected_bank jsonb;

commit;
