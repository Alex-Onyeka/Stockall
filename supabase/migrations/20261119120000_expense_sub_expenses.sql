-- ============================================================================
-- Stockall: Sub-expenses under one expense
-- ============================================================================
-- Adds an optional JSON list of sub-expenses to each expense, stored like
-- receipt items. Each element is:
--   { "uuid", "name", "description", "amount", "quantity", "payment_channel" }
-- When present, the app keeps expenses.amount equal to the sum of the
-- elements' amounts and expenses.payment_entries equal to their amounts
-- merged per payment channel, so reports keep reading expenses.amount only.
--
-- Additive and non-destructive: existing rows stay NULL and behave as before.
-- Apply before releasing an app version that writes sub_expenses.
-- ============================================================================

ALTER TABLE public.expenses
  ADD COLUMN IF NOT EXISTS sub_expenses jsonb NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'expenses_sub_expenses_is_array_check'
      AND conrelid = 'public.expenses'::regclass
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_sub_expenses_is_array_check
      CHECK (
        sub_expenses IS NULL
        OR jsonb_typeof(sub_expenses) = 'array'
      );
  END IF;
END $$;

COMMENT ON COLUMN public.expenses.sub_expenses IS
  'Optional breakdown of the expense (JSON array). amount stays the total.';
