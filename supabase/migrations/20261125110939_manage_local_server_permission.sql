-- Grants 'Manage Local Server' to the Owner and General Manager roles.
-- Idempotent: running it again changes nothing.
-- Detects whether access is text[] or jsonb (the schema isn't in the repo).

-- 1. Check role spellings first (read-only).
SELECT 'permissions' AS source, role, count(*) AS row_count
  FROM public.permissions GROUP BY role
UNION ALL
SELECT 'users', role, count(*) FROM public.users GROUP BY role
ORDER BY source, role;

-- 2. Grant.
DO $$
DECLARE
  perm  constant text   := 'Manage Local Server';
  roles constant text[] := ARRAY['Owner', 'General Manager'];
  r text; col_type text; n integer;
BEGIN
  -- A wrong spelling aborts the whole migration instead of silently granting nothing.
  FOREACH r IN ARRAY roles LOOP
    IF NOT EXISTS (SELECT 1 FROM public.permissions WHERE role = r) THEN
      RAISE EXCEPTION 'No permissions row for role "%". Check the SELECT above.', r;
    END IF;
  END LOOP;

  -- permissions.access
  SELECT udt_name INTO col_type FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'permissions' AND column_name = 'access';
  IF col_type = '_text' THEN
    UPDATE public.permissions
       SET access = array_append(coalesce(access, '{}'::text[]), perm)
     WHERE role = ANY (roles) AND NOT (perm = ANY (coalesce(access, '{}'::text[])));
  ELSIF col_type = 'jsonb' THEN
    UPDATE public.permissions
       SET access = coalesce(access, '[]'::jsonb) || to_jsonb(perm)
     WHERE role = ANY (roles) AND NOT (coalesce(access, '[]'::jsonb) ? perm);
  ELSE
    RAISE EXCEPTION 'Unexpected type for permissions.access: %', col_type;
  END IF;
  GET DIAGNOSTICS n = ROW_COUNT;
  RAISE NOTICE 'permissions rows updated: %', n;

  -- users.access
  SELECT udt_name INTO col_type FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'access';
  IF col_type = '_text' THEN
    UPDATE public.users
       SET access = array_append(coalesce(access, '{}'::text[]), perm)
     WHERE role = ANY (roles) AND NOT (perm = ANY (coalesce(access, '{}'::text[])));
  ELSIF col_type = 'jsonb' THEN
    UPDATE public.users
       SET access = coalesce(access, '[]'::jsonb) || to_jsonb(perm)
     WHERE role = ANY (roles) AND NOT (coalesce(access, '[]'::jsonb) ? perm);
  ELSE
    RAISE EXCEPTION 'Unexpected type for users.access: %', col_type;
  END IF;
  GET DIAGNOSTICS n = ROW_COUNT;
  RAISE NOTICE 'users rows updated: %', n;
END $$;
