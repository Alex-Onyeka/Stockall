alter table public.production_records
  add column if not exists unit_uuid text,
  add column if not exists units_list jsonb not null default '[]'::jsonb;

alter table public.production_materials_usage
  add column if not exists unit_uuid text,
  add column if not exists units_list jsonb not null default '[]'::jsonb;
