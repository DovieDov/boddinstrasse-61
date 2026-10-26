-- Priority (high / medium / low) per initiative, one per name. Additive: a NEW table and a NEW function; the votes table and cast_vote are not touched.
-- Run once in the Supabase SQL editor of project EMBER (dxyaceoaqbgirjwidofq).
create table if not exists public.boddinstrasse_61_priority (
  id bigint generated always as identity primary key,
  init text not null check (init in ('reserve','buzzer','clean','door','legal','bikes','yard','elevator','cellar')),
  priority text not null check (priority in ('high','medium','low')),
  name text not null check (char_length(btrim(name)) between 1 and 60),
  name_key text not null,
  unit text check (unit is null or char_length(unit) <= 20),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (init, name_key)
);
alter table public.boddinstrasse_61_priority enable row level security;
drop policy if exists "public can read priorities" on public.boddinstrasse_61_priority;
create policy "public can read priorities" on public.boddinstrasse_61_priority for select to anon, authenticated using (true);
revoke insert, update, delete on public.boddinstrasse_61_priority from anon, authenticated;

create or replace function public.set_priority(p_init text, p_priority text, p_name text, p_unit text default null)
returns void language plpgsql security definer set search_path = public as $$
declare
  v_name text := btrim(coalesce(p_name, ''));
  v_unit text := nullif(btrim(coalesce(p_unit, '')), '');
begin
  if char_length(v_name) < 1 or char_length(v_name) > 60 then raise exception 'invalid name'; end if;
  if p_init not in ('reserve','buzzer','clean','door','legal','bikes','yard','elevator','cellar') or p_priority not in ('high','medium','low') then raise exception 'invalid priority'; end if;
  if v_unit is not null and char_length(v_unit) > 20 then raise exception 'invalid unit'; end if;
  insert into public.boddinstrasse_61_priority (init, priority, name, name_key, unit)
  values (p_init, p_priority, v_name, lower(v_name), v_unit)
  on conflict (init, name_key) do update
    set priority = excluded.priority, name = excluded.name, unit = coalesce(excluded.unit, public.boddinstrasse_61_priority.unit), updated_at = now();
end; $$;
revoke all on function public.set_priority(text, text, text, text) from public;
grant execute on function public.set_priority(text, text, text, text) to anon, authenticated;
alter publication supabase_realtime add table public.boddinstrasse_61_priority;
