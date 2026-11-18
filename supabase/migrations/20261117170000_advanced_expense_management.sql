-- ============================================================================
-- Stockall: Advanced Expense Management System - Supabase SQL Migrations
-- ============================================================================
-- IMPORTANT:
--   Execute these migrations in the exact order shown below (Migration 1 -> 6)
--   in the Supabase SQL Editor.
--   All statements are designed to be safe, additive, and non-destructive to
--   existing expense, staff, and purchase records.
-- ============================================================================


-- ============================================================================
-- MIGRATION 1: Create `expense_categories` table
-- ============================================================================
-- Stores custom, shop-scoped expense categories (e.g., Electricity, Rent, Fuel).
-- System categories (Simple Expense, Staff Salary, Stock Purchase) are handled
-- via `expenses.expense_type` and do not require rows in this table.

CREATE TABLE IF NOT EXISTS public.expense_categories (
  uuid uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id bigint NOT NULL,
  name text NOT NULL,
  department_uuid text NULL,
  department_name text NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.expense_categories IS
  'Custom business-defined expense categories, scoped per shop_id.';


-- ============================================================================
-- MIGRATION 2: Update the existing `expenses` table
-- ============================================================================
-- Adds categorization, staff salary linkage, stock purchase linkage, and
-- payment channel columns while preserving all existing historical records.
-- Existing rows automatically default to expense_type = ''simple_expense''.

ALTER TABLE public.expenses
  ADD COLUMN IF NOT EXISTS expense_type text NOT NULL DEFAULT 'simple_expense',
  ADD COLUMN IF NOT EXISTS expense_category_uuid uuid NULL,
  ADD COLUMN IF NOT EXISTS expense_category_name text NULL,
  ADD COLUMN IF NOT EXISTS payment_channel text NULL,
  ADD COLUMN IF NOT EXISTS payment_entries jsonb NULL,
  ADD COLUMN IF NOT EXISTS staff_name text NULL;

-- Ensure expense_type only accepts valid system/custom discriminators.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'expenses_expense_type_check'
      AND conrelid = 'public.expenses'::regclass
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_expense_type_check
      CHECK (
        expense_type IN (
          'simple_expense',
          'staff_salary',
          'stock_purchase',
          'custom'
        )
      );
  END IF;
END $$;

-- Link expenses.expense_category_uuid -> expense_categories.uuid.
-- ON DELETE SET NULL ensures deleting a custom category never destroys
-- historical expense records (expense_category_name preserves the label).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'expenses_expense_category_uuid_fkey'
      AND conrelid = 'public.expenses'::regclass
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_expense_category_uuid_fkey
      FOREIGN KEY (expense_category_uuid)
      REFERENCES public.expense_categories(uuid)
      ON DELETE SET NULL;
  END IF;
END $$;


-- ============================================================================
-- MIGRATION 3: Establish `staff_uuid` and `purchase_uuid` columns & FKs
-- ============================================================================
-- Matches the exact column data types of `public.users(user_id)` and
-- `public.purchases(uuid)` in your existing database so foreign keys attach
-- cleanly without type-mismatch errors.

DO $$
DECLARE
  v_user_id_type text;
  v_purchase_uuid_type text;
BEGIN
  -- 1. staff_uuid -> public.users(user_id) (ON DELETE SET NULL)
  SELECT format_type(a.atttypid, a.atttypmod)
    INTO v_user_id_type
  FROM pg_attribute a
  JOIN pg_class c ON c.oid = a.attrelid
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relname = 'users'
    AND a.attname = 'user_id'
    AND NOT a.attisdropped;

  IF v_user_id_type IS NULL THEN
    v_user_id_type := 'text';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'expenses'
      AND column_name = 'staff_uuid'
  ) THEN
    EXECUTE format(
      'ALTER TABLE public.expenses ADD COLUMN staff_uuid %s NULL',
      v_user_id_type
    );
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(c.conkey)
    WHERE n.nspname = 'public'
      AND t.relname = 'users'
      AND a.attname = 'user_id'
      AND c.contype IN ('p', 'u')
  ) AND NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'expenses_staff_uuid_fkey'
      AND conrelid = 'public.expenses'::regclass
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_staff_uuid_fkey
      FOREIGN KEY (staff_uuid)
      REFERENCES public.users(user_id)
      ON DELETE SET NULL;
  END IF;

  -- 2. purchase_uuid -> public.purchases(uuid) (ON DELETE CASCADE)
  SELECT format_type(a.atttypid, a.atttypmod)
    INTO v_purchase_uuid_type
  FROM pg_attribute a
  JOIN pg_class c ON c.oid = a.attrelid
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relname = 'purchases'
    AND a.attname = 'uuid'
    AND NOT a.attisdropped;

  IF v_purchase_uuid_type IS NULL THEN
    v_purchase_uuid_type := 'text';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'expenses'
      AND column_name = 'purchase_uuid'
  ) THEN
    EXECUTE format(
      'ALTER TABLE public.expenses ADD COLUMN purchase_uuid %s NULL',
      v_purchase_uuid_type
    );
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(c.conkey)
    WHERE n.nspname = 'public'
      AND t.relname = 'purchases'
      AND a.attname = 'uuid'
      AND c.contype IN ('p', 'u')
  ) AND NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'expenses_purchase_uuid_fkey'
      AND conrelid = 'public.expenses'::regclass
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_purchase_uuid_fkey
      FOREIGN KEY (purchase_uuid)
      REFERENCES public.purchases(uuid)
      ON DELETE CASCADE;
  END IF;
END $$;


-- ============================================================================
-- MIGRATION 4: Create Indexes and Unique Constraints
-- ============================================================================
-- Prevents duplicate custom category names per shop (case-insensitive),
-- guarantees at most ONE expense record per purchase_uuid, and indexes all
-- common query paths.

CREATE UNIQUE INDEX IF NOT EXISTS expense_categories_shop_name_uidx
  ON public.expense_categories (shop_id, lower(trim(name)));

CREATE INDEX IF NOT EXISTS expense_categories_shop_id_idx
  ON public.expense_categories (shop_id);

-- Critical: Guarantees one purchase cannot generate multiple expense records,
-- even during offline sync retries or concurrent requests.
CREATE UNIQUE INDEX IF NOT EXISTS expenses_purchase_uuid_uidx
  ON public.expenses (purchase_uuid)
  WHERE purchase_uuid IS NOT NULL;

CREATE INDEX IF NOT EXISTS expenses_shop_date_idx
  ON public.expenses (shop_id, created_date DESC);

CREATE INDEX IF NOT EXISTS expenses_shop_type_idx
  ON public.expenses (shop_id, expense_type);

CREATE INDEX IF NOT EXISTS expenses_staff_uuid_idx
  ON public.expenses (shop_id, staff_uuid, created_date DESC)
  WHERE staff_uuid IS NOT NULL;

CREATE INDEX IF NOT EXISTS expenses_category_uuid_idx
  ON public.expenses (shop_id, expense_category_uuid)
  WHERE expense_category_uuid IS NOT NULL;


-- ============================================================================
-- MIGRATION 5: Configure Row Level Security (RLS) for `expense_categories`
-- ============================================================================
-- Ensures users can only read/write expense categories belonging to shops
-- they own (shops.user_id = auth.uid()) or belong to as staff
-- (auth.uid()::text = ANY(shops.employees) or users.auth_user_id = shops.user_id).

ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS expense_categories_select_shop_member ON public.expense_categories;
CREATE POLICY expense_categories_select_shop_member
  ON public.expense_categories
  FOR SELECT
  TO authenticated
  USING (
    shop_id IN (
      SELECT s.shop_id
      FROM public.shops s
      WHERE s.user_id = auth.uid()
         OR auth.uid()::text = ANY(COALESCE(s.employees, '{}'::text[]))
         OR EXISTS (
           SELECT 1
           FROM public.users u
           WHERE u.user_id = auth.uid()
             AND u.auth_user_id = s.user_id
         )
    )
  );

DROP POLICY IF EXISTS expense_categories_insert_shop_member ON public.expense_categories;
CREATE POLICY expense_categories_insert_shop_member
  ON public.expense_categories
  FOR INSERT
  TO authenticated
  WITH CHECK (
    shop_id IN (
      SELECT s.shop_id
      FROM public.shops s
      WHERE s.user_id = auth.uid()
         OR auth.uid()::text = ANY(COALESCE(s.employees, '{}'::text[]))
         OR EXISTS (
           SELECT 1
           FROM public.users u
           WHERE u.user_id = auth.uid()
             AND u.auth_user_id = s.user_id
         )
    )
  );

DROP POLICY IF EXISTS expense_categories_update_shop_member ON public.expense_categories;
CREATE POLICY expense_categories_update_shop_member
  ON public.expense_categories
  FOR UPDATE
  TO authenticated
  USING (
    shop_id IN (
      SELECT s.shop_id
      FROM public.shops s
      WHERE s.user_id = auth.uid()
         OR auth.uid()::text = ANY(COALESCE(s.employees, '{}'::text[]))
         OR EXISTS (
           SELECT 1
           FROM public.users u
           WHERE u.user_id = auth.uid()
             AND u.auth_user_id = s.user_id
         )
    )
  )
  WITH CHECK (
    shop_id IN (
      SELECT s.shop_id
      FROM public.shops s
      WHERE s.user_id = auth.uid()
         OR auth.uid()::text = ANY(COALESCE(s.employees, '{}'::text[]))
         OR EXISTS (
           SELECT 1
           FROM public.users u
           WHERE u.user_id = auth.uid()
             AND u.auth_user_id = s.user_id
         )
    )
  );

DROP POLICY IF EXISTS expense_categories_delete_shop_member ON public.expense_categories;
CREATE POLICY expense_categories_delete_shop_member
  ON public.expense_categories
  FOR DELETE
  TO authenticated
  USING (
    shop_id IN (
      SELECT s.shop_id
      FROM public.shops s
      WHERE s.user_id = auth.uid()
         OR auth.uid()::text = ANY(COALESCE(s.employees, '{}'::text[]))
         OR EXISTS (
           SELECT 1
           FROM public.users u
           WHERE u.user_id = auth.uid()
             AND u.auth_user_id = s.user_id
         )
    )
  );


-- ============================================================================
-- MIGRATION 6: Idempotent Upsert RPC for Purchase-Generated Expenses
-- ============================================================================
-- Provides an atomic server-side upsert keyed on `purchase_uuid` so that
-- creating/updating a purchase expense from any client or sync retry is
-- strictly idempotent and never creates duplicate rows.

CREATE OR REPLACE FUNCTION public.upsert_purchase_expense(
  p_uuid text,
  p_shop_id bigint,
  p_purchase_uuid text,
  p_amount double precision,
  p_name text,
  p_description text,
  p_created_date timestamptz,
  p_updated_at timestamptz,
  p_user_id text,
  p_creator text,
  p_department_uuid text,
  p_department_name text,
  p_payment_channel text,
  p_payment_entries jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN
  IF p_amount IS NULL OR p_amount <= 0 THEN
    DELETE FROM public.expenses
    WHERE purchase_uuid::text = p_purchase_uuid;
    RETURN;
  END IF;

  INSERT INTO public.expenses (
    uuid,
    shop_id,
    purchase_uuid,
    expense_type,
    amount,
    name,
    description,
    created_date,
    updated_at,
    user_id,
    creator,
    department_uuid,
    department_name,
    payment_channel,
    payment_entries
  )
  VALUES (
    p_uuid::uuid,
    p_shop_id,
    p_purchase_uuid::uuid,
    'stock_purchase',
    p_amount,
    p_name,
    p_description,
    p_created_date,
    p_updated_at,
    p_user_id,
    p_creator,
    p_department_uuid,
    p_department_name,
    p_payment_channel,
    p_payment_entries
  )
  ON CONFLICT (purchase_uuid) WHERE purchase_uuid IS NOT NULL
  DO UPDATE SET
    amount = EXCLUDED.amount,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = EXCLUDED.updated_at,
    department_uuid = EXCLUDED.department_uuid,
    department_name = EXCLUDED.department_name,
    payment_channel = EXCLUDED.payment_channel,
    payment_entries = EXCLUDED.payment_entries;
END;
$$;
