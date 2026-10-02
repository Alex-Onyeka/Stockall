alter table public.production_materials_usage
  add column if not exists production_record_uuid text;

create index if not exists production_materials_usage_production_record_uuid_idx
  on public.production_materials_usage (production_record_uuid);
