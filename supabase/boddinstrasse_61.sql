-- Applied to Supabase project EMBER (dxyaceoaqbgirjwidofq) on 2026-10-26
create table public.boddinstrasse_61 (
  id bigint generated always as identity primary key,
  init text not null check (init in ('reserve','buzzer','clean','door','legal','bikes','yard','elevator','cellar')),
  opt text not null check (char_length(opt) between 1 and 20),
  name text not null check (char_length(btrim(name)) between 1 and 60),
  name_key text not null,
  unit text check (unit is null or char_length(unit) <= 20),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (init, name_key)
);
alter table public.boddinstrasse_61 enable row level security;
create policy "public can read votes" on public.boddinstrasse_61 for select to anon, authenticated using (true);
revoke insert, update, delete on public.boddinstrasse_61 from anon, authenticated;

create or replace function public.cast_vote(p_init text, p_opt text, p_name text, p_unit text default null)
returns void language plpgsql security definer set search_path = public as $$
declare
  allowed jsonb := '{"reserve":["10k","20k","30k"],"buzzer":["fix","new","video","none"],"clean":["no","h30","h60"],"door":["fix","new","none"],"legal":["continue","end"],"bikes":["yes","no"],"yard":["no","s1","s2","s3","s4"],"elevator":["yes","no"],"cellar":["yes","no"]}';
  v_name text := btrim(coalesce(p_name, ''));
  v_unit text := nullif(btrim(coalesce(p_unit, '')), '');
begin
  if char_length(v_name) < 1 or char_length(v_name) > 60 then raise exception 'invalid name'; end if;
  if not (allowed ? p_init) or not ((allowed -> p_init) ? p_opt) then raise exception 'invalid vote'; end if;
  if v_unit is not null and char_length(v_unit) > 20 then raise exception 'invalid unit'; end if;
  insert into public.boddinstrasse_61 (init, opt, name, name_key, unit)
  values (p_init, p_opt, v_name, lower(v_name), v_unit)
  on conflict (init, name_key) do update
    set opt = excluded.opt, name = excluded.name, unit = coalesce(excluded.unit, public.boddinstrasse_61.unit), updated_at = now();
end; $$;
revoke all on function public.cast_vote(text, text, text, text) from public;
grant execute on function public.cast_vote(text, text, text, text) to anon, authenticated;
alter publication supabase_realtime add table public.boddinstrasse_61;
